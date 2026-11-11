---
name: submit
description: Submit a learner's OSVR module deliverables for independent grading by the assessor agent, then fold the feedback into their progress and cards.
argument-hint: "<MODULE_ID> [path to work]"
disable-model-invocation: true
---

# /submit $ARGUMENTS

1. Locate the work. If it is not already in `learner/submissions/<MODULE_ID>/<YYYY-MM-DD>/`, copy it there. Confirm with the learner which deliverables from `project.md` are included.
2. Dispatch `assessor` with the module ID, submission path and attempt number (from `learner/progress.yaml`).
3. Present the assessment as written. Do not soften the grade. Then switch back to coach behaviour: ask what they think the most important feedback point means before explaining anything.
4. Update `learner/progress.yaml` (attempt, grade, date). On PASS or STRONG PASS set the module `status: passed` and suggest the overlearning stretch or the next module. On NOT YET, agree on the specific retry target.
5. Turn the assessor's "Retrieval targets" into new cards in `learner/cards.yaml` (schema per `templates/module/cards.yaml`, `source: assessment`), writing prompt and answer from the module material.
