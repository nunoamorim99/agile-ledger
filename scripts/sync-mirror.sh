#!/usr/bin/env sh
#
# Sync the manual-install mirror from the plugin source of truth.
#
#   source of truth : plugins/agile-ledger/{commands,skills}
#   generated mirror: commands/agile-ledger/*.md  +  skills/**
#
# Why a mirror exists at all: a marketplace plugin's root is a hard boundary — paths that
# traverse above plugins/agile-ledger/ are not copied into the plugin cache, so the files
# must physically live inside the plugin. The top-level copy serves the "drop into your
# .claude/ folder" install documented in INSTALL.txt, where commands are namespaced by
# directory (commands/agile-ledger/idea.md -> /agile-ledger:idea) rather than by plugin name.
#
# Usage:
#   scripts/sync-mirror.sh          regenerate the mirror in place
#   scripts/sync-mirror.sh --check  exit non-zero if the mirror is stale (CI)
#
# Edit files under plugins/agile-ledger/ only. Never hand-edit the mirror; it is overwritten.

set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

SRC_COMMANDS="plugins/agile-ledger/commands"
SRC_SKILLS="plugins/agile-ledger/skills"
DST_COMMANDS="commands/agile-ledger"
DST_SKILLS="skills"

for d in "$SRC_COMMANDS" "$SRC_SKILLS"; do
    [ -d "$d" ] || { echo "sync-mirror: missing source directory: $d" >&2; exit 1; }
done

CHECK=0
[ "${1:-}" = "--check" ] && CHECK=1

if [ "$CHECK" -eq 1 ]; then
    STAGE=$(mktemp -d)
    trap 'rm -rf "$STAGE"' EXIT
    OUT_COMMANDS="$STAGE/commands/agile-ledger"
    OUT_SKILLS="$STAGE/skills"
else
    OUT_COMMANDS="$DST_COMMANDS"
    OUT_SKILLS="$DST_SKILLS"
    rm -rf "$DST_COMMANDS" "$DST_SKILLS"
fi

mkdir -p "$OUT_COMMANDS" "$OUT_SKILLS"
cp -R "$SRC_COMMANDS/." "$OUT_COMMANDS/"
cp -R "$SRC_SKILLS/." "$OUT_SKILLS/"

if [ "$CHECK" -eq 1 ]; then
    STATUS=0
    diff -r "$OUT_COMMANDS" "$DST_COMMANDS" >/dev/null 2>&1 || STATUS=1
    diff -r "$OUT_SKILLS" "$DST_SKILLS" >/dev/null 2>&1 || STATUS=1
    if [ "$STATUS" -ne 0 ]; then
        echo "sync-mirror: mirror is STALE — it does not match plugins/agile-ledger/." >&2
        echo "" >&2
        diff -r "$OUT_COMMANDS" "$DST_COMMANDS" 2>&1 | sed 's/^/  /' >&2 || true
        diff -r "$OUT_SKILLS" "$DST_SKILLS" 2>&1 | sed 's/^/  /' >&2 || true
        echo "" >&2
        echo "Fix: run  scripts/sync-mirror.sh  and commit the result." >&2
        echo "Edit files under plugins/agile-ledger/ — never the mirror." >&2
        exit 1
    fi
    echo "sync-mirror: mirror is in sync with plugins/agile-ledger/."
else
    echo "sync-mirror: regenerated $DST_COMMANDS and $DST_SKILLS from plugins/agile-ledger/."
fi
