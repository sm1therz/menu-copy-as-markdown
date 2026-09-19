#!/usr/bin/env bash
# Saves the preset as it is right now in the running BetterTouchTool over the
# copy in preset/, then re-extracts src/ so the repo matches what BTT runs.
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="$PWD/preset/Menu - Text-Selection.bttpreset"
osascript -e "tell application \"BetterTouchTool\" to export_preset \"Menu - Text-Selection V1.11\" outputPath \"$OUT\" compress false includeSettings false" >/dev/null
sleep 1
jq -e '.BTTPresetContent' "$OUT" >/dev/null && echo "exported to $OUT"
scripts/extract-from-preset.sh
