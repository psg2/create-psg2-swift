#!/usr/bin/env bash
set -euo pipefail

# create-psg2-swift: turns this template into your app.
#
#   git clone https://github.com/pgsereno/create-psg2-swift.git my-app
#   cd my-app
#   ./setup.sh
#
# It asks for the app's display name and bundle identifier, then renames every
# placeholder (Template App, TemplateApp, template-app, TEMPLATE_APP and the
# bundle identifier), restarts Git history, installs the tools and runs the
# checks. Pass the answers as arguments to skip the prompts:
#
#   ./setup.sh "My App" com.example.my-app

DEFAULT_NAME="$(basename "$PWD" | tr -- '-_' '  ' | awk '{for (i = 1; i <= NF; i++) printf "%s%s%s", (i > 1 ? " " : ""), toupper(substr($i, 1, 1)), substr($i, 2)}')"
DISPLAY_NAME="${1:-}"
if [[ -z "$DISPLAY_NAME" ]]; then
  read -rp "App name [$DEFAULT_NAME]: " DISPLAY_NAME
  DISPLAY_NAME="${DISPLAY_NAME:-$DEFAULT_NAME}"
fi
if [[ ! "$DISPLAY_NAME" =~ ^[A-Za-z][A-Za-z0-9\ ]*$ ]]; then
  echo "Use letters, digits and spaces, starting with a letter." >&2
  exit 1
fi

# "My App" -> MyApp, my-app, MY_APP
SWIFT_NAME="$(printf '%s' "$DISPLAY_NAME" | awk '{for (i = 1; i <= NF; i++) printf "%s%s", toupper(substr($i, 1, 1)), substr($i, 2)}')"
SLUG="$(printf '%s' "$DISPLAY_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
ENV_PREFIX="$(printf '%s' "$SLUG" | tr '[:lower:]-' '[:upper:]_')"

DEFAULT_BUNDLE="com.psg2.$SLUG"
BUNDLE_IDENTIFIER="${2:-}"
if [[ -z "$BUNDLE_IDENTIFIER" ]]; then
  read -rp "Bundle identifier [$DEFAULT_BUNDLE]: " BUNDLE_IDENTIFIER
  BUNDLE_IDENTIFIER="${BUNDLE_IDENTIFIER:-$DEFAULT_BUNDLE}"
fi
if [[ ! "$BUNDLE_IDENTIFIER" =~ ^[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$ ]]; then
  echo "The bundle identifier should look like com.example.my-app." >&2
  exit 1
fi

echo "Display name: $DISPLAY_NAME"
echo "Swift name:   $SWIFT_NAME (${SWIFT_NAME}Core, ${SWIFT_NAME}CoreTests)"
echo "Slug:         $SLUG"
echo "Bundle ID:    $BUNDLE_IDENTIFIER"
echo "Env prefix:   ${ENV_PREFIX}_"

# Most specific placeholders first: the bundle identifier contains the slug.
find . -type f -not -path './.git/*' -not -path './.build/*' -not -path './build/*' | while IFS= read -r file; do
  case "$file" in *.png | *.icns) continue ;; esac
  LC_ALL=C sed -i '' \
    -e "s/com\.psg2\.template-app/$BUNDLE_IDENTIFIER/g" \
    -e "s/Template App/$DISPLAY_NAME/g" \
    -e "s/TemplateApp/$SWIFT_NAME/g" \
    -e "s/template-app/$SLUG/g" \
    -e "s/TEMPLATE_APP/$ENV_PREFIX/g" \
    "$file"
done

mv "Sources/TemplateAppCore" "Sources/${SWIFT_NAME}Core"
mv "Sources/TemplateApp" "Sources/$SWIFT_NAME"
mv "Sources/$SWIFT_NAME/TemplateApp.swift" "Sources/$SWIFT_NAME/$SWIFT_NAME.swift"
mv "Tests/TemplateAppCoreTests" "Tests/${SWIFT_NAME}CoreTests"

# The template's own notes don't belong in the new app.
mv docs/APP_README.md README.md
rm -f setup.sh
sed -i '' -e 's/ setup\.sh"/"/' mise.toml

rm -rf .git
git init -q -b main
git add -A
git commit -q -m "Start $DISPLAY_NAME from create-psg2-swift"

if command -v mise >/dev/null; then
  mise trust -q
  mise install
  mise run hooks
  mise run ci
else
  echo "Install mise (https://mise.jdx.dev), then run: mise install && mise run hooks && mise run ci"
fi
echo "Done. Run the app with: mise run run"
