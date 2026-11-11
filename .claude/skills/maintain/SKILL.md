---
name: maintain
description: Run the OSVR maintenance cycle, covering freshness sweep, platform drift check, new research intake, inbox triage, and routed fixes. Suitable for a scheduled monthly run.
argument-hint: "[--sweep-only | --inbox-only]"
disable-model-invocation: true
---

# /maintain $ARGUMENTS

Mode: MAINTAIN.

1. Dispatch `maintainer` for the sweep (unless `--inbox-only`) and inbox triage (unless `--sweep-only`).
2. Read its report. For each escalation:
   - `lab-broken` → dispatch `lab-engineer` with the module and symptom.
   - `pedagogy` / `changed` source → dispatch `module-builder` with the module and the specific issue only (not a full rewrite), then `curriculum-auditor` on that module.
   - `structure` → do not act. List it for the user with a suggested `/design` invocation.
3. Run `python3 scripts/validate.py`.
4. Report: what was fixed automatically, what was routed and its outcome, what needs the user, and the date of the next suggested sweep.

If running unattended (scheduled), do not wait for answers: complete steps 1 to 3, skip structural items, and write everything the user must see into the report file and the final message.
