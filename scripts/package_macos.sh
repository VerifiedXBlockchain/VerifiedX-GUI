#!/bin/bash
# Builds the macOS wallet installer in one step: Flutter app, Core CLI,
# bundle assembly, signing, disk image and notarization.
#
# Every input is pinned by the command line rather than by the state of the
# machine. The network picks the Xcode scheme and the dart-define, the bundle
# version comes from APP_V, and the Core CLI is built from a clean export of a
# git ref, never from the working tree of the Core checkout.
#
# Usage:
#   MACOS_SIGN_IDENTITY="Developer ID Application: <Team> (<TEAMID>)" \
#   MACOS_NOTARY_PROFILE="<notarytool keychain profile>" \
#     scripts/package_macos.sh <mainnet|testnet|devnet> [options]
#
# Options:
#   --arch <arm64|x64>   CLI architecture. Defaults to this machine's.
#   --core-ref <ref>     Core CLI branch, tag or commit. Defaults to the
#                        network's branch on origin.
#   --skip-notarize      Stop after signing. The installer will not pass
#                        Gatekeeper; for local testing only.
#   --allow-dirty        Build a mainnet installer from uncommitted GUI changes.
#
# Environment:
#   CORE_CLI_DIR         Core CLI checkout. Defaults to ../Core-CLI.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CORE_CLI_DIR="${CORE_CLI_DIR:-$REPO_ROOT/../Core-CLI}"
ENVIRONMENT_CONFIG="$REPO_ROOT/macos/Flutter/EnvironmentConfig.xcconfig"
ENVIRONMENT_CONFIG_PATH="macos/Flutter/EnvironmentConfig.xcconfig"

BUILD_DIR="$REPO_ROOT/build/macos-package"
ARCHIVE="$BUILD_DIR/Runner.xcarchive"
ARCHIVED_APP="$ARCHIVE/Products/Applications/VFX Switchblade.app"
CORE_SOURCE="$BUILD_DIR/core-cli-src"
CORE_PUBLISH="$BUILD_DIR/core-cli-publish"
LOG_DIR="$BUILD_DIR/logs"
STAGED_APP="$REPO_ROOT/installers/resources/Runner/VFXWallet.app"

usage() {
  sed -n '2,25p' "$0" | sed 's/^# \{0,1\}//' >&2
  exit 64
}

fail() {
  echo "error: $1" >&2
  exit 1
}

step() {
  echo
  echo "==> $1"
}

require_tool() {
  command -v "$1" > /dev/null || fail "$1 not found on PATH"
}

has_arch() {
  [[ " $(lipo -archs "$1") " == *" $2 "* ]]
}

# Build tools print thousands of lines. Keep them in a log and show the end of
# it only when the tool fails.
run_logged() {
  local name="$1"
  shift
  local log="$LOG_DIR/$name.log"
  if ! "$@" > "$log" 2>&1; then
    tail -n 40 "$log" >&2
    fail "$name failed; full log at $log"
  fi
}

NETWORK=""
ARCH="$(uname -m)"
CORE_REF=""
SKIP_NOTARIZE=0
ALLOW_DIRTY=0

while [ $# -gt 0 ]; do
  case "$1" in
    mainnet | testnet | devnet)
      NETWORK="$1"
      ;;
    --arch)
      [ $# -ge 2 ] || usage
      ARCH="$2"
      shift
      ;;
    --core-ref)
      [ $# -ge 2 ] || usage
      CORE_REF="$2"
      shift
      ;;
    --skip-notarize)
      SKIP_NOTARIZE=1
      ;;
    --allow-dirty)
      ALLOW_DIRTY=1
      ;;
    *)
      usage
      ;;
  esac
  shift
done

case "$NETWORK" in
  mainnet)
    SCHEME="Runner"
    DART_DEFINE=""
    DEFAULT_CORE_REF="origin/main"
    ;;
  testnet)
    SCHEME="Runner-Testnet"
    DART_DEFINE="TESTNET=true"
    DEFAULT_CORE_REF="origin/testnet"
    ;;
  devnet)
    SCHEME="Runner-Devnet"
    DART_DEFINE="DEVNET=true"
    DEFAULT_CORE_REF="origin/devnet"
    ;;
  *)
    usage
    ;;
