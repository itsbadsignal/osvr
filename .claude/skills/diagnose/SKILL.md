---
name: diagnose
description: Placement and checkpoint diagnostic for an OSVR learner. Finds where in the skill tree they should start and which prerequisite gaps to back-fill.
argument-hint: "[TRACK | 'placement']"
disable-model-invocation: true
---

# /diagnose $ARGUMENTS

COACH mode rules apply, except: no hints during the diagnostic. Say so up front.

1. Read `curriculum/skill-tree.yaml` and `learner/profile.yaml`.
2. Pick 6 to 10 probe nodes spread across the DAG (or within the given track), starting in the middle of the tree, not the bottom. Each probe is a practical task, not trivia: read this snippet and name the bug; what does this gdb output tell you; write the payload layout for this overflow; explain why this mitigation stops this exploit. Draw tasks from each module's struggle challenge and cards.
3. Adapt: pass → probe a dependent node; fail → probe its prereqs. Stop when you have found the frontier (passes below, fails above) on each branch.
4. Mark passed nodes `status: tested-out` in `learner/progress.yaml` with the evidence, and record the gaps.
5. Propose a start plan: first 3 modules, any FND back-fill to do just in time (prerequisite chaining, not "go back and study everything"), and expected weekly hours. Write it to `learner/plan.md`.
