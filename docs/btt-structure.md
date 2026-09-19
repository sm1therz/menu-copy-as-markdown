# What is inside the preset

Verified 2026-09-19 against the running BetterTouchTool 6.726. `preset/Menu - Text-Selection.bttpreset` was exported from it the same day, after the fix described at the bottom.

## The pieces, top down

**Preset** `Menu - Text-Selection V1.11`
Started from the shared preset "text-selection-menu-v1.11" on share.folivora.ai (a copy of the original is in `~/Downloads/text-selection-base/presetjson.bttpreset`). Everything below except the four items marked *ours* comes from that base.

**Conditional Activation Group** `TextSelectionMenu`
Condition: front app bundle id is `com.anthropic.claudefordesktop` (the Claude desktop app) and is not `org.blenderfoundation.blender`. It never activates in Terminal, so the Claude Code CLI is outside the current config.

Inside the group:

- **Trigger "Text Selection Did Change"** (type 806): the base preset's mechanism. When the selection changes it updates the floating menu's properties and shows it.
- **Trigger "Leftclick" with min press time** (type 1000): shows the floating menu after a long click, via an If Condition.
- **Floating Menu `text-selection`** (UUID `FDEC992A-…`): the base preset's 32-item menu. Disabled (`BTTEnabled: 0`).
- **Floating Menu `no-text-selection`** and **`no-text-selection-modified`**: base preset, disabled.
- **Floating Menu `text-selection-modified`** (UUID `7B9EC08A-8B74-4613-A52C-2F00A7561951`) *ours*: the live menu. Two standard items (not a web view):
  - **Item "Markdown"** (`Menu Item: CopyAsMarkdown`, UUID `624FAE36-…`, SF symbol `m.square`). Action: Trigger Named Trigger → `Claude Code > Copy as Markdown`.
  - **Item "Quoted"** (`Menu Item: CopyAsMarkdownQuoted`, UUID `BE209364-…`, SF symbol `text.quote`). Action: Trigger Named Trigger → `Claude Code > Copy as Markdown (Quoted)`.

Outside the group, in **Global**:

- **Named trigger `Claude Code > Copy as Markdown`** (UUID `03ED467F-…`) *ours*: one action, Run Real JavaScript. Source: `src/copy-as-markdown.js`.
- **Named trigger `Claude Code > Copy as Markdown (Quoted)`** (UUID `35B3C294-…`) *ours*: same, source `src/copy-as-markdown-quoted.js`. The only difference is one line that prefixes every output line with `> `.

## How a copy happens

1. BTT's `get_selection({format:'public.html'})` asks the front app for the selection as HTML.
2. If that comes back empty, the script returns "No selection" to BTT and stops. Nothing reaches the clipboard and nothing is shown to the user.
3. A hand-written set of regular expressions turns the HTML into Markdown (code blocks, headings, block quotes, lists, bold, italic, strikethrough, links, images).
4. `set_clipboard_content({content: md, format: 'NSPasteboardTypeString'})` puts the Markdown on the clipboard as plain text.

No Cmd+C is sent, the clipboard is never read, and no shell or Node process is involved.

## Leftovers on disk that the preset does not use

- `~/Library/Application Support/BetterTouchTool/MDWV/mdwv.html`: an earlier web-view approach using Turndown.
- `~/.local/share/cc-markdown-menu/html2md.js`: an earlier Node + Turndown converter.

## Environment (2026-09-15)

| Thing | Value |
| --- | --- |
| BetterTouchTool | 6.726, build 2026081403 |
| Claude desktop app | `com.anthropic.claudefordesktop` 1.52386.6, Electron 44.2.0 |
| Claude Code CLI | 2.1.272 at `~/.local/bin/claude` |
| Terminal apps installed | Apple Terminal only |

## Fix log

**2026-09-19: the Markdown button did nothing.**
Cause: the button had no action. Its "Trigger Named Trigger" action had been detached from it on 2026-08-31, when BTT was force-quit in the middle of an edit. The detached action is still in BTT's database with no parent; it is harmless and nothing references it.
Fix: attached a new "Trigger Named Trigger → Claude Code > Copy as Markdown" action to the button with `update_trigger` on the button's own UUID.
Also changed: both scripts now pass `format: 'NSPasteboardTypeString'` to `set_clipboard_content`, as the version confirmed working on 2026-08-29 did. Whether leaving it out breaks the copy on BTT 6.726 is not proven: the test runs that suggested so were disturbed by mouse use at the same time.
Proof: `scripts/verify-live.sh` went from RED to PASS for both buttons.
