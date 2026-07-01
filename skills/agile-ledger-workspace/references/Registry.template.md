# Workspace Registry

> Repositories managed by the Agile-Ledger Workspace. Updated by `/discover-repos` and `/workspace-sync`.
> **Never delete rows** — mark a repo `archived` or `gone` instead. The per-repo `Agile-Ledger/` folder
> in each repository is the source of truth; this table only tracks orchestration state.

| Repo | Path | Remote | Status | Last sync (SHA) | Last swept | Notes |
|------|------|--------|--------|-----------------|------------|-------|
<!-- | repo-a | ./repo-a | git@github.com:acme/repo-a.git | active | a1b2c3d | 2026-06-20 | | -->

**Status values:** `active` · `new` (discovered, not yet bootstrapped) · `archived` · `gone`
(remote no longer listed) · `local-only` (cloned but not in the org scan).
