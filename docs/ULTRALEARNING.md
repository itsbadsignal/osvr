# Ultralearning applied to vulnerability research

Reference for module-builder, curriculum-auditor and the coach. The principles come from Scott Young's *Ultralearning* (2019). This file translates each into concrete design and teaching moves for VR / exploit development. Read the section you need, not the whole file.

## 1. Metalearning

Before a track is built, answer three questions in `MAP.md`:

- **Why**: which terminal outcomes (map, find, rootcause, exploit, disclose) this track serves, and for which kind of target.
- **What**: split the track's knowledge into
  - *Concepts* to understand (e.g. how ptmalloc bins work, why ASLR entropy matters)
  - *Facts* to memorise (struct offsets that recur, calling conventions, syscall numbers you will use constantly, mitigation flags)
  - *Procedures* to practise until automatic (setting up a debug session, writing a fuzz harness, building a ROP chain)
- **How**: benchmark against how experts actually got there. Sources: public career writeups by known researchers, syllabi of serious trainings (as structure references, not things the learner must buy), job descriptions for VR roles, and the public writeups behind real CVEs in the domain. Record an *emphasise* list (what experts lean on that tutorials skip) and an *exclude* list (popular content that is outdated or low yield).

Budget roughly 10% of track hours for this, and revisit the map at the track midpoint.

## 2. Focus

Coach session protocol:

1. Learner states one concrete session goal ("get a leak from the format string in module BX-04").
2. Timebox declared (default 50 min work / 10 min break).
3. Distractions written to a log, not acted on.
4. Session ends with 3-minute free recall: what did you learn, without notes.
5. Coach writes a session log to `learner/sessions/YYYY-MM-DD.md`.

Procrastination counters: start with a 5-minute "just open the debugger" commitment; never end a session at a natural stopping point (leave the next step obvious).

## 3. Directness

Learning transfers poorly. Learn the skill in the context you will use it.

- Every module's project hits a real artefact: a real CVE reproduction at a pinned vulnerable version, a real open-source codebase, real firmware.
- Toy binaries are allowed only as a warm-up within a module that ends on a real target.
- Use the real tools of the trade (gdb + pwndbg/gef, Ghidra/IDA/Binary Ninja, AFL++, libFuzzer, CodeQL, WinDbg), never simplified course-only tools.
- Writeups are written as if they were going to a vendor or a public blog. Disclosure practice is part of the skill, not an appendix.

## 4. Drill

Find the **rate-determining step**: the sub-skill that bottlenecks overall performance. Common ones in VR:

| Domain | Typical rate-determining step |
|---|---|
| Stack/ROP | finding and chaining gadgets under constraints |
| Heap | predicting allocator state after a sequence of operations |
| Format strings | computing offsets and write sizes |
| Fuzzing | writing a harness that reaches deep state |
| Code audit | tracing attacker-controlled data across function boundaries |
| Kernel | turning a weak primitive into a useful one (heap grooming, cross-cache) |
| Browser | turning a JIT/type confusion into addrof/fakeobj |
| RE | recovering structures and intent from stripped code |

Drill types to use in `drills.md`:

- **Time-sliced**: isolate one phase of a full exploit (only the leak, only the pivot).
- **Cognitive component**: train the mental model directly (given this malloc/free sequence, draw the bins; given this function, list every tainted variable).
- **Copycat**: reproduce a public exploit step by step, then do it again from memory.
- **Magnifying glass**: spend 10x normal time on one hard component.
- **Prerequisite chaining**: start at the hard thing, back-fill prerequisites only when blocked.

## 5. Retrieval

Testing is learning. Never let the learner read the solution before trying.

- Each module opens with a short **prerequisite check**, then a closed-book **struggle challenge**. Learners meeting the technique for the first time study a subgoal-labelled worked example (on a different instance) before the challenge; every route ends with consolidation against the reference solution (DR-0004). Evidence: unguided discovery underperforms explicit instruction for novices, while problem-solving before instruction helps only with prior knowledge and consolidation (`research/benchmarks/learning-science.md` sections 6 and 7).
- `cards.yaml` decks use free recall, not recognition: "Write the tcache poisoning steps on glibc 2.32+ including safe-linking", not "Which of these is tcache poisoning?".
- Card types: `fact`, `concept`, `procedure`, `diagram` (learner draws then compares), `code` (learner writes then compares).
- Bad card: answer is visible in the question wording. Bad card: answer is a whole paragraph to memorise verbatim. Split those.

## 6. Feedback

Label feedback by type so the learner knows what to do with it:

- **Outcome**: did it work (flag, shell, crash). Automated checkers in labs.
- **Informational**: where it went wrong (crash triage, debugger state, assessor notes on which step failed).
- **Corrective**: how to fix it (assessor gives the specific change). Use only after the learner has tried to self-correct.

Feedback should be fast and frequent. Prefer a checker that returns in seconds over a weekly review. Public feedback (CTF scores, published writeups, bounty triage responses) is the highest-signal kind; the PRO track pushes learners toward it early.

## 7. Retention

- Spaced repetition via `scripts/srs.py` on `learner/cards.yaml`. 15 minutes daily beats 2 hours weekly.
- **Proceduralisation**: build full exploits repeatedly, not once. A technique is retained when the learner can do it on a fresh binary without notes.
- **Overlearning**: after passing a module, do one project a level above (e.g. same technique, extra mitigation).
- **Leeches**: cards failed 4+ times get rewritten or split, not drilled harder.

## 8. Intuition

- **Struggle rule**: attempt for at least 20 minutes (or one full timebox for projects) before taking a hint. The coach enforces the hint ladder. The 20 minutes is a pilot parameter with no published source (DR-0004): log time-to-first-hint in every session and tune it from pilot data.
- **Prove it**: derive things instead of accepting them. Why does a canary stop this overflow but not that one? Why is an arbitrary read plus a controlled free enough here?
- **Feynman**: explain the bug and exploit in plain language to an imagined smart non-specialist; gaps in the explanation are gaps in understanding. Graded by the assessor.
- Study the bug, not just the exploit: why did the developer write that code? What invariant broke?

## 9. Experimentation

- **Copy, then create**: reproduce a public exploit, then change one thing (different primitive, different target version, added mitigation, stripped binary).
- **Constraints**: "exploit this without a leak", "no one_gadget", "under 200 bytes".
- **Explore extremes**: capstones are open-ended. The learner picks the target, the approach, and the definition of success, with the coach only advising.

## Hint ladder (coach)

0. Restate the goal and ask what they have tried.
1. Point to the region: "look at what happens to the size field on line 140".
2. Ask a guiding question: "what does free() trust about that field?"
3. Name the concept: "this is a tcache double free, check how 2.29+ detects it".
4. Show a partial step or pseudocode for the current sub-step only.
5. Full solution for the current sub-step, followed immediately by a retrieval test and a variation to do unaided.

Never skip rungs unless the learner explicitly invokes `solution` after the struggle rule, and even then log it in `learner/error-log.md`.
