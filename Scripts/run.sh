#!/usr/bin/env bash
set -euo pipefail

# Builds the app and opens a new instance with any arguments passed through.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_PATH="$("$ROOT/Scripts/build.sh" | tail -1)"
open -n "$APP_PATH" --args "$@"
