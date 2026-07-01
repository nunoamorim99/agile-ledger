# Agile-Ledger Workspace — Spec (Phase 2, design-complete)

> Companion to `Agile-Ledger-skill-spec.md`. An **optional** orchestrator that sits one level above the
> per-repo skill, for the "install once, manage many" case. The per-repo Agile-Ledger is unchanged and
> remains the source of truth for each repository. Ships as a **second skill inside the same plugin**
> (`skills/agile-ledger-workspace/`), so installation is still one step and the core skill stays lean.

## 1. Problem it solves

A remote PM running many repos hits two blind spots, especially after time off: **repos created on the
host that nobody mentioned**, and **work merged to `main` that was never registered**. Going folder by
folder to find both is the pain. This layer makes it one command.

## 2. Architecture

```
<workspace-root>/
├── Agile-Ledger-Workspace/      # orchestrator: Registry.md + Config.md ONLY (never a backlog)
├── repo-a/  └─ Agile-Ledger/…   # per-repo ledger = source of truth, unchanged
└── repo-b/  └─ Agile-Ledger/…
```

The orchestrator discovers, sweeps, and *proposes*. Each repo's `Agile-Ledger/` is authoritative for
itself (so it can be committed there and shared with that repo's developers).

## 3. Locked decisions

| # | Decision | Choice |
|---|---|---|
| 1 | Discovery scope | **Local + org-level** via `gh repo list <org>` — needed to catch truly-new, uncloned repos |
| 2 | Onboard policy | **Always propose and wait for confirmation** before cloning/bootstrapping |
| 3 | Reconstruction | **Flag undocumented work, then follow the normal flow to validate** — propose as Inbox Drafts, human triages; never auto-register as truth |
| 4 | Ledger placement | Orchestrator **writes and (opt-in) commits locally on a setup branch**; the **user** pushes / opens the PR |

## 4. Safety boundaries (stricter than the core skill)

- Per-repo ledgers are the source of truth; the workspace holds only Registry + Config.
- Discovery uses the user's existing `gh` auth (read-only). The skill never requests, stores, or handles
  tokens or credentials.
- Cloning downloads code → always propose the list and wait for explicit confirmation.
- **Never push, open a PR, or merge.** Opt-in `git_execution` permits a local commit of the new
  `Agile-Ledger/` folder on a `setup_branch`; the user does the rest.
- Reconstructed Epics/Stories are **proposals only** — Inbox Drafts flagged `🔍 reconstructed from git`,
  never with invented value or acceptance criteria, never Ready/Delivered, never overwriting human content.
- Sweeps read-only by default; every state-changing action is confirmed. Registry rows are never deleted.

## 5. Commands (6; namespaced under the plugin)

- `/init-workspace` — scaffold `Registry.md` + `Config.md`; capture org + clone target. Setup only.
- `/discover-repos` — local `.git` scan + `gh repo list <org>`, diff against the Registry, classify
  new / known / local-only, **propose** clone + bootstrap for new repos (confirm before cloning).
- `/bootstrap-repo <path> [--from-git]` — scaffold one repo's `Agile-Ledger/` (only if absent);
  `--from-git` seeds proposed drafts from history; opt-in local commit on the setup branch.
- `/sweep` *(alias `/workspace-sync`)* — the holidays command: discovery + per-repo `/sync-main` +
  flag/propose undocumented merges → **one consolidated report**. Read-only by default.
- `/workspace-status` — dashboard across managed repos (sprint, unreleased, blocked, last sync).

## 6. Reconstruction logic (git → proposed backlog)

Signal: merges to `main` with no `[US-xxx]` id (per-repo `/sync-main` already detects these); for a new
repo, the whole history. Heuristics (see `references/reconstruction-guide.md`): prefer merged PRs (≈ one
candidate story), cluster by area/theme into candidate epics, propose `feat`/user-facing work and skip
chore/ci/style noise, stay conservative (3–8 epics with a few stories, not a per-commit dump). Output is
always Inbox Drafts with `value: ?? (confirm)` where unclear — the human writes value, AC, and slicing at
`/triage`. Idempotent: only looks past each repo's last-sync SHA; never re-proposes a drafted commit/PR.

## 7. Files

```
Agile-Ledger-Workspace/
├── Registry.md   # managed repos: path, remote, status, last-sync SHA, last swept (never-delete rows)
└── Config.md     # org, clone_target, include/exclude, git_execution, setup_branch
```

Skill assets: `skills/agile-ledger-workspace/{SKILL.md, references/{Registry.template.md,
Config.template.md, reconstruction-guide.md}}`.

## 8. Deliberately NOT included

Hands-off auto-onboarding (always confirm, per decision 2); pushing/PRs/merges (user-only); the
orchestrator storing backlogs (per-repo only); auto-registering reconstructed work as truth.

## 9. Extension points

A non-GitHub host adapter (the `gh` call is the only host-specific piece); a `/workspace-roadmap` rolling
epics up across repos; scheduled sweeps. Keep every safety boundary above when extending.
