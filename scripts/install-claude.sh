#!/usr/bin/env bash
set -euo pipefail

CONFIG="$(cd "$(dirname "$0")/../claude" && pwd)"
TARGET="$HOME/.claude"

mkdir -p "$TARGET"

for item in CLAUDE.md settings.json skills system-prompt.md; do
  [ ! -e "$CONFIG/$item" ] && continue
  ln -sf "$CONFIG/$item" "$TARGET/$item"
  echo "$item → linked"
done

ALIAS_LINE="alias claude='claude --system-prompt-file ~/.claude/system-prompt.md'"
MARKER="# drakula-pi"
SHELL_RC="$HOME/.zshrc"

if ! grep -qF "$MARKER" "$SHELL_RC" 2>/dev/null; then
  printf '\n%s\n%s\n' "$MARKER" "$ALIAS_LINE" >> "$SHELL_RC"
  echo "alias → added to .zshrc"
else
  echo "alias → already in .zshrc"
fi
