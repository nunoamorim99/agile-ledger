---
name: agile-ledger-workspace
description: >-
  Optional multi-repo orchestrator for Agile-Ledger. Install once at a workspace root to manage many
  repositories at once: discover new repositories on a GitHub org (including ones nobody told you about),
  clone and bootstrap them, run a single cross-repo "what changed while I was away" sync, and reconstruct
  undocumented work from git history into proposed backlog drafts. Use this skill whenever the user talks
  about multiple repos, a workspace or monorepo root, "what changed across all projects", detecting new
  repositories, onboarding a repo, syncing everything after time off / holidays, or turning git commits
  and PRs into epics/stories. It NEVER replaces the per-repo Agile-Ledger — each repo keeps its own
  `Agile-Ledger/` folder as the source of truth; this layer only discovers, sweeps, and proposes.
---

# Agile-Ledger Workspace (optional orchestrator)

A layer that sits **one level above** the per-repo Agile-Ledger skill. The per-repo skill is unchanged
and remains the default: each repository owns its self-contained `Agile-Ledger/` folder. This
orchestrator exists for the "install once, manage many" case — most usefully, **coming back from time
off and finding out, in one command, what changed across every repo and which repos are new.**

It solves a specific blind spot: a repo created on the git host that **nobody told you about**. A local
folder scan can't catch that — only asking the host can. So discovery queries GitHub via your existing
`gh` auth, not just the filesystem.

```
<workspace-root>/
├── Agile-Ledger-Workspace/      # this orchestrator's only files
│   ├── Registry.md              # managed repos: path, remote, status, last-sync SHA, last-swept
│   └── Config.md                # org, clone target, filters, git_execution, setup branch
├── repo-a/  └─ Agile-Ledger/…   # per-repo ledger — the source of truth, unchanged
├── repo-b/  └─ Agile-Ledger/…
└── …
```

---

## Golden safety rules (never violate)

These are stricter than the per-repo skill because this layer touches the network and the filesystem:

- **Per-repo ledgers are the source of truth.** The workspace holds only `Registry.md` and `Config.md`
  — never a backlog, sprint, or release. Each repo's `Agile-Ledger/` is authoritative for itself.
- **Discovery uses your existing `gh` auth.** Run `gh repo list <org> …` (read-only). **Never** request,
  read, store, or handle tokens or credentials. If `gh` is not authenticated, say so and stop.
- **Cloning downloads code → always propose and wait.** List the repos that would be cloned and wait for
  the user's explicit confirmation before any `git clone`. No hands-off cloning.
- **Never push, never open a PR, never merge.** When `git_execution` is `on`, the orchestrator may write
  and commit a repo's new `Agile-Ledger/` folder **locally on a setup branch**; the **user** pushes /
  opens the PR. When `off`, it only writes files and lets the user do everything.
- **Reconstructed work is always a proposal, never truth.** Epics/stories mined from git land **only** in
  the target repo's 📥 Inbox as Drafts, flagged `🔍 reconstructed from git — needs review`. Never write
  acceptance criteria, estimates, or a Ready/Delivered state from inference. Never invent the "so that…".
  Never overwrite anything a human wrote.
- **Sweeps are read-only by default.** Every state-changing action (clone, bootstrap, commit, draft) is
  surfaced and confirmed, then performed — not assumed.
- **Never delete** rows from the Registry; mark them `archived`/`gone` instead.

---

## Setup

If `Agile-Ledger-Workspace/` doesn't exist, scaffold `Registry.md` and `Config.md` from the reference
templates. `Config.md` keys:

```
org:            <github-org-or-owner>     # scanned via gh
clone_target:   ./                        # where new repos are cloned (relative to workspace root)
include:        []                        # optional name globs (empty = all)
exclude:        [archived, forks]         # skipped from proposals (still listed, marked)
git_execution:  off                       # off = text only; on = allow clone/commit on confirmation
setup_branch:   agile-ledger-setup        # local branch for the committed Agile-Ledger/ folder
```

