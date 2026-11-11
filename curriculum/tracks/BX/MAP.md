# BX: Binary exploitation (userland) (metalearning map)

Updated: 2026-11-10   Research: pending /research BX (blocked on glibc userland defaults, FIELD-SYNTHESIS Q2)   Decisions: DR-0001, DR-0002, DR-0004

Status: stub. Why, Outcome statement and Module path are set by the architect; the other sections wait for track-level research.

## Why
BX serves exploit, and root-cause at the primitive level. It keeps the canonical order shared by free curricula (stack, format strings, mitigations one at a time, heap) but compressed, and adds what they lack: real N-days as the exploit targets and explicit mitigation-era labelling per module (research/benchmarks/curricula-and-trainings.md, sections 2 and 3). Exploit practice is fed by N-days because finding and exploiting are separate skills (research/benchmarks/expert-paths.md, Hypr). Every technique is met without its mitigation, then with it, then with the bypass, and `BX-06` shows which classic techniques CET/CFI kill.

## Outcome statement
"After this track you can build a reliable exploit (measured over at least 20 runs, DR-0002) for a real stack or heap N-day against NX, canaries, ASLR, PIE, full RELRO and current glibc heap hardening, and state which techniques you used are dead on newer defaults."

## Concepts / Facts / Procedures
pending /research BX.

| Concepts (understand) | Facts (memorise) | Procedures (automate) |
|---|---|---|
| pending /research | pending /research | pending /research |

## Benchmarks
pending /research BX. Field-level benchmarks already filed: research/benchmarks/expert-paths.md, research/benchmarks/curricula-and-trainings.md, research/benchmarks/job-market.md, research/benchmarks/learning-science.md. Note: CTF-style practice is a labelled entry ramp only; its effectiveness evidence is rated Low to Very Low (research/benchmarks/learning-science.md, FIELD-SYNTHESIS finding 10).

## Emphasise
pending /research BX.

## Exclude
pending /research BX.

## Module path
Modules in recommended order within the track. The interleaved core order across tracks is in `curriculum/skill-tree.yaml` (node order) and DR-0001.

| # | Module | Hours | RDS | Direct target |
|---|---|---|---|---|
| 1 | `BX-01-stack-overflow-to-control-flow` Stack overflow to controlled RIP and shellcode | 12 | computing the offset to saved RIP and verifying it in the debugger | set by module-builder |
| 2 | `BX-02-format-string-bugs` Format string bugs as leak and write primitives | 10 | computing argument offsets and write sizes for a targeted write | set by module-builder |
| 3 | `BX-03-nx-canaries-and-rop` NX and stack canaries, bypassed with leaks and ROP | 16 | finding and chaining gadgets under register and bad-byte constraints | set by module-builder |
| 4 | `BX-04-aslr-pie-relro-and-leaks` ASLR, PIE and RELRO, bypassed with info leaks and ret2libc | 14 | turning one info leak into the base addresses the rest of the chain needs | set by module-builder |
| 5 | `BX-05-first-n-day-exploit` First real N-day exploit under default-era mitigations | 16 | adapting textbook primitives to the constraints of real code (input filters, allocation order, crash-free return) | set by module-builder |
| 6 | `BX-06-cet-cfi-and-what-they-kill` CET shadow stack, IBT and CFI, and which techniques they kill | 8 | predicting whether a given chain survives shadow stack and indirect-branch tracking, and why | set by module-builder |
| 7 | `BX-07-glibc-heap-internals` glibc heap allocator internals | 16 | predicting allocator state (bins, tcache, chunk headers) after a malloc/free sequence | set by module-builder |
| 8 | `BX-08-heap-bug-classes` Heap bug classes: UAF, double free, overflow, uninitialised data | 14 | turning a heap bug into overlapping or controlled chunks via grooming | set by module-builder |
| 9 | `BX-09-modern-glibc-heap-techniques` Heap techniques that survive modern glibc | 18 | choosing a technique that survives the target glibc's checks and getting the leak it needs | set by module-builder |
| 10 | `BX-10-heap-n-day-exploit` Real heap N-day exploit | 20 | grooming a real program's heap into the layout the technique needs using only its normal inputs | set by module-builder |
| 11 | `BX-11-exploit-reliability-engineering` Exploit reliability engineering and measurement | 8 | finding and removing the sources of nondeterminism that make an exploit fail across runs | set by module-builder |

Total hours: 152  (about 15 weeks at 10 h/week; pilot parameter, not a measured figure)

## Midpoint check
At `BX-07` (start of the heap block, after the first bug hunt) the learner revisits this map. This is the documented quitting point (CLAUDE.md failure modes); the coach checks pacing and whether `BX-05` is retained by rebuilding it from a blank file.

## Track capstone
`CAP-03` (memory-corruption exploit against current mitigations) is the BX graduation proof.
