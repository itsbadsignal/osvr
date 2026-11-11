# VD: Vulnerability discovery (metalearning map)

Updated: 2026-11-10   Research: pending /research VD; target shortlists for VD-09/VD-10 pending /research (research/targets/ is empty)   Decisions: DR-0001, DR-0002, DR-0003, DR-0004

Status: stub. Why, Outcome statement and Module path are set by the architect; the other sections wait for track-level research.

## Why
VD serves find, map and root-cause: the outcomes no free curriculum trains. Fuzzing is last or absent in every free syllabus read, patch diffing and variant analysis appear only in paid courses, and only one university course runs find-to-disclose (research/benchmarks/curricula-and-trainings.md). In-the-wild and KEV data show injection, deserialization, traversal and auth bugs outnumbering memory corruption (research/domain-maps/field-overview.md), so VD teaches logic classes as first-class content (`VD-05`). Fuzzing starts at hour 77 of the core, lab parity precedes the first hunt because environment setup is the documented cost centre (research/benchmarks/expert-paths.md), and validation plus novelty checks are weighted over raw bug count because AI and fuzzers contest the easy space (FIELD-SYNTHESIS finding 7).

## Outcome statement
"After this track you can choose an open-source target with a justified score, map its attack surface, run a coverage-tracked hunt using fuzzing, audit and variant analysis, and hand over either a novel, validated, root-caused bug or a negative-result report with coverage evidence."

## Concepts / Facts / Procedures
pending /research VD.

| Concepts (understand) | Facts (memorise) | Procedures (automate) |
|---|---|---|
| pending /research | pending /research | pending /research |

## Benchmarks
pending /research VD. Field-level benchmarks already filed: research/benchmarks/expert-paths.md, research/benchmarks/curricula-and-trainings.md, research/benchmarks/job-market.md, research/benchmarks/learning-science.md. Note: CTF-style practice is a labelled entry ramp only; its effectiveness evidence is rated Low to Very Low (research/benchmarks/learning-science.md, FIELD-SYNTHESIS finding 10).

## Emphasise
pending /research VD.

## Exclude
pending /research VD.

## Module path
Modules in recommended order within the track. The interleaved core order across tracks is in `curriculum/skill-tree.yaml` (node order) and DR-0001.

| # | Module | Hours | RDS | Direct target |
|---|---|---|---|---|
| 1 | `VD-01-bug-classes-and-attack-surface` Bug classes (memory and logic) and attack-surface mapping | 10 | listing the entry points of a real codebase and ranking them by how much attacker-controlled data they parse | set by module-builder |
| 2 | `VD-02-fuzzing-harnesses-and-sanitizers` Coverage-guided fuzzing with harnesses and sanitizers | 18 | writing a harness that reaches deep parser state rather than failing at the first validity check | set by module-builder |
| 3 | `VD-03-crash-triage-and-root-cause` Crash triage, minimisation and primitive identification | 10 | deciding from a minimised crash what primitive is reachable (read/write, size, control) and whether it is a duplicate | set by module-builder |
| 4 | `VD-04-source-audit-memory-safety` Manual source audit for memory-safety bugs | 16 | tracing attacker-controlled data across function boundaries to a size, index or lifetime decision | set by module-builder |
| 5 | `VD-05-logic-injection-and-auth-bugs` Logic, injection, traversal and authentication bugs | 20 | tracing a request parameter from the HTTP or socket handler to a shell, file path or auth decision | set by module-builder |
| 6 | `VD-06-variant-analysis-codeql-semgrep` Variant analysis from a fix with CodeQL and Semgrep | 16 | generalising one fixed bug into a query that finds its siblings without drowning in false positives | set by module-builder |
| 7 | `VD-07-ai-assisted-vr-and-validation` AI-assisted vulnerability research with independent validation | 8 | independently validating or refuting a model-proposed finding with a reproducer and a root cause | set by module-builder |
| 8 | `VD-08-lab-parity-and-target-debugging` Lab parity, emulation and debugging real targets | 12 | making the lab target behave like the real one (config, emulation, debugger attach, stable harness) | set by module-builder |
| 9 | `VD-09-target-selection-and-novelty-checks` Target selection and novelty checks | 6 | scoring a candidate target on source, build cost, prior CVEs, fuzzing coverage and disclosure path before investing time | set by module-builder |
| 10 | `VD-10-first-real-bug-hunt` First real bug hunt on an open-source target | 40 | sustaining a coverage-tracked hunt and deciding when to switch technique or entry point | set by module-builder |

Total hours: 156  (about 16 weeks at 10 h/week; pilot parameter, not a measured figure)

## Midpoint check
At `VD-04` the learner revisits this map: which find technique produced the most signal so far, and which lane (DR-0003) they will hunt in at `VD-10`.

## Track capstone
`VD-10` first real bug hunt (two lanes, DR-0003); `CAP-01` is the unguided repeat.
