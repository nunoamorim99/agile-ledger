---
description: Show the Agile-Ledger command map — which command belongs to which phase and file
allowed-tools: Read, Grep, Glob
---
Using the **Agile-Ledger** skill, print a concise overview for the user (read-only — change nothing):

1. The **phase → command → file** map (Capture → Triage → Detail → Plan → Execute → Release), naming for
   each command which `Agile-Ledger/` file it reads or writes.
2. The current project's state if a ledger exists: counts of ideas, epics, stories by state, open bugs,
   and the active sprint — a one-glance "where things are."

Keep it compact and scannable. If no `Agile-Ledger/` folder exists yet, explain that the first `/idea`,
`/triage`, or `/bug` will scaffold it, and just show the command map.
