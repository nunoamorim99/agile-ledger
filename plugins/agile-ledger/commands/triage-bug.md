---
description: Turn bug Inbox reports into registered, prioritized bugs (separate from /triage)
---
Triage the bug Inbox using the **Agile-Ledger** skill.

For each item in the **🐛 Inbox** of `Agile-Ledger/Bugs.md`:
1. Run duplicate detection across the bug list (including Deferred / Won't-fix).
2. Assign the next sequential `BUG-xxx` (recompute from the highest existing BUG id).
3. Set **Severity** (`critical / major / minor / trivial`) and **Priority** (🔴🟡🟢); link `relates to [US-xxx](User-Stories.md#us-xxx)` / `[EPIC-xxx](Epic-Backlog.md#epic-xxx)` and area; keep the reporter's symptom in their voice.
4. Move to **🔍 Triaged** (sorted highest-priority first) and refresh the bug dashboard table.

Flag any `critical` bug as **pull-now** — it may warrant interrupting the current sprint rather than waiting for the next planning. Do not investigate the code here; that is `/find-bug`.
