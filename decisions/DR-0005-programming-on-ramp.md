# DR-0005: Conditional programming on-ramp (FND-00) gated by a diagnostic

Date: 2026-11-10   Status: accepted (direction approved by the user on 2026-11-10)

## Context
CLAUDE.md says the target learner starts anywhere from "can use a terminal" up to working IT/SOC professional. The core path assumes more than that. `FND-01-linux-lab-and-learning-protocol` (6 h) sets up the workstation and the session protocol and needs no programming. `FND-02-c-pointers-and-memory` (18 h) then teaches pointers, arrays and strings, and that only works for someone who can already write and debug a small program. So learners at the bottom of the stated range have no entry point.

Evidence on file:
- `research/benchmarks/expert-paths.md`, sequencing pattern 1: every documented path starts with programming, then assembly, then memory corruption. Alex Plaskett and the Interrupt Labs hiring page both name programming as a fundamental. None of these sources places programming inside a VR course. Each expert arrived already able to program.
- `research/benchmarks/learning-science.md` sections 6 and 7, already applied in DR-0004: novices gain from explicit instruction and worked examples, and expertise reversal means scaffolding that helps novices slows down learners who have the skill. A universal programming module would waste the time of the many learners who can already program and bore them.
- `research/benchmarks/job-market.md`, language tally: C and Python are the two languages named most for low-level work.
- There is no track-level FND research yet. The researcher is gathering `research/domain-maps/foundations.md`, and it will hold the on-ramp's resources. This DR does not wait for it. The language choice below is a design judgement and is open to revision on that file (see Consequences).

Prerequisite honesty (architect principle 4): FND-02 really requires that the learner "can write and debug a small program". That ability can come from anywhere: a job, a bootcamp, Python scripting at a SOC desk. An OSVR module is not the only source, so it cannot be a hard prereq edge.

## Options
1. **Hard prereq: FND-00 → FND-01 (or → FND-02) for everyone.** Pros: one path, and the validator checks it. Cons: the edge is dishonest because the skill can be met elsewhere. It adds about 30 h for the large share of learners who already program, and it is the "skip fundamentals, no wait, redo fundamentals" pattern that pushes experienced learners away (expertise reversal).
2. **No on-ramp, state "can program" as an entry requirement.** Pros: no new node, core hours unchanged. Cons: contradicts CLAUDE.md's stated learner range. Those learners would go and collect beginner courses on their own, which is the tutorial-hell failure mode CLAUDE.md designs against.
3. **Conditional on-ramp node with a diagnostic, no prereq edges in or out** (chosen). Learners who pass the diagnostic skip it. Pros: honest DAG, and it covers the whole stated range. FND-01 stays the root of the core path. Cons: the validator cannot enforce "take FND-00 if the diagnostic fails", so the coach must apply it. Core hours become a range rather than one number.

Sub-decision, the on-ramp language:
- **a. Python first.** Pros: gentler syntax, fewer early crashes, and the job market names it often. Cons: the learner learns a language and then switches to C within days. The memory model it hides is exactly what FND-02 to FND-05 teach. FND-08 already covers Python tooling at about hour 100, when the learner needs it for exploits.
- **b. C first** (chosen). Pros: directness. The next roughly 40 core hours (FND-02 to FND-04) and the first real CVE are in C, so on-ramp time compounds straight into FND-02. Compiler errors and crashes in a debugger are the domain's daily loop, so meeting them early is practice, not noise. There is one language until FND-08. Cons: harsher for a first-time programmer, and a higher dropout risk in the first 30 h. Mitigation: the on-ramp is worked-example-first throughout (DR-0004 novice route) and keeps undefined behaviour and manual memory management out of scope. Those stay in FND-02 and FND-05.
- **c. Both, briefly.** Rejected: twice the syntax load for the learner with the least capacity for it.

## Decision
Option 3 with sub-option b.

