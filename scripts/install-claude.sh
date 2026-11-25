#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/link.sh"

TARGET="$HOME/.claude"

# skills/ is a real folder because the Claude app writes its synced skills into it
mkdir -p "$TARGET/skills"

link "$COMMON/AGENTS.md" "$TARGET/CLAUDE.md"

for item in settings.json system-prompt.md hooks; do
  link "$REPO/claude/$item" "$TARGET/$item"
done

for skill in "$COMMON/skills"/*/; do
  skill="${skill%/}"
  link "$skill" "$TARGET/skills/$(basename "$skill")"
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