---

## Commands

### `/init-workspace`
Scaffold `Agile-Ledger-Workspace/Registry.md` and `Config.md`. Ask for the GitHub org and clone target,
write them to `Config.md`. Do not scan yet. This is the only setup step.

### `/discover-repos`
Find repositories — the new-repo detector.
1. **Local scan:** find directories containing `.git` under the workspace root; record path + remote.
2. **Org scan:** `gh repo list <org> --limit 1000 --json name,url,isArchived,isFork …` (read-only).
3. **Diff against `Registry.md`:** classify each repo as **new** (in org, not in Registry), **known**,
   or **local-only** (cloned but not in the org list). Apply `exclude` filters (still list them, marked).
4. **Report** the three groups. For **new** repos, **propose** `git clone` into `clone_target` and then
   `/bootstrap-repo` on each — and **wait for confirmation** before cloning anything.
5. After confirmed clones, add rows to `Registry.md` (never overwrite existing rows).

### `/bootstrap-repo <path> [--from-git]`
Onboard one repository.
- Scaffold its `Agile-Ledger/` folder from the per-repo skill's templates **only if absent** (never
  overwrite an existing ledger; if present, report and stop).
- With **`--from-git`**: mine the repo's history and **propose** reconstructed Epics/User Stories as
  Drafts in the new ledger's 📥 Inbox, each flagged `🔍 reconstructed from git`. Follow
  `references/reconstruction-guide.md`. These are proposals for `/triage`, never confirmed truth.
- If `git_execution` is `on`: create the `setup_branch`, stage + commit the `Agile-Ledger/` folder
  locally, and tell the user the branch is ready for them to push / open a PR. **Never push or PR.**
  If `off`: just write the files and tell the user what to commit.

### `/workspace-sync`
The one-command "what changed while I was away." Across every repo in `Registry.md`:
1. Run **`/discover-repos`** to catch any new repos.
2. In each known repo, run the per-repo **`/sync-main`** reconciliation (merges to `main` since the
   repo's last-sync SHA, mapped to `[US-xxx]` case-insensitively).
3. **Flag undocumented work:** merges with **no** `US` id are delivered work nobody registered — for
   each, **propose** a reconstructed Draft in that repo's Inbox (flagged, linked to the commit/PR).
4. Produce **one consolidated report**, per repo: new / merged-and-reconciled / undocumented-drafted /
   unchanged, plus blocked items and unreleased counts.
Read-only by default — it drafts and reconciles only on confirmation. Update each repo's last-sync SHA
and the Registry's `last swept` date after the user reviews. The point: you learn *where* to look from
one command, then walk into each flagged repo to triage the news.

### `/workspace-status`
A dashboard from `Registry.md` + each repo's ledger: per repo, the current sprint + goal, unreleased
(Increment) count, blocked count, and last-sync date. Read-only.

---

## Reconstruction (git → proposed backlog)

The detection signal already exists in the per-repo skill: `/sync-main` flags **merges to main with no
`[US-xxx]` id** — that *is* undocumented delivered work. For a brand-new repo, the whole history is the
signal. Turn signal into *proposals*, never into confirmed stories — see
`references/reconstruction-guide.md` for the clustering heuristics and the hard guardrails (no invented
value, no invented acceptance criteria, conservative output, Inbox-only, human triages).

This keeps the skill's core philosophy intact: the tool does the bookkeeping legwork; the human keeps
judgment over what is real, what the user value is, and how it's sliced.

---

## Idempotency

Everything here is safe to re-run. Discovery diffs against the Registry; sweeps only look at commits
after each repo's recorded last-sync SHA; bootstrap skips repos that already have a ledger; reconstructed
items only ever appear once in the Inbox (don't re-propose an already-drafted commit/PR). Never
overwrite human-written ledger content under any circumstances.
