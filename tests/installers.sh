#!/usr/bin/env bash
set -euo pipefail

SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT

REPO="$SANDBOX/repo"
HOME_DIR="$SANDBOX/home"

mkdir -p \
  "$REPO/scripts" \
  "$REPO/common/skills/example-skill" \
  "$REPO/claude/hooks" \
  "$REPO/pi/extensions" \
  "$HOME_DIR"

cp \
  scripts/link.sh \
  scripts/install.sh \
  scripts/install-claude.sh \
  scripts/uninstall.sh \
  scripts/uninstall-claude.sh \
  "$REPO/scripts/"
touch \
  "$REPO/common/AGENTS.md" \
  "$REPO/common/skills/example-skill/SKILL.md" \
  "$REPO/claude/settings.json" \
  "$REPO/claude/system-prompt.md"

assert_link() {
  local path="$1"
  local target="$2"

  if [ ! -L "$path" ] || [ "$(readlink "$path")" != "$target" ]; then
    echo "Expected $path to link to $target" >&2
    exit 1
  fi
}

assert_missing() {
  local path="$1"

  if [ -e "$path" ] || [ -L "$path" ]; then
    echo "Expected $path to not exist" >&2
    exit 1
  fi
}

echo "Testing repeated Pi installation"
HOME="$HOME_DIR" "$REPO/scripts/install.sh"
HOME="$HOME_DIR" "$REPO/scripts/install.sh"

assert_link "$HOME_DIR/.pi/agent/AGENTS.md" "$REPO/common/AGENTS.md"
assert_link "$HOME_DIR/.pi/agent/skills" "$REPO/common/skills"
assert_link "$HOME_DIR/.pi/agent/extensions" "$REPO/pi/extensions"
assert_missing "$REPO/common/skills/skills"
assert_missing "$REPO/pi/extensions/extensions"

echo "Testing Pi uninstallation"
HOME="$HOME_DIR" "$REPO/scripts/uninstall.sh"

assert_missing "$HOME_DIR/.pi/agent/AGENTS.md"
assert_missing "$HOME_DIR/.pi/agent/skills"
assert_missing "$HOME_DIR/.pi/agent/extensions"

echo "Testing repeated Claude installation"
mkdir -p "$HOME_DIR/.claude/skills/synced"
touch "$HOME_DIR/.claude/skills/synced/manifest.json"

HOME="$HOME_DIR" "$REPO/scripts/install-claude.sh"
HOME="$HOME_DIR" "$REPO/scripts/install-claude.sh"

assert_link "$HOME_DIR/.claude/CLAUDE.md" "$REPO/common/AGENTS.md"
assert_link "$HOME_DIR/.claude/settings.json" "$REPO/claude/settings.json"
assert_link "$HOME_DIR/.claude/system-prompt.md" "$REPO/claude/system-prompt.md"
assert_link "$HOME_DIR/.claude/hooks" "$REPO/claude/hooks"
assert_link "$HOME_DIR/.claude/skills/example-skill" "$REPO/common/skills/example-skill"
assert_missing "$REPO/common/skills/example-skill/example-skill"
assert_missing "$REPO/claude/hooks/hooks"

if [ -L "$HOME_DIR/.claude/skills" ]; then
  echo "Expected $HOME_DIR/.claude/skills to be a folder, not a link" >&2
  exit 1
fi

if [ "$(grep -c "# drakula-pi" "$HOME_DIR/.zshrc")" != "1" ]; then
  echo "Expected the claude alias to be added to .zshrc once" >&2
  exit 1
fi

echo "Testing Claude uninstallation"
HOME="$HOME_DIR" "$REPO/scripts/uninstall-claude.sh"

assert_missing "$HOME_DIR/.claude/CLAUDE.md"
assert_missing "$HOME_DIR/.claude/settings.json"
assert_missing "$HOME_DIR/.claude/system-prompt.md"
assert_missing "$HOME_DIR/.claude/hooks"
assert_missing "$HOME_DIR/.claude/skills/example-skill"

if [ ! -f "$HOME_DIR/.claude/skills/synced/manifest.json" ]; then
  echo "Expected skills that the Claude app synced to stay in place" >&2
  exit 1
fi

if grep -qF "# drakula-pi" "$HOME_DIR/.zshrc"; then
  echo "Expected the claude alias to be removed from .zshrc" >&2
  exit 1
fi

echo "Installer tests passed"
