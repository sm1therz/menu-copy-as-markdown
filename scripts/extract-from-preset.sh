#!/usr/bin/env bash
# Pull the editable JavaScript out of the BTT preset into src/.
# The preset is the deliverable BTT imports; src/ is what you read and edit.
# Usage: scripts/extract-from-preset.sh [path/to/preset.bttpreset]
set -euo pipefail
cd "$(dirname "$0")/.."
PRESET="${1:-preset/Menu - Text-Selection.bttpreset}"

extract() { # $1 = BTT named-trigger name, $2 = output file
  jq -r --arg t "$1" '
    .BTTPresetContent[] | .BTTTriggers[]
    | select(.BTTTriggerName == $t)
    | .BTTActionsToExecute[0].BTTAdditionalActionData.BTTScriptString
  ' "$PRESET" > "$2"
  echo "wrote $2 ($(wc -c < "$2" | tr -d ' ') bytes) from named trigger \"$1\""
}

extract "Claude Code > Copy as Markdown"          src/copy-as-markdown.js
extract "Claude Code > Copy as Markdown (Quoted)" src/copy-as-markdown-quoted.js
