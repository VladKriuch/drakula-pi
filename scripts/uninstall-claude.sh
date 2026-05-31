#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/.claude"

for item in CLAUDE.md settings.json skills system-prompt.md; do
  [ -L "$TARGET/$item" ] && rm "$TARGET/$item" && echo "$item → removed"
done

MARKER="# drakula-pi"
SHELL_RC="$HOME/.zshrc"

if grep -qF "$MARKER" "$SHELL_RC" 2>/dev/null; then
  sed -i '' "/$MARKER/,+1d" "$SHELL_RC"
  echo "alias → removed from .zshrc"
fi
