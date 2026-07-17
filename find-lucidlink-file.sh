#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Find LucidLink File
# @raycast.mode silent

# Optional parameters:
# @raycast.icon https://www.lucidlink.com/favicon.ico
# @raycast.argument1 { "type": "text", "placeholder": "lucid:// link (optional, reads clipboard if left blank)", "optional": true }
# @raycast.packageName LucidLink

# Documentation:
# @raycast.description Parses a LucidLink Classic direct link (typed in or read from clipboard), finds the matching file on the mounted volume (Spotlight can't index LucidLink filespaces, so this walks the filesystem directly), and reveals it in Finder.
# @raycast.author krabf

# --- CONFIG: change this to match your actual LucidLink mount point ---
MOUNT_ROOT="/Volumes/REPLACE_WITH_YOUR_FILESPACE_NAME"

LINK="$1"

# If no argument was typed/pasted, fall back to the clipboard
if [ -z "$LINK" ]; then
  LINK=$(pbpaste)
fi

if [ -z "$LINK" ]; then
  osascript -e 'display notification "No link provided and nothing found on clipboard." with title "Find LucidLink File"'
  exit 1
fi

if [ ! -d "$MOUNT_ROOT" ]; then
  osascript -e "display notification \"Mount not found at $MOUNT_ROOT. Check the filespace is connected.\" with title \"Find LucidLink File\""
  exit 1
fi

# Strip query string (e.g. ?reveal=true)
LINK_NO_QUERY="${LINK%%\?*}"

# Extract the last path segment, which is the filename
ENCODED_NAME="${LINK_NO_QUERY##*/}"

# URL-decode it (%20 -> space, %2E -> ., etc.)
DECODED_NAME=$(python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))" "$ENCODED_NAME")

RESULT=$(find "$MOUNT_ROOT" -iname "$DECODED_NAME" -print -quit 2>/dev/null)

if [ -z "$RESULT" ]; then
  osascript -e "display notification \"No match found for $DECODED_NAME\" with title \"Find LucidLink File\""
  exit 1
fi

open -R "$RESULT"
osascript -e "display notification \"Revealed: $DECODED_NAME\" with title \"Find LucidLink File\""
