# menu-copy-as-markdown

A floating web view inside BetterTouchTool (BTT) that copies the current text selection as Markdown, optionally wrapped in a Markdown block quote.

## Agent skills

### Issue tracker

Issues live in Linear, team `RSM`, project `btt-menu-copy-as-markdown`. See `docs/agents/issue-tracker.md`.

### Triage labels

The five default triage labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`) plus the workspace's `Bug` / `Feature` / `Improvement` category labels. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` at the repo root and ADRs in `docs/adr/`. See `docs/agents/domain.md`.

## Where the source is

The deliverable is BTT configuration, not an app. `preset/Menu - Text-Selection.bttpreset` is what BTT imports; `src/*.js` are the scripts inside it, extracted with `scripts/extract-from-preset.sh`. Read `docs/btt-structure.md` before touching anything: it maps the activation group, triggers, menus, items and UUIDs.

BTT is closed source. There is no code to grep for how `get_selection` or floating menus work; use the docs at https://docs.folivora.ai/ (Context7 has them indexed) and the forum at https://community.folivora.ai/.
