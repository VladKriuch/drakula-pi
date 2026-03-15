#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/.pi/agent"

for item in AGENTS.md settings.json extensions skills prompts; do
  [ -L "$TARGET/$item" ] && rm "$TARGET/$item" && echo "$item → removed"
done
