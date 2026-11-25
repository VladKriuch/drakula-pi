#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/link.sh"

TARGET="$HOME/.pi/agent"

mkdir -p "$TARGET"

link "$COMMON/AGENTS.md" "$TARGET/AGENTS.md"
link "$COMMON/skills" "$TARGET/skills"
link "$REPO/pi/extensions" "$TARGET/extensions"
