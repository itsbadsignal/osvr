# FND: Foundations (metalearning map)

Updated: 2026-11-10   Research: none track-level yet (pending /research FND); field-level: research/FIELD-SYNTHESIS.md   Decisions: DR-0001, DR-0004, DR-0005

Status: stub. Why, Outcome statement and Module path are set by the architect; the other sections wait for track-level research.

## Why
FND serves root-cause first (reading C and machine state to the line), then exploit and find: every documented expert path starts with programming and assembly before memory corruption (research/benchmarks/expert-paths.md, sequencing pattern 1). It is also where the learner meets a real CVE at hour 40 (`FND-04`), so foundations are learnt against a real artefact rather than toy exercises. FND deliberately covers only x86-64; ARM and MIPS move to `EMB-01` because nothing in the core runs on them (DR-0001). Python and C are the two languages the job sample names most for low-level work (research/benchmarks/job-market.md, language tally).

## Outcome statement
"After this track you can build a real open-source C project at a pinned commit with sanitizers, reproduce a published crash, root-cause it to the line in C and in x86-64 assembly under gdb, and script a target process and debugger from Python."

## Concepts / Facts / Procedures
pending /research FND.

| Concepts (understand) | Facts (memorise) | Procedures (automate) |
|---|---|---|
| pending /research | pending /research | pending /research |

## Benchmarks
pending /research FND. Field-level benchmarks already filed: research/benchmarks/expert-paths.md, research/benchmarks/curricula-and-trainings.md, research/benchmarks/job-market.md, research/benchmarks/learning-science.md. Note: CTF-style practice is a labelled entry ramp only; its effectiveness evidence is rated Low to Very Low (research/benchmarks/learning-science.md, FIELD-SYNTHESIS finding 10).

## Emphasise
pending /research FND.

## Exclude
pending /research FND.

## Module path
Modules in recommended order within the track. The interleaved core order across tracks is in `curriculum/skill-tree.yaml` (node order) and DR-0001.

| # | Module | Hours | RDS | Direct target |
|---|---|---|---|---|
| 0 (conditional) | `FND-00-programming-on-ramp` Programming on-ramp in C: write, compile and debug small programs. Taken only if the learner fails the diagnostic after FND-01 (DR-0005); no prereq edges | 30 | turning a compiler error or a wrong output into the specific line that causes it, and fixing it | set by module-builder |
| 1 | `FND-01-linux-lab-and-learning-protocol` Linux workstation, the OSVR lab and the session protocol | 6 | running a declared-goal, timeboxed session that ends with free recall and a logged next step | set by module-builder |
| 2 | `FND-02-c-pointers-and-memory` C I: pointers, arrays, strings and where objects live | 18 | predicting where a C object lives and what writing past its end touches | set by module-builder |
| 3 | `FND-03-building-and-debugging-with-gdb-and-sanitizers` Building real C projects and debugging them with gdb and sanitizers | 10 | building an unfamiliar open-source project at a pinned commit with ASan/UBSan and debug symbols | set by module-builder |
| 4 | `FND-04-first-cve-crash-reproduction` Reproduce a real CVE crash and root-cause it to the line | 6 | walking an ASan report back from the crash frame to the line that broke the invariant | set by module-builder |
| 5 | `FND-05-c-structs-integers-and-undefined-behaviour` C II: structs, dynamic memory, integer semantics and undefined behaviour | 18 | spotting the integer conversion or lifetime error that turns a length check into an out-of-bounds access | set by module-builder |
| 6 | `FND-06-x86-64-assembly-through-gdb` x86-64 assembly read and stepped through gdb | 22 | reading a function's prologue, epilogue and stack frame live in gdb and mapping it back to C | set by module-builder |
| 7 | `FND-07-linux-process-internals-elf-and-linking` Linux process internals: ELF, loader, syscalls, virtual memory, PLT/GOT | 16 | tracing a library call from the call site through the PLT and GOT to libc in a running process | set by module-builder |
| 8 | `FND-08-python-exploit-tooling` Python tooling for exploitation and research (pwntools, scripted debugging) | 8 | scripting interaction with a target process and a debugger so every attempt is one command | set by module-builder |

Total hours: 104 without the on-ramp, 134 with it (about 10 or 13 weeks at 10 h/week; pilot parameters, not measured figures).

Entry: complete FND-01 (no programming needed), then take the FND-00 diagnostic (90 min, any language: write a ~50-line file-processing program to spec, fix a seeded bug in a ~40-line program, predict a short program's output). Pass: go to FND-02. Fail: FND-00, then retake the diagnostic in C. FND-02 is linked to the diagnostic from its Prerequisite check and carries a short C-syntax-for-programmers section for learners who passed in another language.

## Midpoint check
At `FND-05` (after the first CVE reproduction and before assembly) the learner revisits this map: was C I enough to follow the CVE fix, and is the pace sustainable at their weekly hours? The coach prompts this and records actual hours against estimates.

## Track capstone
None separate. `FND-04` (real CVE crash to the line) is the track's proof point, repeated at higher difficulty in `VD-03` and `RE-04` (spiral).
