---
name: design
description: Design or redesign an OSVR track - its metalearning MAP.md, its nodes in skill-tree.yaml, and the decision records behind them. Use after /research has produced a synthesis for the track.
argument-hint: "<TRACK id, e.g. BX> [notes]"
disable-model-invocation: true
---

# /design $ARGUMENTS

Mode: BUILD.

1. Confirm `research/*SYNTHESIS.md` exists for this track. If not, stop and suggest `/research`.
2. Dispatch `curriculum-architect` with: the track ID, the synthesis path, the current `skill-tree.yaml`, any notes from the arguments, and this deliverable list:
   - `curriculum/tracks/<TRACK>/MAP.md` from `templates/track-MAP.md`
   - new or changed nodes in `curriculum/skill-tree.yaml`, each with prereqs, outcomes, hours, rds, mitigations
   - `decisions/DR-NNNN-*.md` for every structural choice
3. If the architect returns a research request instead, run the needed `researcher` briefs, then re-dispatch the architect once.
4. Run `python3 scripts/validate.py --tree-only`.
5. Show the user: the track outcome statement, the module list in DAG order with hours, total track hours, and the decisions that most deserve their review. Ask them to approve or adjust before any module is built. This is the one checkpoint where the user's judgement is required, because rebuilding modules on a wrong structure is expensive.
