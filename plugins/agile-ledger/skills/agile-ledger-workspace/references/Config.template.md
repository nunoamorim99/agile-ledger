# Workspace Config

> Configuration for the Agile-Ledger Workspace orchestrator. Edit to fit your setup.

```
org:            <github-org-or-owner>     # the GitHub org/owner scanned via `gh repo list`
clone_target:   ./                        # where new repos are cloned (relative to the workspace root)
include:        []                        # optional repo-name globs to include (empty = all)
exclude:        [archived, forks]         # skipped from clone/bootstrap proposals (still listed, marked)
git_execution:  off                       # off = propose text only; on = allow clone/commit on confirmation
setup_branch:   agile-ledger-setup        # local branch used to commit a repo's new Agile-Ledger/ folder
```

## Notes

- **Authentication:** discovery uses your existing `gh` CLI session (`gh auth status` must be logged in).
  The skill never asks for, stores, or handles tokens.
- **git_execution:** even when `on`, the orchestrator **never pushes, opens PRs, or merges**. It may
  clone (after you confirm) and commit a new `Agile-Ledger/` folder locally on `setup_branch`; you push
  and open the PR.
- **exclude:** filters only reduce noise in proposals. Because onboarding is always propose-then-confirm,
  excluded repos are still listed (marked) so you can opt one in.
