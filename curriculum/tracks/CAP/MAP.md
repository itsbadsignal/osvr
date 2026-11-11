# CAP: Graduation capstones (metalearning map)

Updated: 2026-11-10   Research: none needed beyond the core tracks; target lanes per DR-0003   Decisions: DR-0001, DR-0002, DR-0003, DR-0004, DR-0006

Status: stub. Why, Outcome statement and Module path are set by the architect; the other sections wait for track-level research.

## Why
The capstones prove all five terminal outcomes without guidance. `CAP-01`/`CAP-02` run a full 0-day lifecycle on a target the learner chooses (lanes A library, B network service, C appliance firmware with EMB, DR-0003). `CAP-03` guarantees every graduate has built one memory-corruption exploit against current mitigations, the guard that DR-0002 places on the impact-PoC clause. Scaffolding is minimal here: this is the expertise-reversal end state (DR-0004).

## Outcome statement
"After the capstones you have, unaided, found, root-caused, exploited (or demonstrated the impact of) and disclosed a previously unknown bug with a public writeup, and built a reliable memory-corruption exploit against a current target's default mitigations."

## Concepts / Facts / Procedures
pending /research CAP.

| Concepts (understand) | Facts (memorise) | Procedures (automate) |
|---|---|---|
| pending /research | pending /research | pending /research |

## Benchmarks
pending /research CAP. Field-level benchmarks already filed: research/benchmarks/expert-paths.md, research/benchmarks/curricula-and-trainings.md, research/benchmarks/job-market.md, research/benchmarks/learning-science.md. Note: CTF-style practice is a labelled entry ramp only; its effectiveness evidence is rated Low to Very Low (research/benchmarks/learning-science.md, FIELD-SYNTHESIS finding 10).

## Emphasise
pending /research CAP.

## Exclude
pending /research CAP.

## Module path
Modules in recommended order within the track. The interleaved core order across tracks is in `curriculum/skill-tree.yaml` (node order) and DR-0001.

| # | Module | Hours | RDS | Direct target |
|---|---|---|---|---|
| 1 | `CAP-01-zero-day-hunt-and-root-cause` Capstone 1a: hunt and root-cause a 0-day on a target of your choice | 50 | choosing, mapping and hunting a target without guidance until a novel, validated bug is root-caused | set by module-builder |
| 2 | `CAP-02-zero-day-exploit-and-disclosure` Capstone 1b: exploit or impact PoC, disclosure and public writeup for your 0-day | 30 | turning your own root-caused bug into a reliable exploit or impact PoC and a disclosure that lands | set by module-builder |
| 3 | `CAP-03-mitigation-bypass-exploit` Capstone 2: memory-corruption exploit against current mitigations | 60 | building a reliable chain on a current target under its default mitigation set | set by module-builder |

Total hours: 140  (about 14 weeks at 10 h/week; pilot parameter, not a measured figure)

## Midpoint check
At the end of `CAP-01` the coach checks whether the bug found is exploitable within the time budget; if not, the learner may run `CAP-02` as an impact PoC (non-memory class) or loop back to `CAP-01` with a new entry point.

## Track capstone
These are the capstones. Content lives in `curriculum/tracks/CAP/modules/<id>/` like any module (DR-0006); `curriculum/capstones/` is retired. Per-track capstones are nodes in their own track or named in that track's MAP.
