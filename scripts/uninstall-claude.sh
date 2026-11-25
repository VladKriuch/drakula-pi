#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/link.sh"

TARGET="$HOME/.claude"

for item in CLAUDE.md settings.json system-prompt.md hooks; do
  unlink_if_link "$TARGET/$item"
done

for skill in "$COMMON/skills"/*/; do
  unlink_if_link "$TARGET/skills/$(basename "$skill")"
done

MARKER="# drakula-pi"
SHELL_RC="$HOME/.zshrc"

if grep -qF "$MARKER" "$SHELL_RC" 2>/dev/null; then
  sed -i '' "/$MARKER/,+1d" "$SHELL_RC"
  echo "alias → removed from .zshrc"
fi
