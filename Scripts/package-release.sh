#!/usr/bin/env bash
set -euo pipefail

# Builds the universal release archive and its SHA-256 checksum in build/release.
#
# Signing modes:
#   TEMPLATE_APP_RELEASE_SIGNING=adhoc  Ad hoc signing without notarization.
# Add Developer ID signing and notarization here once you have a certificate.
# Without a mode the script refuses, so an unnotarized archive is deliberate.

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [[ "${TEMPLATE_APP_RELEASE_SIGNING:-}" != "adhoc" ]]; then
  echo "Set TEMPLATE_APP_RELEASE_SIGNING=adhoc for an unnotarized release." >&2
  exit 1
fi
VERSION="$(tr -d '[:space:]' <"$ROOT/VERSION")"
OUTPUT="$ROOT/build/release"
ARCHIVE="TemplateApp-$VERSION-macos-universal.zip"
APP_PATH="$("$ROOT/Scripts/build.sh" --universal | tail -1)"
rm -rf "$OUTPUT"
mkdir -p "$OUTPUT"
ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$OUTPUT/$ARCHIVE"
(cd "$OUTPUT" && shasum -a 256 "$ARCHIVE" >"$ARCHIVE.sha256")
printf '%s\n' "$OUTPUT/$ARCHIVE"
