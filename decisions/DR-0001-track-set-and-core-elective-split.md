# DR-0001: Track set, core/elective split and core sequencing

Date: 2026-11-10   Status: accepted (approved by the user on 2026-11-10)

## Context
First architecture pass. Inputs: `research/FIELD-SYNTHESIS.md` (sections 1, 2, 5) and the five files it cites: `research/benchmarks/curricula-and-trainings.md` [CUR], `research/benchmarks/expert-paths.md` [EXP], `research/benchmarks/job-market.md` [JOB], `research/domain-maps/field-overview.md` [FLD], `research/benchmarks/learning-science.md` [LSC].

Evidence that drives the split:
- Hiring asks for OS internals, RE, code audit, one real explainable find and written reporting. No live posting in the sample requires Linux-kernel or browser exploitation specifically [JOB tallies, observation 4]. So the hiring-critical spine is FND, RE, BX, VD, PRO; kernel, hypervisor, browser, Windows and mobile are depth options.
- Free curricula share one order (tooling, RE, stack, format string, mitigations one at a time, heap, kernel) and put fuzzing last; none teach patch diffing, variant analysis or disclosure [CUR section 2].
- Environment setup costs more than finding the bug [EXP sequencing pattern 5, recurring advice; FIELD-SYNTHESIS finding 5].
- Finding and exploiting are separate skills [EXP disagreements, Hypr; FIELD-SYNTHESIS finding 6].
- Logic, injection and auth classes outnumber memory corruption in KEV 2025-26 and dominate appliance 0-days [FLD facts: KEV, GTIG-2025, P2O-I1].
- 13 of 31 postings expect AI as a target or as a research accelerant [JOB skill tally].

## Options

### A. Track set
1. **Keep the seed set unchanged** (FND, RE, BX, VD, PRO core; LK, WIN, BRW, EMB, MOB, HV electives). Pros: matches CLAUDE.md. Cons: EMB scope as "embedded and firmware" misses the appliance web-admin and daemon surface where most 2025 edge 0-days sit [FLD]; capstones have no place in the DAG, so their prereqs are not validated.
2. **Seed set, EMB widened to "embedded, firmware and appliances", plus a `CAP` track for the two graduation capstones, AI-assisted VR as a cross-cutting module inside VD** (chosen). Pros: EMB matches the field's first-0-day class; capstone prereqs are checked by `validate.py`; AI work stays attached to the find workflow it accelerates. Cons: one extra track ID; `CAP` module directories would sit under `curriculum/tracks/CAP/` while CLAUDE.md lists `curriculum/capstones/` (see Consequences).
3. **Add an `AI` track** (AI-assisted VR plus attacking agentic systems). Pros: visibility for a fast-growing hiring signal. Cons: no research on bug classes in agentic systems exists in `research/`; AI-assisted VR is a technique applied inside fuzzing, triage and variant analysis, not a separate target domain; a track would invite tool-tour content. Rejected for now.

### B. Core/elective split
1. **Core = FND, RE, BX, VD, PRO, CAP; electives = EMB, LK, HV, WIN, MOB, BRW** (chosen). Electives ordered by first-0-day reachability and hiring value per FIELD-SYNTHESIS section 2: EMB, LK, HV, WIN, MOB, BRW.
2. **Put EMB in the core** because it is the synthesis's recommended first-0-day class. Rejected in DR-0003: firmware is mostly proprietary (core constraint wants an open-source hunt), adds about 28 h of ARM/MIPS and extraction work, and puts the highest environment-friction risk [EXP, Hypr: about a year with untriggerable bugs] at the most fragile point of the core.

### C. Where AArch64 assembly lives
1. **In FND** (seed hypothesis). Pros: hiring names x86/ARM assembly. Cons: only 3-4 postings require it, mostly hardware/embedded [JOB language tally, implication 8]; nothing in the core needs it; costs about 10-12 h before the first exploit.
2. **As the entry module of EMB (ARM and MIPS for firmware), reused by MOB** (chosen). Prerequisite honesty: the core never executes on ARM.

