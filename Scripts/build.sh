#!/usr/bin/env bash
set -euo pipefail

# Builds build/<App>.app with SwiftPM, stamps VERSION into the versioned
# Info.plist, adds the icon and signs it ad hoc.
#   --universal  Apple Silicon and Intel in one binary
#   --install    Also copy the app to ~/Applications

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="Template App"
EXECUTABLE="TemplateApp"
BUNDLE_IDENTIFIER="com.psg2.template-app"
MINIMUM_MACOS="14.0"

UNIVERSAL=false
INSTALL=false
for argument in "$@"; do
  case "$argument" in
    --universal) UNIVERSAL=true ;;
    --install) INSTALL=true ;;
    *)
      echo "Usage: $0 [--universal] [--install]" >&2
      exit 2
      ;;
  esac
done

VERSION="$(tr -d '[:space:]' <"$ROOT/VERSION")"
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
  echo "VERSION must look like 1.2.3." >&2
  exit 1
}

mkdir -p "$ROOT/build"
STAGING="$(mktemp -d "$ROOT/build/.app-build.XXXXXX")"
trap 'rm -rf "$STAGING"' EXIT
APP="$STAGING/$APP_NAME.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

ARCHITECTURES=("$(uname -m)")
if $UNIVERSAL; then ARCHITECTURES=(arm64 x86_64); fi
BINARIES=()
for architecture in "${ARCHITECTURES[@]}"; do
  TRIPLE="$architecture-apple-macosx$MINIMUM_MACOS"
  SCRATCH="$ROOT/.build/release-$architecture"
  swift build --package-path "$ROOT" --scratch-path "$SCRATCH" -c release --product "$EXECUTABLE" --triple "$TRIPLE" >&2
  BIN_DIR="$(swift build --package-path "$ROOT" --scratch-path "$SCRATCH" -c release --triple "$TRIPLE" --show-bin-path)"
  BINARIES+=("$BIN_DIR/$EXECUTABLE")
  # SwiftPM resource bundles, if a target declares resources.
  for bundle in "$BIN_DIR"/*.bundle; do
    [[ -d "$bundle" && ! -d "$APP/Contents/Resources/$(basename "$bundle")" ]] || continue
    ditto "$bundle" "$APP/Contents/Resources/$(basename "$bundle")"
  done
done
if $UNIVERSAL; then
  lipo -create "${BINARIES[@]}" -output "$APP/Contents/MacOS/$EXECUTABLE"
else
  cp "${BINARIES[0]}" "$APP/Contents/MacOS/$EXECUTABLE"
fi

cp "$ROOT/Resources/Info.plist" "$APP/Contents/Info.plist"
plutil -replace CFBundleShortVersionString -string "$VERSION" "$APP/Contents/Info.plist"
plutil -replace CFBundleVersion -string "$VERSION" "$APP/Contents/Info.plist"

ICONSET="$STAGING/AppIcon.iconset"
mkdir -p "$ICONSET"
for size in 16 32 128 256 512; do
  sips -z "$size" "$size" "$ROOT/Resources/AppIcon.png" --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
  sips -z $((size * 2)) $((size * 2)) "$ROOT/Resources/AppIcon.png" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"

codesign --force --sign - "$APP" >&2
codesign --verify --deep --strict "$APP"

# Replace an earlier build or install only when it is this app.
replace() {
  local target="$1"
  if [[ -e "$target" ]]; then
    local identifier
    identifier="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$target/Contents/Info.plist" 2>/dev/null || true)"
    [[ "$identifier" == "$BUNDLE_IDENTIFIER" ]] || {
      echo "$target is another app; leaving it in place." >&2
      exit 1
    }
    rm -rf -- "$target"
  fi
}
FINAL="$ROOT/build/$APP_NAME.app"
replace "$FINAL"
mv "$APP" "$FINAL"
if $INSTALL; then
  mkdir -p "$HOME/Applications"
  replace "$HOME/Applications/$APP_NAME.app"
  ditto "$FINAL" "$HOME/Applications/$APP_NAME.app"
fi
printf '%s\n' "$FINAL"
