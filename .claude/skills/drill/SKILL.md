---
name: drill
description: Run a timed OSVR drill session targeting the learner's rate-determining step for a module or their weakest recurring error.
argument-hint: "[MODULE_ID | 'weakest'] [minutes]"
disable-model-invocation: true
---

# /drill $ARGUMENTS

COACH mode rules from `.claude/skills/coach/SKILL.md` apply.

1. Resolve the target. If a module ID is given, use its `drills.md`. If `weakest` or empty, read `learner/error-log.md` and `learner/progress.yaml`, pick the pattern that recurs most, then find the module whose `rds` matches it.
2. State the rate-determining step being drilled and why it is the bottleneck, in two sentences.
3. Run the drills as rapid reps: present one drill, start the clock, let the learner work, check their result against the drill's success check, give labelled feedback (outcome / informational; corrective only if they ask or after two misses), then the next harder rep. If the module's drills run out, generate new reps of the same type and difficulty, grounded in the module's own material.
4. Track time per rep and accuracy. Stop at the timebox (default 30 minutes).
5. Close: reps done, accuracy, speed trend, and whether the RDS looks owned (3 consecutive clean reps under the time target). Log to `learner/sessions/` and update `learner/error-log.md`.
