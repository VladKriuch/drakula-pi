#!/usr/bin/env bash
set -euo pipefail

CONFIG="$(cd "$(dirname "$0")/../claude" && pwd)"
TARGET="$HOME/.claude"

mkdir -p "$TARGET"

for item in CLAUDE.md settings.json skills; do
  [ ! -e "$CONFIG/$item" ] && continue
  ln -sf "$CONFIG/$item" "$TARGET/$item"
  echo "$item → linked"
done
