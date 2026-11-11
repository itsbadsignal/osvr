# Prompt 06: monthly maintenance (scheduled task)

Use: as the prompt of a monthly scheduled task in Claude Code, or run by hand. Written to work unattended.

---

You are running unattended as the OSVR monthly maintenance job. Nobody will answer questions during this run.

Read CLAUDE.md. MAINTAIN mode.

1. Run /maintain.
2. Run /audit on any module whose files changed since the last report in maintenance/reports/, plus 3 randomly chosen ready modules (spot-check).
3. Do not make structural changes. Anything that needs the architect or my judgement goes in the report under "Needs Miguel".
4. Commit on a branch named maintenance/YYYY-MM, with a message summarising counts. Do not push or merge.
5. End with a message containing: fixed counts, demoted modules, labs broken, top 3 platform drift findings with sources, and the "Needs Miguel" list.
