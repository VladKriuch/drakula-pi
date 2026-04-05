#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/.claude"

for item in CLAUDE.md settings.json skills; do
  [ -L "$TARGET/$item" ] && rm "$TARGET/$item" && echo "$item → removed"
done
