# Agile-Ledger (plugin)

Plain-Markdown Scrum/Agile product management for Claude Code. The rules live in
`skills/agile-ledger/SKILL.md`; the commands below delegate to it. State is stored in an `Agile-Ledger/`
folder in your project — plain Markdown, no database. Read in the Markdown preview (IDs are clickable
links); make changes through the commands.

## Commands

**Capture**
- `/idea <text>` — drop a raw idea into `Ideas.md` (instant, any language, safe mid-work)
- `/bug <text>` — drop a raw bug report into the `Bugs.md` inbox (instant)

**Triage (inbox → registered)**
- `/triage` — promote ideas into epics / stories; new epics also get a few suggested Draft stories
- `/triage-bug` — register inbox bugs with ID, severity, and priority

**Shape the backlog**
- `/detail-us <US-ID>` — detail one story to Ready (As-a/I-want/So-that + Gherkin AC + estimate + deps)
- `/detail-epic <EPIC-ID>` — detail every story under an epic
- `/create-task <US-ID>` — *(optional)* add a task for an FE/BE split or unplanned sub-work
- `/find-bug <BUG-ID>` — read-only investigation; fills repro / expected / actual / assessment
- `/refine` — INVEST / Definition-of-Ready / vertical-slice / dependency / broken-link checks (report only)

**Plan & run the sprint**
- `/plan-sprint` — propose a Goal, pull Ready stories **and** high-priority bugs within velocity, build the board
- `/start-us <US-ID>` — dependency-gate, To Do → In Progress, offer the branch
- `/start-bug <BUG-ID>` — To Do → In Progress for a bug, offer the branch
- `/review <US-ID | BUG-ID>` — In Progress → In Review (verify on branch, no PR yet)
- `/pr <US-ID | BUG-ID>` — In Review → In PR (PR body filled from the ledger)
- `/done-us <US-ID>` — In PR → Done (gated by DoD + AC), record into the Increment
- `/done-bug <BUG-ID>` — In PR → Fixed, record into the Increment
- `/close-sprint` — record Increment + velocity, return unfinished items to the backlog

**Inspect (read-only views)**
- `/board` *(alias `/standup`)* — the async sprint snapshot
- `/my-work [name]` — one developer's stories, AC, branch, blockers
- `/status` — whole-product snapshot (states, sprint, velocity, open bugs, unreleased, version)
- `/roadmap` — epics grouped by target version, with rollups
- `/guide` — the command-to-file map + a one-glance state summary
- `/ledger-check` — audit all files for drift and broken links
- `/sync-main` — reconcile git `main` vs. the ledger (what merged while you were away)

**Release & communicate**
- `/release [version]` — cut a Major.Minor version from the Increment
- `/changelog` — derive release notes (Added/Changed + Fixed)

**Workspace — optional multi-repo orchestrator** *(phase 2)*
- `/init-workspace` — set up the orchestrator (Registry + Config) at a workspace root
- `/discover-repos` — detect new repos locally **and** on your GitHub org; propose clone + bootstrap
- `/bootstrap-repo <path> [--from-git]` — onboard one repo; optionally seed proposed drafts from git history
- `/workspace-sync` — one-command "what changed while I was away" across every managed repo
- `/workspace-status` — dashboard across all managed repos

The Workspace layer never replaces the per-repo ledger — each repo keeps its own `Agile-Ledger/` as the
source of truth. It only discovers, syncs, and *proposes* (cloning, committing, and reconstructed
backlog drafts are always confirmed first; it never pushes, opens PRs, or merges). See
`skills/agile-ledger-workspace/SKILL.md`.

Several read-only commands (`/board`, `/status`, `/roadmap`, `/guide`, `/my-work`, `/changelog`) declare
`allowed-tools` so they physically cannot modify files; `/find-bug` and `/sync-main` are likewise
restricted from executing arbitrary shell. Installed via a marketplace, commands are namespaced
(e.g. `/agile-ledger:idea`, `/agile-ledger:workspace-sync`).

## Files it manages

`Agile-Ledger/Ideas.md` · `Epic-Backlog.md` · `User-Stories.md` · `Bugs.md` · `Sprint.md` ·
`Sprints-History.md` · `Releases.md` · `Definitions.md`. Edit `Definitions.md` to configure language,
estimation scale, your name, and git execution.

See the repository README for install options and `SKILL.md` for the full rules.
