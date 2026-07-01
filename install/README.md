# Project-scope install (whole team)

To give every collaborator on a repository Agile-Ledger automatically, copy
[`project.settings.json`](project.settings.json) into that repository at:

```
<your-project>/.claude/settings.json
```

If the project already has a `.claude/settings.json`, **merge** the two keys
(`extraKnownMarketplaces` and `enabledPlugins`) into it rather than overwriting the file.

Commit and push. When a teammate opens the repo and trusts the folder, Claude Code prompts them to
install the `nunoamorim99` marketplace and enable `agile-ledger@nunoamorim99`. Updates ship as normal
pull requests to this file.

## The two keys, and why both are needed

- `extraKnownMarketplaces` — tells the project where the marketplace lives (your GitHub repo). Without it,
  a project-scope `enabledPlugins` entry points at a marketplace the project doesn't know, which is the
  usual cause of a project-scope install error.
- `enabledPlugins` — turns the plugin on, using the `"<plugin>@<marketplace>": true` format
  (`"agile-ledger@nunoamorim99": true`).

## Scope cheat-sheet

| Scope | File | Shared? |
|---|---|---|
| User | `~/.claude/settings.json` | no — just you, everywhere |
| Project | `<project>/.claude/settings.json` | yes — committed, whole team |
| Local | `<project>/.claude/settings.local.json` | no — you, this repo, gitignored |

To opt out on your own machine of a project-enabled plugin, set it to `false` in
`.claude/settings.local.json`.
