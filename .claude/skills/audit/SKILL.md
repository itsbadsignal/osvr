---
name: audit
description: Audit OSVR content against the Definition of Done, ultralearning contract, technical accuracy and source integrity. Read-only; produces a dated report.
argument-hint: "[MODULE_ID | TRACK | all]"
disable-model-invocation: true
---

# /audit $ARGUMENTS

Mode: MAINTAIN. Scope: "$ARGUMENTS" (default: all modules with status `ready` or `drafting`).

1. Run `python3 scripts/validate.py` for the scope and keep the output.
2. Split the scope into batches of up to 4 modules and dispatch one `curriculum-auditor` per batch in parallel.
3. For `all` scope, also dispatch one `curriculum-auditor` for a structural review of `skill-tree.yaml`: orphan nodes, nodes tracing to no outcome, prerequisite chains longer than needed, unrealistic hour totals, outcomes with thin coverage.
4. Merge results into `maintenance/reports/YYYY-MM-DD-audit-<scope>.md`.
5. Demote any `ready` module that received BLOCKED or a D9/D10 failure to `drafting`, and log it in the CHANGELOG.
6. Report: verdict counts, top 5 blocking issues across the scope, and the recommended fixing order.
