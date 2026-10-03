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
test "$("$EXECUTABLE" --version)" = "$VERSION"
echo "App bundle checks passed"
