#!/usr/bin/env bash
# Pushes src/*.js into the running BetterTouchTool, replacing the script inside
# each named trigger's "Run Real JavaScript" action. Updates the action in place
# by its own UUID, so nothing is re-created and nothing can be orphaned.
# Usage: scripts/push-to-btt.sh            (needs BTT running)
set -euo pipefail
cd "$(dirname "$0")/.."
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

push() { # $1 src file, $2 named-trigger uuid
  local src="$1" trigger="$2" action live
  action="$(osascript -e "tell application \"BetterTouchTool\" to get_trigger \"$trigger\"" | jq -r '.BTTActionsToExecute[0].BTTUUID')"
  jq -n --rawfile s "$src" '{BTTAdditionalActionData:{BTTScriptType:3,BTTAppleScriptUsePath:false,BTTScriptLocation:0,BTTAppleScriptRunInBackground:true,BTTScriptString:($s|rtrimstr("\n"))}}' > "$TMP/payload.json"
  osascript - "$TMP/payload.json" "$action" >/dev/null <<'OSA'
on run argv
  set j to read POSIX file (item 1 of argv) as «class utf8»
  tell application "BetterTouchTool" to update_trigger (item 2 of argv) json j
end run
OSA
  sleep 1
  live="$(osascript -e "tell application \"BetterTouchTool\" to get_trigger \"$trigger\"")"
  [ "$(jq '.BTTActionsToExecute|length' <<<"$live")" = 1 ] || { echo "FAIL $src: trigger no longer has exactly one action"; exit 1; }
  diff <(jq -r '.BTTActionsToExecute[0].BTTAdditionalActionData.BTTScriptString' <<<"$live") <(cat "$src") >/dev/null \
    && echo "ok   $src is now live in \"$(jq -r .BTTTriggerName <<<"$live")\"" \
    || { echo "FAIL $src: BTT's copy differs from the file after the push"; exit 1; }
}

push src/copy-as-markdown.js        03ED467F-B51E-4238-9EF5-6E8A151C07AA
push src/copy-as-markdown-quoted.js 35B3C294-B995-4E93-9C44-0C7A5CB185F6
