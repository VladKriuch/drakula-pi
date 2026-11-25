#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/link.sh"

TARGET="$HOME/.pi/agent"

for item in AGENTS.md skills extensions; do
  unlink_if_link "$TARGET/$item"
done
