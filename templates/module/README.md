# <MODULE_ID>: <Title>

Track: <TRACK>   Hours: N   Prereqs: <ids>   Status: drafting
Outcomes: <map | find | rootcause | exploit | disclose>

## Objectives
After this module you can:
1. <testable verb> ...
2. ...
3. ...

## Where this shows up in the wild
- <real bug, one line, from research/>
- ...

## Mitigation context
| Mitigation | On in this module? | What it blocks | How this module deals with it |
|---|---|---|---|

## Prerequisite check
Answer these closed-book (3 to 5 questions or one tiny task, under 10 minutes). Then pick your route:
- All correct **and** you have used this technique before: skip the worked example and go straight to the struggle challenge.
- Otherwise: study the worked example first.

<check>

## Worked example
A solved instance that is **different** from the struggle challenge (different binary, input or constraint), broken into labelled subgoals (e.g. *leak*, *groom*, *corrupt*, *redirect*). For each subgoal, state its goal before the steps, then show the steps and the debugger evidence.

<worked example>

## Struggle challenge
Attempt this closed-book before reading further. Timebox: N minutes (pilot parameter; log your actual time before first hint). Write down what you tried, even if you fail.

<challenge>

## Theory
Mechanism first: data structures, invariants, and exactly which invariant the bug breaks.

## Walkthrough (spoilers)
Step-by-step on the warm-up target, with debugger output at each step.

## Consolidation
Put your struggle-challenge attempt next to the reference solution. Write down, per subgoal: what you did, what the solution does, and the gap in one line. Turn each gap into a card.

## Common failure points
| Symptom | Likely cause | How to see it (debugger command) |
|---|---|---|

## Next
Drills: `drills.md`. Project: `project.md`. Cards: import with `python3 scripts/srs.py import <MODULE_ID>`.
