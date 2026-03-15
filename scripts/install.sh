#!/usr/bin/env bash
set -euo pipefail

CONFIG="$(cd "$(dirname "$0")/../config" && pwd)"
TARGET="$HOME/.pi/agent"

mkdir -p "$TARGET"

for item in AGENTS.md settings.json extensions skills prompts; do
  [ ! -e "$CONFIG/$item" ] && continue
  ln -sf "$CONFIG/$item" "$TARGET/$item"
  echo "$item → linked"
done
