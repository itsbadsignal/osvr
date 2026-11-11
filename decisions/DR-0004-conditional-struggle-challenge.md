# DR-0004: Make D5 (struggle challenge) conditional on prior knowledge

Date: 2026-11-10   Status: accepted (approved by the user on 2026-11-10)

## Context
DoD D5 required every module to open with a closed-book struggle challenge before the walkthrough, a problem-solving-before-instruction design. `research/FIELD-SYNTHESIS.md` finding 8 and conflict C3 flag this as contradicted for novices by `research/benchmarks/learning-science.md`:
- Section 6: unassisted discovery lost to explicit instruction (Alfieri et al. 2011, d = -0.38), while assisted discovery with feedback, worked examples and scaffolding won (d = +0.30). Productive failure (Sinha & Kapur 2021) helps (g = 0.36) when consolidation follows, and reversed for some populations (younger learners, domain-general skills). No source supports the 20-minute struggle threshold.
- Section 7: the worked-example effect for novices is strong; expertise reversal (Kalyuga et al. 2003) means guidance that helps novices can hurt experienced learners. The resolution the evidence supports is ordering conditional on prior knowledge of the specific sub-skill, always followed by consolidation.
OSVR's learner range ("can use a terminal" to working SOC professional, CLAUDE.md) makes a single order wrong for part of the population.

## Options
1. **Keep D5 universal (struggle first).** Pros: simple, one route. Cons: places novices in the unassisted-discovery condition that lost; contradicts the strongest evidence in the review.
2. **Worked example first for everyone.** Pros: safe for novices. Cons: expertise reversal for learners who already have the pieces; loses the productive-failure gain.
3. **Conditional D5** (chosen): prerequisite check first; a learner meeting the technique for the first time studies a subgoal-labelled worked example on a different instance, then attempts the closed-book challenge; a learner who passes the check and has met the technique attempts the challenge cold; every route ends with consolidation against the reference solution. The 20-minute struggle rule becomes a pilot parameter.

## Decision
Option 3. Implemented by the main thread on 2026-11-10 in CLAUDE.md (D5 text), `templates/module/README.md` (sections Prerequisite check, Worked example, Struggle challenge, Consolidation), `docs/ULTRALEARNING.md`, `.claude/agents/module-builder.md`, `.claude/skills/coach/SKILL.md` and `scripts/validate.py` (section presence and order checks). This record documents the decision; it does not change those files.

## Consequences
- Every module README needs four sections in order: Prerequisite check, Worked example, Struggle challenge (before any Walkthrough), Consolidation. `validate.py` enforces presence and order for drafting/ready modules.
- Worked examples must use a different instance from the struggle challenge, so the challenge stays a real test.
- The 20-minute struggle rule is a pilot parameter. The pilot logs time-to-first-hint per session, the route taken (worked-example-first vs challenge-cold), and compares completion and later retention on fresh binaries across routes.
- Capstones (`CAP-*`) are the expertise-reversal end state: no worked example, minimal scaffolding.
- Revisit after the first pilot cohort finishes FND and BX-05.
