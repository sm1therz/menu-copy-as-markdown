# menu-copy-as-markdown

A floating menu inside BetterTouchTool (BTT) that appears when you select text in the Claude desktop app. Two buttons:

- **Markdown**: copy the selection to the clipboard as Markdown.
- **Quoted**: the same Markdown, every line prefixed with `> ` (a Markdown block quote).

## Layout

| Path | What it is |
| --- | --- |
| `preset/Menu - Text-Selection.bttpreset` | The deliverable. Import it into BTT. Everything BTT needs is in here. |
| `src/copy-as-markdown.js` | The JavaScript BTT runs for the Markdown button, extracted from the preset. |
| `src/copy-as-markdown-quoted.js` | Same for the Quoted button. |
| `scripts/export-from-btt.sh` | Saves the preset from the running BTT into `preset/` and refreshes `src/`. |
| `scripts/push-to-btt.sh` | The other direction: puts `src/*.js` into the running BTT. |
| `scripts/extract-from-preset.sh` | Refreshes `src/` from the preset file. |
| `scripts/verify-live.sh` | End-to-end check of both buttons in the running BTT. Prints PASS or RED. Keep your hands off the mouse for ten seconds while it runs. |
| `test/` | Tests of the two scripts outside BTT: `node --test test/converter.test.mjs`. |
| `docs/research/` | Local only, not in git: digests of past sessions. |
| `docs/btt-structure.md` | Map of what is inside the preset: activation group, triggers, menus, items, UUIDs. |
| `CONTEXT.md`, `docs/adr/` | Glossary and decisions (created as they are made). |
| `docs/agents/` | Where issues live (Linear) and how agents should read this repo. |

## Working on it

- Changed a script in `src/`? Run the tests, then `scripts/push-to-btt.sh`, then `scripts/verify-live.sh`, then `scripts/export-from-btt.sh`.
- Changed something inside BTT? Run `scripts/export-from-btt.sh`, then `scripts/verify-live.sh`.
- Commit `preset/` and `src/` together.

Issues are tracked in Linear, project `btt-menu-copy-as-markdown`.
