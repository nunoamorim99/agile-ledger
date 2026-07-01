---
description: (Workspace) Onboard one repo — scaffold its Agile-Ledger/, optionally seed drafts from git
argument-hint: <path> [--from-git]
---
Using the **Agile-Ledger Workspace** skill, onboard the repository at `$ARGUMENTS`. Scaffold its `Agile-Ledger/` folder from the per-repo skill's templates **only if absent** (never overwrite an existing ledger — report and stop if present). With `--from-git`, mine the repo's history and **propose** reconstructed Epics/User Stories as Drafts in the new ledger's 📥 Inbox, each flagged `🔍 reconstructed from git`, following `references/reconstruction-guide.md` (no invented value or acceptance criteria; Inbox-only; human triages). If `git_execution` is `on`, create the `setup_branch`, stage and commit the `Agile-Ledger/` folder **locally**, and tell the user it is ready to push / PR — never push, PR, or merge. If `off`, just write the files.
