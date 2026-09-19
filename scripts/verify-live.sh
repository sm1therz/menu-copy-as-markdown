#!/usr/bin/env bash
# Checks the two buttons in the running BetterTouchTool, end to end.
# For each button it: selects a test page in a browser, puts a marker on the
# clipboard, runs the actions BTT has attached to that button (the same thing
# a click does), then checks the clipboard now holds the expected Markdown.
# Your clipboard text is saved first and put back at the end.
# Usage: scripts/verify-live.sh            (needs BTT running)
set -uo pipefail
cd "$(dirname "$0")/.."
BROWSER="${BROWSER_APP:-Brave Browser}"
FIXTURE="$PWD/test/fixtures/selection.html"
MARKDOWN_ITEM="624FAE36-479E-47B0-8496-E2036B75C36F"   # button "Markdown"
QUOTED_ITEM="BE209364-7D37-4249-BBF3-8AC05C4B8996"     # button "Quoted"
MARKER="__verify_live_marker__"
fail=0
btt() { osascript -e "tell application \"BetterTouchTool\" to $1"; }

saved="$(pbpaste 2>/dev/null || true)"
open -a "$BROWSER" "$FIXTURE"; sleep 3

check() { # $1 label, $2 item uuid, $3 = "plain" | "quoted"
  local label="$1" uuid="$2" mode="$3" wired out
  wired="$(btt "get_trigger \"$uuid\"" | jq -r '[.BTTMenuItemActions[]? | .BTTNamedTriggerToTrigger // empty] | join(", ")')"
  if [ -z "$wired" ]; then echo "FAIL  $label: button has no action attached"; fail=1; else echo "ok    $label: button runs named trigger \"$wired\""; fi
  open -a "$BROWSER"; sleep 1
  printf '%s' "$MARKER" | pbcopy
  btt "execute_assigned_actions_for_trigger \"$uuid\"" >/dev/null 2>&1
  sleep 2
  out="$(pbpaste)"
  if [ "$out" = "$MARKER" ]; then echo "FAIL  $label: clicking copied nothing (clipboard unchanged)"; fail=1; return; fi
  local want='## Fixture Heading'; [ "$mode" = quoted ] && want='> ## Fixture Heading'
  if [ -z "$out" ]; then echo "FAIL  $label: the clipboard was changed but holds no plain text (0 bytes)"; fail=1; return; fi
  if [ "$(printf '%s\n' "$out" | head -1)" != "$want" ]; then echo "FAIL  $label: first line is not \"$want\" (clipboard holds ${#out} characters)"; fail=1; return; fi
  for needle in '**bold text**' '*italic text*' '`inline_code`' '[link label](https://example.com/page)' '- first bullet' '1. step one' '```' 'console.log(a);'; do
    printf '%s' "$out" | grep -qF -- "$needle" || { echo "FAIL  $label: output is missing $needle"; fail=1; }
  done
  if [ "$mode" = quoted ] && printf '%s\n' "$out" | grep -qv '^>'; then echo "FAIL  $label: some lines do not start with >"; fail=1; fi
  echo "ok    $label: clipboard holds the expected Markdown ($(printf '%s' "$out" | wc -l | tr -d ' ') lines)"
}

check "Markdown" "$MARKDOWN_ITEM" plain
check "Quoted"   "$QUOTED_ITEM"   quoted

printf '%s' "$saved" | pbcopy
[ $fail -eq 0 ] && echo "PASS" || echo "RED"
exit $fail