esac
CORE_REF="${CORE_REF:-$DEFAULT_CORE_REF}"

case "$ARCH" in
  arm64)
    RUNTIME_ID="osx-arm64"
    APP_ARCH="arm64"
    DMG_NAME="VFX-OSX-ARM-Installer.dmg"
    CLI_ZIP_NAME="vfx-corecli-mac-arm.zip"
    ;;
  x64 | x86_64)
    RUNTIME_ID="osx-x64"
    APP_ARCH="x86_64"
    DMG_NAME="VFX-OSX-Intel-Installer.dmg"
    CLI_ZIP_NAME="vfx-corecli-mac-intel.zip"
    ;;
  *)
    fail "unsupported architecture '$ARCH'; use arm64 or x64"
    ;;
esac

EXPORT_DIR="$REPO_ROOT/installers/exports/$NETWORK"
DMG="$EXPORT_DIR/$DMG_NAME"
CLI_ZIP="$EXPORT_DIR/$CLI_ZIP_NAME"
BUILD_INFO="$EXPORT_DIR/BUILD-INFO-$ARCH.txt"

: "${MACOS_SIGN_IDENTITY:?Set MACOS_SIGN_IDENTITY to the Developer ID Application identity (see docs/macos-release-signing.md)}"
if [ "$SKIP_NOTARIZE" -eq 0 ]; then
  : "${MACOS_NOTARY_PROFILE:?Set MACOS_NOTARY_PROFILE to the notarytool keychain profile, or pass --skip-notarize (see docs/macos-release-signing.md)}"
fi

cd "$REPO_ROOT"

# appdmg is a global npm package, so it follows the active Node version. Fall
# back to the version the repo pins when the current one does not have it.
if ! command -v appdmg > /dev/null && [ -f "$REPO_ROOT/.nvmrc" ]; then
  pinned_node_bin="$HOME/.nvm/versions/node/$(tr -d '[:space:]' < "$REPO_ROOT/.nvmrc")/bin"
  if [ -x "$pinned_node_bin/appdmg" ]; then
    PATH="$pinned_node_bin:$PATH"
  fi
fi

for tool in git fvm pod xcodebuild dotnet appdmg; do
  require_tool "$tool"
done
[ -d "$CORE_CLI_DIR/.git" ] || [ -f "$CORE_CLI_DIR/.git" ] \
  || fail "Core CLI checkout not found at $CORE_CLI_DIR; set CORE_CLI_DIR"

