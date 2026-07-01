---
description: Audit all ledger files for drift (report; fix only on request)
---
Using the **Agile-Ledger** skill, audit all `Agile-Ledger/*.md` files for drift: duplicate or mis-sequenced typed IDs, dangling `Parent`/dependency links, plus any ID link that doesn't resolve to an existing `#id` anchor, childless epics, a story on the board but missing under its epic (or vice versa), a board column not matching the story's recorded state, orphan Increment lines, and stale `Next free ID` counters. Report findings clearly; fix only on explicit request.

Also reconcile the two-file split: epic index line state vs. the story's group in **`User-Stories.md`**, a Ready+ story missing its index line (or vice versa), a Draft story that wrongly has a detail entry, and stale overview tables.
