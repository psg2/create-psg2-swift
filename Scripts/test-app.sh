#!/usr/bin/env bash
set -euo pipefail

# Checks the built bundle through its public surface: signature, icon, plist
# version and the --version command-line contract.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="${1:-$ROOT/build/Template App.app}"
EXECUTABLE="$APP/Contents/MacOS/TemplateApp"
VERSION="$(tr -d '[:space:]' <"$ROOT/VERSION")"

codesign --verify --deep --strict "$APP"
test -s "$APP/Contents/Resources/AppIcon.icns"
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist")" = "$VERSION"
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$APP/Contents/Info.plist")" = "$VERSION"
test "$("$EXECUTABLE" --version)" = "$VERSION"

# The binary's minimum macOS must match the plist, and a universal build must
# hold both architectures.
MINIMUM="$(/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' "$APP/Contents/Info.plist")"
ARCHITECTURES="$(lipo -archs "$EXECUTABLE")"
for architecture in $ARCHITECTURES; do
  minos="$(vtool -arch "$architecture" -show-build "$EXECUTABLE" | awk '$1 == "minos" {print $2; exit}')"
  test "$minos" = "$MINIMUM" || {
    echo "$architecture targets macOS $minos, but Info.plist says $MINIMUM" >&2
    exit 1
  }
done
if [[ "${EXPECT_UNIVERSAL:-}" == 1 ]]; then
  [[ " $ARCHITECTURES " == *" arm64 "* && " $ARCHITECTURES " == *" x86_64 "* ]] || {
    echo "Expected a universal binary, got: $ARCHITECTURES" >&2
    exit 1
  }
fi
echo "App bundle checks passed"