APP_VERSION="$(sed -n 's/^const APP_V = "\(.*\)";$/\1/p' lib/core/app_constants.dart)"
[[ "$APP_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] \
  || fail "could not read APP_V from lib/core/app_constants.dart (got '$APP_VERSION')"

step "Checking the GUI working tree"
GUI_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
GUI_COMMIT="$(git rev-parse --short HEAD)"
# The Xcode schemes rewrite EnvironmentConfig.xcconfig on every build, so a
# difference there says nothing about the source being built.
GUI_CHANGES="$(git status --porcelain -- . ":(exclude)$ENVIRONMENT_CONFIG_PATH")"
if [ -n "$GUI_CHANGES" ]; then
  echo "Uncommitted GUI changes:"
  echo "$GUI_CHANGES"
  if [ "$NETWORK" = "mainnet" ] && [ "$ALLOW_DIRTY" -eq 0 ]; then
    fail "a mainnet installer must be built from committed code; commit or pass --allow-dirty"
  fi
fi
echo "GUI $GUI_BRANCH @ $GUI_COMMIT, version $APP_VERSION"

step "Exporting Core CLI source at $CORE_REF"
git -C "$CORE_CLI_DIR" fetch origin
CORE_COMMIT="$(git -C "$CORE_CLI_DIR" rev-parse --verify --quiet "$CORE_REF^{commit}")" \
  || fail "Core CLI ref '$CORE_REF' not found in $CORE_CLI_DIR"
rm -rf "$BUILD_DIR"
mkdir -p "$CORE_SOURCE" "$LOG_DIR" "$EXPORT_DIR"
git -C "$CORE_CLI_DIR" archive "$CORE_COMMIT" | tar -x -C "$CORE_SOURCE"
echo "Core CLI $CORE_REF @ ${CORE_COMMIT:0:8}"

# Core's testnet branch overrides the network in Program.cs right after this
# marker. A binary built from such a ref joins testnet whatever flags the GUI
# passes, so it must never go into a mainnet installer.
CORE_PROGRAM="$CORE_SOURCE/VerifiedXCore/Program.cs"
forced_network_line="$(awk '/\/\/Forced Testnet/ { getline; print; exit }' "$CORE_PROGRAM")"
if [[ "$forced_network_line" =~ ^[[:space:]]*Globals\.IsTestNet[[:space:]]*=[[:space:]]*true ]]; then
  CORE_FORCES_TESTNET="yes"
  [ "$NETWORK" != "mainnet" ] \
    || fail "Core CLI ref $CORE_REF forces testnet in Program.cs; build mainnet from a release ref"
elif [ -n "$forced_network_line" ]; then
  CORE_FORCES_TESTNET="no"
else
  CORE_FORCES_TESTNET="unknown (marker not found in Program.cs)"
  echo "warning: could not check whether Core CLI ref $CORE_REF forces testnet" >&2
fi

step "Building the Flutter app ($SCHEME)"
run_logged pub-get fvm flutter pub get
# CocoaPods refuses to run without a UTF-8 locale, which shells started by
# automation do not set.
run_logged pod-install env LANG="${LANG:-en_US.UTF-8}" pod install --project-directory=macos
# Xcode resolves these lists before it runs the Flutter build phase that
# fills them, so a fresh checkout needs them to exist.
touch macos/Flutter/ephemeral/FlutterInputs.xcfilelist macos/Flutter/ephemeral/FlutterOutputs.xcfilelist

environment_config_backup="$(mktemp)"
cp "$ENVIRONMENT_CONFIG" "$environment_config_backup"
restore_environment_config() {
  cp "$environment_config_backup" "$ENVIRONMENT_CONFIG"
  rm -f "$environment_config_backup"
}
trap restore_environment_config EXIT

# Settings on the command line outrank the project and its xcconfig files, so
# the network, entry point and version cannot be changed by an earlier build
# or run. Signing is left to sign_macos_app.sh, which runs once the CLI is in
# the bundle.
DART_DEFINES="$(printf '%s' "$DART_DEFINE" | base64)"
run_logged xcodebuild-archive xcodebuild \
  -workspace macos/Runner.xcworkspace \
  -scheme "$SCHEME" \
  -configuration Release \
  -derivedDataPath "$BUILD_DIR/DerivedData" \
  -archivePath "$ARCHIVE" \
  archive \
  DART_DEFINES="$DART_DEFINES" \
  FLUTTER_TARGET="lib/main.dart" \
  MARKETING_VERSION="$APP_VERSION" \
  CODE_SIGNING_ALLOWED=NO

[ -d "$ARCHIVED_APP" ] || fail "archive did not produce $ARCHIVED_APP"
has_arch "$ARCHIVED_APP/Contents/MacOS/VFX Switchblade" "$APP_ARCH" \
  || fail "the app was not built for $APP_ARCH"
bundle_version="$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$ARCHIVED_APP/Contents/Info.plist")"
[ "$bundle_version" = "$APP_VERSION" ] \
  || fail "bundle version is $bundle_version, expected $APP_VERSION"

step "Building the Core CLI ($RUNTIME_ID)"
run_logged dotnet-publish dotnet publish "$CORE_SOURCE/VerifiedXCore/VerifiedXCore.csproj" \
  -c Release \
  -r "$RUNTIME_ID" \
  -f net6.0 \
  --self-contained true \
  -p:PublishSingleFile=true \
  -o "$CORE_PUBLISH"

[ -f "$CORE_PUBLISH/VerifiedXCore" ] || fail "dotnet publish did not produce VerifiedXCore"
has_arch "$CORE_PUBLISH/VerifiedXCore" "$APP_ARCH" \
  || fail "the CLI was not built for $APP_ARCH"
[ -f "$CORE_PUBLISH/BIP39/wordlist/english.txt" ] \
  || fail "the CLI build has no BIP39 wordlists"

# Core checks some native libraries into git as prebuilt files. One built for
# the other architecture publishes without error and fails only when the CLI
# first calls it. The runtime looks a library up with and without the "lib"
# prefix, so either spelling can satisfy the lookup.
UNLOADABLE_LIBRARIES=""
for library in "$CORE_PUBLISH"/*.dylib; do
  if has_arch "$library" "$APP_ARCH"; then
    continue
  fi
  library_name="$(basename "$library")"
  case "$library_name" in
    lib*) alternate="$CORE_PUBLISH/${library_name#lib}" ;;
    *) alternate="$CORE_PUBLISH/lib$library_name" ;;
  esac
  if [ -f "$alternate" ] && has_arch "$alternate" "$APP_ARCH"; then
    continue
  fi
  UNLOADABLE_LIBRARIES="$UNLOADABLE_LIBRARIES $library_name"
done
UNLOADABLE_LIBRARIES="${UNLOADABLE_LIBRARIES# }"
if [ -n "$UNLOADABLE_LIBRARIES" ]; then
  echo "warning: not built for $APP_ARCH, the CLI cannot load: $UNLOADABLE_LIBRARIES" >&2
fi

step "Assembling the bundle"
rm -rf "$STAGED_APP"
mkdir -p "$(dirname "$STAGED_APP")"
ditto "$ARCHIVED_APP" "$STAGED_APP"
ditto "$CORE_PUBLISH" "$STAGED_APP/Contents/Resources/VFXCore"
ditto "$CORE_PUBLISH/BIP39" "$STAGED_APP/Contents/Resources/BIP39"

step "Signing"
"$REPO_ROOT/scripts/sign_macos_app.sh" "$STAGED_APP"

step "Building the disk image"
rm -f "$DMG" "$CLI_ZIP" "$BUILD_INFO"
appdmg "$REPO_ROOT/installers/dmg/config.json" "$DMG"

if [ "$SKIP_NOTARIZE" -eq 0 ]; then
  step "Notarizing"
  "$REPO_ROOT/scripts/notarize_macos.sh" "$DMG"
  NOTARIZED="yes"
else
  NOTARIZED="no"
fi

step "Packaging the standalone CLI"
(cd "$STAGED_APP/Contents/Resources" && zip -qr "$CLI_ZIP" VFXCore)

{
  echo "network:        $NETWORK"
  echo "version:        $APP_VERSION"
  echo "architecture:   $ARCH"
  echo "built:          $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
  echo "gui:            $GUI_BRANCH @ $GUI_COMMIT"
  if [ -n "$GUI_CHANGES" ]; then
    echo "gui changes:    uncommitted"
    echo "$GUI_CHANGES" | sed 's/^/                /'
  else
    echo "gui changes:    none"
  fi
  echo "core cli:       $CORE_REF @ $CORE_COMMIT"
  echo "forces testnet: $CORE_FORCES_TESTNET"
  echo "cannot load:    ${UNLOADABLE_LIBRARIES:-nothing}"
  echo "signed as:      $MACOS_SIGN_IDENTITY"
  echo "notarized:      $NOTARIZED"
  echo "sha256:"
  (cd "$EXPORT_DIR" && shasum -a 256 "$DMG_NAME" "$CLI_ZIP_NAME" | sed 's/^/  /')
} > "$BUILD_INFO"

step "Done"
cat "$BUILD_INFO"
echo
echo "Artifacts in $EXPORT_DIR"
if [ "$NOTARIZED" = "no" ]; then
  echo "warning: this installer is NOT notarized and will be blocked by Gatekeeper on other Macs" >&2
fi
if [ -n "$UNLOADABLE_LIBRARIES" ]; then
  echo "warning: the CLI in this installer cannot load: $UNLOADABLE_LIBRARIES" >&2
fi
