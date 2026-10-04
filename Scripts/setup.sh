#!/usr/bin/env bash
set -euo pipefail

# create-psg2-swift: turns this template into your app.
#
#   gh repo create psg2/my-app --template psg2/create-psg2-swift --private --clone
#   cd my-app
#   ./Scripts/setup.sh
#
# It asks for the app's display name, bundle identifier and GitHub repository,
# then renames every placeholder (Template App, TemplateApp, template-app,
# TEMPLATE_APP, the bundle identifier and the repository), commits the result,
# installs the tools and runs the checks. A copy made from the template keeps
# its repository and remote. A plain clone of create-psg2-swift starts a fresh
# Git history instead. Pass the answers as arguments to skip the prompts:
#
#   ./Scripts/setup.sh "My App" com.example.my-app psg2/my-app

cd "$(dirname "$0")/.."

# Run once: the renames below can't be applied twice.
[[ -d Sources/TemplateApp && -f docs/APP_README.md ]] || {
  echo "This copy is already set up." >&2
  exit 1
}

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

DEFAULT_REPOSITORY="psg2/$SLUG"
REPOSITORY="${3:-}"
if [[ -z "$REPOSITORY" ]]; then
  read -rp "GitHub repository [$DEFAULT_REPOSITORY]: " REPOSITORY
  REPOSITORY="${REPOSITORY:-$DEFAULT_REPOSITORY}"
fi
if [[ ! "$REPOSITORY" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]; then
  echo "The repository should look like owner/name." >&2
  exit 1
fi

echo "Display name: $DISPLAY_NAME"
echo "Swift name:   $SWIFT_NAME (${SWIFT_NAME}Core, ${SWIFT_NAME}CoreTests)"
echo "Slug:         $SLUG"
echo "Bundle ID:    $BUNDLE_IDENTIFIER"
echo "Env prefix:   ${ENV_PREFIX}_"
echo "Repository:   $REPOSITORY"

# Most specific placeholders first: the bundle identifier contains the slug.
find . -type f -not -path './.git/*' -not -path './.build/*' -not -path './build/*' | while IFS= read -r file; do
  case "$file" in *.png | *.icns) continue ;; esac
  LC_ALL=C sed -i '' \
    -e "s#psg2/template-app#$REPOSITORY#g" \
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
rm -f Scripts/setup.sh

# A plain clone of the template still points at create-psg2-swift: start over.
ORIGIN="$(git remote get-url origin 2>/dev/null || true)"
case "$ORIGIN" in
  "" | *[/:]psg2/create-psg2-swift | *[/:]psg2/create-psg2-swift.git)
    rm -rf .git
    git init -q -b main
    ;;
esac
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
