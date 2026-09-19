# Issue tracker: Linear

Issues and specs for this repo live in Linear, inside one project. Use the Linear MCP tools (`mcp__<linear-server>__*`) for all operations. The `gh` CLI is only for code (branches, PRs); never create GitHub issues.

## Where

- **Workspace**: robertsmith (https://linear.app/robertsmith)
- **Team**: `RSM` (id `9dd22459-9250-4082-a3f2-350a21614192`)
- **Project**: `btt-menu-copy-as-markdown` (id `8e94918f-88dc-4267-8e6e-970fa3ee3ba1`, https://linear.app/robertsmith/project/btt-menu-copy-as-markdown-d538324c3409)

Every issue created for this repo must be in team `RSM` and project `btt-menu-copy-as-markdown`.

## Conventions

- **Create an issue**: `save_issue` with `team: "RSM"`, `project: "btt-menu-copy-as-markdown"`, `title`, `description` (Markdown, real newlines).
- **Read an issue**: `get_issue` with the identifier (e.g. `RSM-12`); `list_comments` for the thread.
- **List issues**: `list_issues` with `project: "btt-menu-copy-as-markdown"`, plus `state`, `label`, `assignee` filters as needed.
- **Comment on an issue**: `save_comment` with `issueId`.
- **Apply / remove labels**: `save_issue` with `addLabels` / `removeLabels` (label names). Labels live at the workspace level; create a missing one with `create_issue_label`.
- **Close**: `save_issue` with `state: "Done"` (or `"Canceled"` for wontfix), then `save_comment` with the reason.
- **Categories**: use the existing workspace labels `Bug`, `Feature`, `Improvement` for the category roles (`bug` → `Bug`, `enhancement` → `Feature` or `Improvement`).

## Pull requests as a triage surface

**PRs as a request surface: no.** GitHub PRs on `sm1therz/menu-copy-as-markdown` are code only; they are not read as feature requests.

## When a skill says "publish to the issue tracker"

Create a Linear issue in team `RSM`, project `btt-menu-copy-as-markdown`.

## When a skill says "fetch the relevant ticket"

`get_issue` with the identifier, then `list_comments`.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a single issue with **sub-issues** as tickets.

- **Map**: one issue labelled `wayfinder:map`, holding the Notes / Decisions-so-far / Fog body.
- **Child ticket**: a sub-issue of the map (`save_issue` with `parentId: <map identifier>`). Labels: `wayfinder:<type>` (`research` / `prototype` / `grilling` / `task`). Once claimed, assign to the driving dev.
- **Blocking**: Linear's native relations. `save_issue` with `blockedBy: [<blocker identifier>]` on the child. A ticket is unblocked when every blocker is Done or Canceled.
- **Frontier query**: `list_issues` with `parentId: <map>`, state not Done/Canceled; drop any with an open blocker (`get_issue` shows relations) or an assignee; first in map order wins.
- **Claim**: `save_issue` with `assignee: "me"`, the session's first write.
- **Resolve**: `save_comment` with the answer, `save_issue` with `state: "Done"`, then append a context pointer to the map's Decisions-so-far via `save_issue` `patch`.
