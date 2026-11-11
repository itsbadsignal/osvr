---
name: build-module
description: Build one or more OSVR modules end to end - content, lab, audit, and fix loop - from planned skill-tree nodes. Use after /design is approved.
argument-hint: "<MODULE_ID | TRACK (builds all planned modules in DAG order)> [--no-lab]"
disable-model-invocation: true
---

# /build-module $ARGUMENTS

Mode: BUILD.

## Resolve scope

If the argument is a track ID, list its `planned` nodes in topological order and build them one at a time in that order (prereqs first, so later modules can reference earlier vocabulary). If it is a module ID, check its prereqs are at least `drafting`; if not, say which and stop.

## Per module loop

1. **Research check.** Does `research/` cover this node's topic and contain a verified direct target? If not, dispatch `researcher` with a targeted brief first.
2. **Write.** Dispatch `module-builder` with the module ID. Collect its TODOs and self-assessment.
3. **Lab.** If `lab/SPEC.md` was written and `--no-lab` is not set, dispatch `lab-engineer`. Independent modules' labs may be built in parallel with the next module's writing.
4. **Audit.** Dispatch `curriculum-auditor` scoped to the module.
5. **Fix loop.** If verdict is REVISE, send the blocking issues back to `module-builder` (and `lab-engineer` for lab issues), then re-audit. Maximum 2 fix rounds; after that, leave the module `drafting` and surface the remaining issues to the user.
6. **Promote.** On READY, set `status: ready` in `skill-tree.yaml`, append to `maintenance/CHANGELOG.md`, and run `python3 scripts/build_index.py` so the learner map shows the new status.

## Report

Per module: final status, audit verdict, outstanding `TODO(research)` and `needs-lab-verification` items, lab verified yes/no. Then the next buildable modules.
