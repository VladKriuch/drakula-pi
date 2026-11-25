#!/usr/bin/env bash

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMMON="$REPO/common"

link() {
  local source="$1"
  local target="$2"
  [ ! -e "$source" ] && return

  if [ -L "$target" ]; then
    rm "$target"
  elif [ -e "$target" ]; then
    echo "$target → not linked: already exists" >&2
    exit 1
  fi

  ln -s "$source" "$target"
  echo "$target → linked"
}

unlink_if_link() {
  local target="$1"

  if [ -L "$target" ]; then
    rm "$target"
    echo "$target → removed"
  fi
}
