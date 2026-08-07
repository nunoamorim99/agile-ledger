# Contributing

## Repository layout — one source of truth

The plugin's commands and skills exist twice on purpose, and **only one copy is editable**:

| Path | Role |
|---|---|
| `plugins/agile-ledger/commands/`, `plugins/agile-ledger/skills/` | ✅ **Source of truth — edit here** |
| `commands/agile-ledger/`, `skills/` | 🤖 Generated mirror — **never hand-edit** |

Why the duplication can't simply be deleted: a marketplace plugin's root is a hard boundary. Paths
that traverse above `plugins/agile-ledger/` are not copied into the plugin cache on install, so the
files must physically live inside the plugin directory. The top-level copy exists to serve the
"drop into your `.claude/` folder" install described in [INSTALL.txt](INSTALL.txt), where commands are
namespaced by directory (`commands/agile-ledger/idea.md` → `/agile-ledger:idea`) instead of by plugin
name.

### Workflow

Edit under `plugins/agile-ledger/`, then regenerate the mirror before committing:

```sh
scripts/sync-mirror.sh
```

To check without writing anything (this is what CI runs):

```sh
scripts/sync-mirror.sh --check
```

The mirror is deleted and recreated on every run, so any edit made directly to
`commands/agile-ledger/` or `skills/` is silently discarded. CI fails the build if the mirror
does not match its source.

## Versioning

The version appears in two manifests and must match in both:

- `.claude-plugin/marketplace.json` — `metadata.version` and the plugin entry's `version`
- `plugins/agile-ledger/.claude-plugin/plugin.json` — `version`

CI verifies that the marketplace entry and `plugin.json` agree on both `name` and `version`.

## CI

[`.github/workflows/validate.yml`](.github/workflows/validate.yml) runs on every push and pull
request:

1. Both plugin manifests parse as JSON.
2. The marketplace entry resolves to a real plugin directory, names and versions agree, and the
   required `commands/` and `skills/agile-ledger/SKILL.md` are present.
3. The manual-install mirror is in sync with the plugin source.

## Ledger file conventions

The shapes the skill scaffolds and maintains are specified in
[`entry-templates.md`](plugins/agile-ledger/skills/agile-ledger/references/entry-templates.md).
Two rules are easy to miss when adding a command:

- **Overview tables are derived, never hand-typed.** Any command that changes an item's state,
  priority, estimate, assignee, or title must rebuild the roll-up counts **and** that item's row in
  the index table at the top of the file.
- **Nothing is ever deleted.** Delivered, Fixed, and Discarded items keep their entry and their
  overview row forever, so every anchor stays reachable.
