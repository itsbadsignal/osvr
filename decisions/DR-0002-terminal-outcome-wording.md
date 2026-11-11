# DR-0002: Terminal outcomes, amend three of the five

Date: 2026-11-10   Status: accepted (approved by the user on 2026-11-10)

## Context
`research/FIELD-SYNTHESIS.md` section 3 proposes three wording changes, each tied to a finding:
- Collisions and AI-volume contention: CVE-2022-0185 had two finders and an untriaged fuzzer hit [`research/benchmarks/expert-paths.md`]; curl's confirmed-report rate fell below 5% and the bounty ended; Pwn2Own collisions cut payouts [`research/domain-maps/field-overview.md`, CURL, P2O-I1].
- About half of real 0-days are injection, deserialization, traversal, auth or logic bugs where "against modern mitigations" is meaningless (KEV 2025-26 tally; GTIG-2025 enterprise share) [`research/domain-maps/field-overview.md`].
- Reliability is gating in the field: kernelCTF runs the exploit 20 times with a minimum pass score (a 70% pass line per the field map) [`research/domain-maps/field-overview.md`, KCTF].
- Hiring asks for one personally-found bug you can talk through, with public writeups as a recurring preferred signal (6 postings) and written reporting as the most frequent requirement [`research/benchmarks/job-market.md`].

## Options
1. **Keep the five outcomes as written.** Pros: no constitutional change. Cons: "Find" lets a learner report a duplicate; "Exploit" either excludes half the real bug population or forces a meaningless mitigation-bypass framing on a command injection; no reliability bar means an exploit that worked once passes; "Disclose" does not produce the portfolio artefact hiring asks for.
2. **Adopt all three synthesis amendments as proposed.** Pros: evidence-backed. Cons: the Exploit amendment, read alone, would let a learner graduate without ever building a memory-corruption exploit against modern mitigations, which is the low-level hiring core [`research/benchmarks/job-market.md`, junior skills list] and the conflict C1 in the synthesis.
3. **Adopt all three with two guards** (chosen): the impact-PoC clause applies to the learner's own found bug, while graduation still requires one memory-corruption exploit against modern mitigations (`CAP-03`); and the public writeup respects the disclosure timeline.

## Decision
Proposed replacement text for CLAUDE.md "Terminal outcome" (to be applied by the user or on their instruction):

1. **Map**: unchanged.
2. **Find**: discover a previously unknown bug through manual audit, fuzzing or variant analysis, **and check that it is novel (not already fixed upstream, reported, or a known fuzzer hit) before reporting.**
3. **Root-cause**: unchanged.
4. **Exploit**: build a reliable exploit against modern mitigations on a current target, in a lab they control. **For non-memory bug classes (injection, auth bypass, logic), a reliable proof of concept that demonstrates the real impact satisfies this outcome. Reliability is measured, not asserted: the exploit or PoC is run at least 20 times on a fresh target state and its success rate is reported; the default pass line is 70%, adopted from kernelCTF's stability scoring and tunable per track.** Graduation still requires at least one memory-corruption exploit against modern mitigations (capstone `CAP-03`).
5. **Disclose**: write a vendor-grade advisory, run coordinated disclosure through to a CVE or fix, **and publish a technical writeup that explains the bug to the line, once the disclosure timeline allows.**

The 20-run / 70% bar is a design parameter borrowed from one programme (kernelCTF), not a research-validated threshold. Tracks may set a stricter bar (LK should match kernelCTF's own scoring) or a looser one where the target cannot be reset cheaply (some EMB hardware), with the reason stated in the track MAP.

## Consequences
- Rubrics (`rubric.md`) for exploit-bearing modules need a reliability section: number of runs, success rate, environment description. Applies from `BX-05` onward; formally taught in `BX-11`.
- `VD-09` (target selection and novelty checks) and `PRO-05` carry the novelty check; `VD-10` and `CAP-01` rubrics require it before any report.
- `PRO-06` and `CAP-02` require a public writeup or, while an embargo runs, a writeup ready for publication with a scheduled date.
- Until the user approves, module-builders should write rubrics to the amended wording but cite this DR as proposed.
- Also prompted by the synthesis but not decided here: the D4 card guidance revision toward application on fresh cases (FIELD-SYNTHESIS finding 9). Needs its own DR.
