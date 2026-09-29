#!/bin/bash
# Signs a disk image, submits it to Apple's notary service and staples the
# ticket, so Gatekeeper accepts the download without a network lookup.
#
# The app inside must already be signed with scripts/sign_macos_app.sh. The
# notarization covers every binary in the image, including the Core CLI.
#
# Usage:
#   MACOS_SIGN_IDENTITY="Developer ID Application: <Team> (<TEAMID>)" \
#   MACOS_NOTARY_PROFILE="<notarytool keychain profile>" \
#     scripts/notarize_macos.sh <path to .dmg>

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "usage: $0 <path to .dmg>" >&2
  exit 64
fi

: "${MACOS_SIGN_IDENTITY:?Set MACOS_SIGN_IDENTITY to the Developer ID Application identity (see docs/macos-release-signing.md)}"
: "${MACOS_NOTARY_PROFILE:?Set MACOS_NOTARY_PROFILE to the notarytool keychain profile (see docs/macos-release-signing.md)}"

DMG="$1"

fail() {
  echo "error: $1" >&2
  exit 1
}

[ -f "$DMG" ] || fail "disk image not found: $DMG"
case "$DMG" in
  *.dmg) ;;
  *) fail "expected a .dmg, got $DMG" ;;
esac

echo "Signing $DMG"
codesign --force --timestamp --sign "$MACOS_SIGN_IDENTITY" "$DMG"

echo "Submitting to the notary service (this usually takes a few minutes)"
submission="$(xcrun notarytool submit "$DMG" \
  --keychain-profile "$MACOS_NOTARY_PROFILE" \
  --wait \
  --output-format json)"

submission_id="$(printf '%s' "$submission" | plutil -extract id raw -o - -)"
submission_status="$(printf '%s' "$submission" | plutil -extract status raw -o - -)"

if [ "$submission_status" != "Accepted" ]; then
  echo "Notarization $submission_status for submission $submission_id. Notary log:" >&2
  xcrun notarytool log "$submission_id" --keychain-profile "$MACOS_NOTARY_PROFILE" >&2
  exit 1
fi

echo "Stapling ticket"
xcrun stapler staple "$DMG"
xcrun stapler validate "$DMG"

echo "Checking Gatekeeper"
spctl --assess --type open --context context:primary-signature --verbose=2 "$DMG"

echo "Notarized $DMG (submission $submission_id)"
