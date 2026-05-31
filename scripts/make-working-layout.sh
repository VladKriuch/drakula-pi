#!/bin/bash
set -euo pipefail

DIR="$(pwd)"

# Get primary screen usable area in System Events (QuickDraw) coordinates
# Converts from Cocoa coords (origin bottom-left) to screen coords (origin top-left)
read -r SCREEN_X SCREEN_Y SCREEN_W SCREEN_H <<< "$(osascript -l JavaScript -e '
ObjC.import("AppKit");
var primary = $.NSScreen.screens.objectAtIndex(0);
var pf = primary.frame;
var vf = primary.visibleFrame;
var x = Math.round(vf.origin.x);
var y = Math.round(pf.size.height - vf.origin.y - vf.size.height);
var w = Math.round(vf.size.width);
var h = Math.round(vf.size.height);
x + " " + y + " " + w + " " + h;
')"

HALF_W=$((SCREEN_W / 2))
HALF_H=$((SCREEN_H / 2))

# Escape single quotes in path for AppleScript
ESCAPED_DIR="${DIR//\'/\'\\\'\'}"

# Set up Warp windows FIRST (before VS Code, which steals focus)
osascript <<EOF
tell application "Warp" to activate
delay 1

-- Claude window (top-left): resize BEFORE typing so Warp doesn't scroll
tell application "Warp" to activate
tell application "System Events" to tell process "Warp"
    keystroke "n" using command down
    delay 0.8
    set position of window 1 to {${SCREEN_X}, ${SCREEN_Y}}
    set size of window 1 to {${HALF_W}, ${HALF_H}}
    delay 0.3
    keystroke "k" using command down
    delay 0.2
    keystroke "cd '${ESCAPED_DIR}' && claude"
    key code 36
end tell

delay 0.5

-- Pi window (bottom-left): resize BEFORE typing so Warp doesn't scroll
tell application "Warp" to activate
tell application "System Events" to tell process "Warp"
    keystroke "n" using command down
    delay 0.8
    set position of window 1 to {${SCREEN_X}, $((SCREEN_Y + HALF_H))}
    set size of window 1 to {${HALF_W}, ${HALF_H}}
    delay 0.3
    keystroke "k" using command down
    delay 0.2
    keystroke "cd '${ESCAPED_DIR}' && pi"
    key code 36
end tell
EOF

# Open VS Code AFTER Warp is done (so it can't steal focus during keystroke input)
code "$DIR"
sleep 3

# Position VS Code
osascript <<EOF
tell application "System Events" to tell process "Code"
    set position of window 1 to {$((SCREEN_X + HALF_W)), ${SCREEN_Y}}
    set size of window 1 to {${HALF_W}, ${SCREEN_H}}
end tell
EOF

echo "Layout ready"
