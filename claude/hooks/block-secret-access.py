#!/usr/bin/env python3
"""PreToolUse hook: denies Bash commands that mention secret files or sops."""

from __future__ import annotations

import json
import re
import sys

SECRET_PATTERNS: dict[str, re.Pattern[str]] = {
    "sops": re.compile(r"(?<![\w.-])sops(?![\w.-])"),
    "a secrets file": re.compile(r"secrets[\w.-]*\.(?:ya?ml|json)\b"),
    "a .env file": re.compile(r"(?<!\w)\.env(?:\.[\w-]+)?(?!\w)"),
    "env.sh": re.compile(r"(?<![\w-])env\.sh\b"),
}


def matched_secret(command: str) -> str | None:
    for label, pattern in SECRET_PATTERNS.items():
        if pattern.search(command):
            return label
    return None


def main() -> None:
    payload = json.load(sys.stdin)
    command = payload.get("tool_input", {}).get("command", "")
    label = matched_secret(command)
    if label is None:
        return
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": (
                f"Blocked by block-secret-access hook: the command mentions {label}. "
                "Ask Vlad before reading or decrypting secrets."
            ),
        }
    }))


if __name__ == "__main__":
    main()
