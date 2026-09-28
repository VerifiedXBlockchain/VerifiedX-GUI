#!/bin/bash
# Signs the packaged macOS app for distribution outside the App Store.
#
# Run this after the Core CLI and the BIP39 wordlists are copied into the
# bundle and before the disk image is built. A signature seals every file in
# the bundle, so anything copied in afterwards invalidates it. Nested code is
# signed inside-out (CLI payload, frameworks, then the app) because each outer
# signature seals the signatures of the code it contains.
#
# Usage:
#   MACOS_SIGN_IDENTITY="Developer ID Application: <Team> (<TEAMID>)" \
#     scripts/sign_macos_app.sh <path to .app>

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "usage: $0 <path to .app>" >&2
  exit 64
fi

: "${MACOS_SIGN_IDENTITY:?Set MACOS_SIGN_IDENTITY to the Developer ID Application identity (see docs/macos-release-signing.md)}"

APP="${1%/}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_ENTITLEMENTS="$REPO_ROOT/macos/Runner/Release.entitlements"
CLI_ENTITLEMENTS="$REPO_ROOT/macos/Runner/VFXCore.entitlements"
CLI_DIR="$APP/Contents/Resources/VFXCore"
CLI_BINARY="$CLI_DIR/VerifiedXCore"

fail() {
  echo "error: $1" >&2
  exit 1
}

is_macho() {
  local file_type
  file_type="$(file -b "$1")"
  [[ "$file_type" == *"Mach-O"* ]]
}

sign() {
  codesign --force --timestamp --options runtime --sign "$MACOS_SIGN_IDENTITY" "$@"
}

team_of() {
  codesign --display --verbose=2 "$1" 2>&1 | sed -n 's/^TeamIdentifier=//p'
}

require_hardened_runtime() {
  local signature
  signature="$(codesign --display --verbose=2 "$1" 2>&1)"
  [[ "$signature" == *"flags="*"runtime"* ]] \
    || fail "hardened runtime is not enabled on $1"
}

[ -d "$APP" ] || fail "app bundle not found: $APP"
[ -f "$CLI_BINARY" ] || fail "Core CLI not found at $CLI_BINARY; copy it into the bundle before signing"
[ -f "$APP_ENTITLEMENTS" ] || fail "missing $APP_ENTITLEMENTS"
[ -f "$CLI_ENTITLEMENTS" ] || fail "missing $CLI_ENTITLEMENTS"

# codesign treats everything in Contents/MacOS as code. Data files there get
# their signature stored in extended attributes, which a disk image or zip
# drops, so the bundle fails Gatekeeper on the user's machine.
while IFS= read -r -d '' entry; do
  if [ -d "$entry" ] || ! is_macho "$entry"; then
    fail "$entry is not an executable; Contents/MacOS must hold only code, move data to Contents/Resources"
  fi
done < <(find "$APP/Contents/MacOS" -mindepth 1 -maxdepth 1 -print0)

# Finder metadata and quarantine flags make codesign reject the bundle.
xattr -cr "$APP"

echo "Signing Core CLI payload"
while IFS= read -r -d '' payload_file; do
  if [ "$payload_file" != "$CLI_BINARY" ] && is_macho "$payload_file"; then
    sign "$payload_file"
  fi
done < <(find "$CLI_DIR" -type f -print0)
sign --entitlements "$CLI_ENTITLEMENTS" "$CLI_BINARY"

echo "Signing frameworks"
while IFS= read -r -d '' framework_item; do
  sign "$framework_item"
done < <(find "$APP/Contents/Frameworks" -depth \( -name "*.framework" -o -name "*.dylib" \) -print0)

echo "Signing app"
sign --entitlements "$APP_ENTITLEMENTS" "$APP"

echo "Verifying"
codesign --verify --deep --strict --verbose=2 "$APP"

# --deep checks code in Contents/Resources only as sealed files, not as code,
# so every binary is verified on its own. Each must carry the app's team: the
# notary service rejects a mixed or unsigned binary, and library validation
# refuses to load one at launch.
app_team="$(team_of "$APP")"
[ -n "$app_team" ] || fail "$MACOS_SIGN_IDENTITY did not produce a team-signed bundle"
binary_count=0
while IFS= read -r -d '' bundle_file; do
  if is_macho "$bundle_file"; then
    codesign --verify --strict "$bundle_file"
    [ "$(team_of "$bundle_file")" = "$app_team" ] \
      || fail "$bundle_file is not signed by team $app_team"
    binary_count=$((binary_count + 1))
  fi
done < <(find "$APP" -type f -print0)
echo "$binary_count binaries signed by team $app_team"

require_hardened_runtime "$APP"
require_hardened_runtime "$CLI_BINARY"

echo "Signed $APP as $MACOS_SIGN_IDENTITY"
