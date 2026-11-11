# RE: Reverse engineering (metalearning map)

Updated: 2026-11-10   Research: pending /research RE   Decisions: DR-0001, DR-0004

Status: stub. Why, Outcome statement and Module path are set by the architect; the other sections wait for track-level research.

## Why
RE serves root-cause and map: recovering what stripped code does is required in nearly all low-level postings (research/benchmarks/job-market.md, skill tally) and an RE job first is the dominant employed route into VR (research/benchmarks/expert-paths.md, sequencing pattern 2). Most real targets (firmware, closed vendor binaries, patched releases) ship without source. The track ends on patch diffing because an N-day located from a binary diff is the legal, reproducible bridge to real targets (research/benchmarks/curricula-and-trainings.md implication 3; FIELD-SYNTHESIS finding 3).

## Outcome statement
"After this track you can take a stripped binary that parses untrusted input, recover its structures and control flow, and locate and trigger the security fix between two releases from a binary diff."

## Concepts / Facts / Procedures
pending /research RE.

| Concepts (understand) | Facts (memorise) | Procedures (automate) |
|---|---|---|
| pending /research | pending /research | pending /research |

## Benchmarks
pending /research RE. Field-level benchmarks already filed: research/benchmarks/expert-paths.md, research/benchmarks/curricula-and-trainings.md, research/benchmarks/job-market.md, research/benchmarks/learning-science.md. Note: CTF-style practice is a labelled entry ramp only; its effectiveness evidence is rated Low to Very Low (research/benchmarks/learning-science.md, FIELD-SYNTHESIS finding 10).

## Emphasise
pending /research RE.

## Exclude
pending /research RE.

## Module path
Modules in recommended order within the track. The interleaved core order across tracks is in `curriculum/skill-tree.yaml` (node order) and DR-0001.

| # | Module | Hours | RDS | Direct target |
|---|---|---|---|---|
| 1 | `RE-01-static-re-with-a-decompiler` Static reverse engineering of stripped binaries | 18 | recovering a function's intent from stripped disassembly and correcting the decompiler where it is wrong | set by module-builder |
| 2 | `RE-02-dynamic-re-and-instrumentation` Dynamic reverse engineering and instrumentation | 12 | placing breakpoints and hooks that answer one specific question about runtime state | set by module-builder |
| 3 | `RE-03-structure-and-protocol-recovery` Structure, file-format and protocol recovery | 16 | recovering structures and field semantics from stripped code that parses untrusted input | set by module-builder |
| 4 | `RE-04-patch-diffing-n-days` Patch diffing to locate and reconstruct an N-day | 14 | isolating the security-relevant change among noise in a binary diff and writing a trigger for it | set by module-builder |

Total hours: 60  (about 6 weeks at 10 h/week; pilot parameter, not a measured figure)

## Midpoint check
At `RE-03` the learner checks whether static or dynamic work is the bottleneck and re-balances drill time; coach prompts.

## Track capstone
None separate. `RE-04` feeds the first real N-day exploit (`BX-05`) and the heap N-day (`BX-10`).