### D. Core sequencing
1. **Canonical free-curriculum order, then VD, then PRO at the end.** Rejected: fuzzing last, disclosure bolted on, first real artefact late [CUR].
2. **Canonical order compressed for the exploitation spine, with VD and PRO interleaved and the first real bug hunt placed before the heap block** (chosen). Specifics:
   - First real CVE contact at hour 40: `FND-04` reproduces a real CVE crash in a pinned open-source C project under ASan and root-causes it to the line, using only C basics and gdb. Satisfies the 40 h constraint and gives "find" work its first real artefact before assembly.
   - Fuzzing in the first sixth of the core: `VD-02` (hours 77-95) needs only C, build systems and sanitizers, not assembly or exploitation (prereq honesty), so it can run before `FND-06`.
   - N-day patch diffing as the bridge: `RE-04` binary patch diffing feeds `BX-05` (first real N-day exploit) and `VD-06` (variant analysis from a fix).
   - Lab parity before the hunt: `VD-08` (emulation, debugger attach, harness stability, remote/local parity).
   - Separate find and exploit work: VD modules carry find-side RDS and rubrics; BX modules carry exploit-side RDS and rubrics, with N-days as exploit practice.
   - Logic, injection and auth bug classes as a full module: `VD-05`.
   - Mitigation-era sequence: no mitigations (`BX-01`), then each mitigation with its bypass (`BX-03`, `BX-04`), then a real N-day under default-era mitigations (`BX-05`), then immediately what CET/CFI kill (`BX-06`). Heap repeats the pattern: internals, classes, modern-glibc techniques, real N-day.
   - First real bug hunt (`VD-10`) at hour 384-424, before the heap block. A hunt needs triage, audit, fuzzing, lab parity and target selection, not ptmalloc internals (prereq honesty). Putting the hunt first gives the slowest-feedback activity (time-to-first-bug is long [EXP first-bug table]) the earliest start, and gives the learner a real-world attempt before the "quit at the first heap exploit" failure point.
   - PRO interleaved: `PRO-01`/`PRO-02` right after the first CVE repro, `PRO-03` after the first N-day exploit, `PRO-04`/`PRO-05` before the hunt, `PRO-06` after it, `PRO-07` at the end.
3. **Hunt after heap** (hunt at about hour 460). Pros: learner can assess heap exploitability of what they find. Cons: later start on the longest-latency task; heap is not a prerequisite for finding or root-causing. Rejected; exploitability of a found heap bug is handled in `CAP-02`.

### E. Cut or deferred from the seed
- **Attacking agentic/LLM systems** (category-B postings [JOB implication 3]): deferred, no research exists. Not in the tree.
- **"Odds and ends" BX unit** (integers, races, C++) from the canonical order [CUR]: integers and UB go to `FND-05`; races and C++ type confusion are revisited in LK and BRW (spiral) and taught as bug classes in `VD-01`/`VD-04`. No separate BX module.
- **Symbolic execution**: absent from expert accounts and postings in the research; not in the tree.

## Decision
Track set: FND, RE, BX, VD, PRO, CAP (core); EMB (renamed "Embedded, firmware and appliances"), LK, HV, WIN, MOB, BRW (electives, in that recommended order). AI-assisted VR is the cross-cutting module `VD-07` and recurs as drills in later VD and capstone work; it is not a track. AArch64 moves to `EMB-01`. Core order as in D2.

Core hours (module estimates, pilot-unverified): FND 104, RE 60, BX 152, VD 156, PRO 42, CAP 140; total 654 h, about 15 months at 10 h/week. Excluding capstones: 514 h. Electives (placeholders): EMB 68, LK 76, HV 60, WIN 80, MOB 56, BRW 78. Track metalearning (MAP review, the ~10% planning budget from `docs/ULTRALEARNING.md`, itself unsourced [LSC ledger]) is on top of this.

Hours rationale: no provider publishes hours from zero [CUR "Hour totals"]. Sourced anchors: a semester (about 150 h) reaches classic stack/ROP/heap; modern heap plus kernel adds an inferred 100-200 h; Konovalov's kernel course is about 32-36 h after userland. OSVR's FND+RE+BX is 316 h, about twice the semester anchor, because the target learner may start at "can use a terminal", and because the core adds find, disclose and real-target work that no semester course includes. Treat every `hours:` value as a pilot parameter.

## Consequences
- Modules: 40 core module nodes plus 3 capstone nodes (the 0-day lifecycle capstone is split into hunt/root-cause and exploit/disclose to give a checkpoint and keep nodes under 60 h); 21 elective placeholder nodes.
- `CAP` layout: `validate.py` expects module directories at `curriculum/tracks/CAP/modules/<id>/`; CLAUDE.md lists `curriculum/capstones/`. Needs the user's call: either move capstone content under `tracks/CAP/` and repurpose `curriculum/capstones/` for briefs, or teach the validator to look in `curriculum/capstones/` for `CAP-*`.
- Each elective track's final node must end with a disclosure deliverable (PRO attachment), per FIELD-SYNTHESIS finding 3. Specified when each elective is designed.
- Rubrics: module-builder writes separate find-side and exploit-side rubric sections where a module touches both.
- Watch: actual hours per module in pilot logs; whether `VD-02` before assembly overloads learners; whether the early hunt produces motivation or discouragement (log weeks active before and after `VD-10`).
- Revisit when `/research` runs for any track, at the track midpoint, or after the first pilot learner reaches `VD-10`.