Node `FND-00-programming-on-ramp`. The ID is compliant: `validate.py` ID_RE accepts `\d{2}`, CLAUDE.md requires only a two-digit NN, and 00 marks a node that sits before the numbered path.
- title: Programming on-ramp in C: write, compile and debug small programs
- prereqs: `[]`. It needs only "can use a terminal", which the target learner already has. It is a second root, outside the core path.
- outcomes: `[rootcause]`. It builds the base skill of reading code to the line and locating the line that produces a wrong result.
- hours: 30. Pilot parameter: no source gives hours from zero (`curricula-and-trainings.md`, "Hour totals from zero").
- rds: "turning a compiler error or a wrong output into the specific line that causes it, and fixing it"
- Scope: variables and types, control flow, functions, arrays and strings at the level of use (not memory layout), reading input and files, splitting a program across functions, compiler warnings (`-Wall -Wextra`), printf debugging, and a first gdb breakpoint and backtrace. Out of scope: pointer arithmetic, heap allocation and UB. Those belong to FND-02 and FND-05.
- Direct target (D1, filled by the module-builder): the project ends on reading, building and changing a small real open-source C program at a pinned commit, not on toy exercises only.
- New optional node field `conditional:`. It holds a one-line string naming the gate. The validator ignores unknown fields. Any node with `conditional:` set is excluded from the "without on-ramp" core-hours figure in decisions and MAPs.

**Diagnostic** (the gate). The module-builder writes it as a short closed-book task in `FND-00`'s module directory. FND-01's final section and FND-02's Prerequisite check both link to it.
- Timebox 90 minutes, any language the learner already uses (the skill is language-agnostic). Three parts:
  1. Write a program of roughly 50 lines to a short spec that reads a file, processes records and prints a summary.
  2. Find and fix a seeded bug in a provided program of about 40 lines in the same language.
  3. Predict the output of a short program with a loop and a function call, then check by running it.
- Pass = all three parts correct within the timebox, without searching for the solution. A pass means skipping FND-00 and going to FND-02. Learners who pass in a language other than C get the C-syntax-for-programmers material that FND-02 must carry (see Consequences).
- Fail on any part means taking FND-00 and retaking the diagnostic in C at its end.

**Recommended order for a learner who cannot yet program:** FND-01 (lab and session protocol, no programming needed), then the diagnostic, then FND-00, then FND-02. This is a recommendation, not an edge. In `skill-tree.yaml` the node sits right after FND-01, matching this order.

## Consequences
- Tree: +1 node (65). Core hours are 654 without the on-ramp, about 15.1 months at 10 h/week, and 684 with it, about 15.8 months. Excluding capstones: 514 and 544. Both stay within the 12 to 18 month core target. `validate.py` prints the with-on-ramp figure (684) because it sums every core node. Use the 654 figure for learners who pass the diagnostic.
- FND track: 104 h without, 134 h with. `curriculum/tracks/FND/MAP.md` Module path updated.
- Builder notes:
  - FND-01 ends with a pointer to the diagnostic.
  - FND-02's Prerequisite check links to the diagnostic. Its Worked example must also carry a short "C syntax for programmers of another language" subsection, so a Python- or Java-only learner who passes the diagnostic is not blocked.
  - FND-00 itself is worked-example-first throughout (DR-0004 novice route).
- Proposed, outside the architect's write scope:
  - Add `conditional` to the field list in `templates/skill-tree.example.yaml`.
  - Optionally have `validate.py` print core hours both with and without `conditional:` nodes.
  - Have the coach skill run the diagnostic at the end of FND-01 when no diagnostic result is logged.
- Watch in the pilot:
  - Diagnostic pass rate.
  - FND-00 actual hours against 30.
  - Dropout inside FND-00.
  - Whether learners who completed FND-00 finish FND-02 in time comparable to those who passed the diagnostic.
- Revisit the language choice if `research/domain-maps/foundations.md` brings evidence that C-first raises novice attrition significantly against Python-first, or if pilot dropout in FND-00 is high.
