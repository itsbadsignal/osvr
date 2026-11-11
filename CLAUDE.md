# OSVR: Open Security Vulnerability Research

OSVR is a self-learning curriculum that takes a motivated learner with no degree from zero to independently finding, root-causing, exploiting and responsibly disclosing previously unknown vulnerabilities (0-days). It replaces the university pathway with an Ultralearning pathway: self-directed, aggressive, project-driven, measured by what the learner can do, not what they have read.

This file is the constitution. Every agent, skill and prompt in this repo defers to it. If a request conflicts with this file, say so and ask before proceeding.

## Operating modes

Identify the mode before acting. State it in one line at the start of non-trivial work.

| Mode | Purpose | Entry | Primary actors |
|---|---|---|---|
| BUILD | Research, design and write curriculum content | `/research`, `/design`, `/build-module`, or plain requests to create content | curriculum-architect, researcher, module-builder, lab-engineer |
| MAINTAIN | Audit, refresh, fix rot, absorb new research | `/audit`, `/maintain` | curriculum-auditor, maintainer, researcher |
| COACH | Teach a learner using the curriculum | `/coach`, `/drill`, `/review`, `/diagnose`, `/submit` | main thread (coach persona), assessor |

In COACH mode the rules in `.claude/skills/coach/SKILL.md` override BUILD conventions. Never edit curriculum content while coaching; log the defect to `maintenance/inbox.md` instead and keep teaching.

## Target learner

- Background: anywhere from "can use a terminal" to working IT/SOC/cloud professional. No degree assumed. Often self-taught, often a college dropout.
- Constraints: studies part-time (8 to 20 h/week), limited budget, Linux daily driver, can run Docker and VMs.
- Motivation: wants real capability and a portfolio of real findings, not certificates. Certs are optional side quests, never the spine.
- Failure modes to design against: tutorial hell, collecting resources instead of doing, passive video watching, skipping fundamentals, quitting at the first heap exploit.

## Terminal outcome

A graduate can, without guidance:

1. **Map**: pick a real target and produce an attack-surface map with prioritised entry points.
2. **Find**: discover a previously unknown bug through manual audit, fuzzing or variant analysis, and check that it is novel (not already fixed upstream, reported, or a known fuzzer hit) before reporting.
3. **Root-cause**: explain the bug to the line, the bug class (CWE), and the reachable primitive.
4. **Exploit**: build a reliable exploit against modern mitigations on a current target, in a lab they control. For non-memory bug classes (injection, auth bypass, logic), a reliable proof of concept that demonstrates the real impact satisfies this outcome. Reliability is measured, not asserted: run at least 20 times on a fresh target state with the success rate reported; default pass line 70% (from kernelCTF's stability scoring), tunable per track with the reason in the track MAP. Graduation still requires at least one memory-corruption exploit against modern mitigations (`CAP-03`). See DR-0002.
5. **Disclose**: write a vendor-grade advisory, run coordinated disclosure through to a CVE or fix, and publish a technical writeup that explains the bug to the line once the disclosure timeline allows.

Every node in the skill tree must trace to at least one of these five outcomes (`outcomes: [map, find, rootcause, exploit, disclose]`). Content that traces to none is cut.

## Ultralearning contract

Scott Young's nine principles are not decoration. Each is implemented as a concrete mechanic, and the auditor checks for it.

| Principle | Mechanic in OSVR | Enforced where |
|---|---|---|
| Metalearning | Each track opens with a map: concepts / facts / procedures split, expert benchmarks, emphasise / exclude list, ~10% of track time budgeted for planning | `curriculum/tracks/*/MAP.md`, `/research` |
| Focus | Session protocol: declared goal, timebox, distraction log, end-of-session recall. Sessions logged | coach skill, `learner/sessions/` |
| Directness | Every module is anchored to a real target, real CVE or real codebase. Toy examples only as stepping stones to a real artefact in the same module | module DoD rule D1 |
| Drill | Each module names its rate-determining step and ships isolated drills for it (time-sliced, cognitive-component, copycat) | `drills.md` |
| Retrieval | Closed-book challenges before solutions; free-recall prompts; flashcards generated per module; hint ladder delays answers | `cards.yaml`, coach hint ladder |
| Feedback | Automated (lab flag/checker), assessor rubric grading, public feedback (writeups, CTFs, disclosures). Feedback type labelled outcome / informational / corrective | `rubric.md`, assessor agent |
| Retention | Spaced repetition via `scripts/srs.py`; overlearning projects one level above; proceduralisation via repeated full exploit builds | `/review`, `learner/cards.yaml` |
| Intuition | Feynman explanations graded; "derive it" tasks (why a mitigation works, why a primitive is enough); struggle rule before hints | `project.md` Feynman section, coach struggle rule |
| Experimentation | Copy then create: reproduce a public exploit, then vary target / primitive / constraint; capstones are open-ended | `project.md` variations, capstones |

## Repository layout

```
CLAUDE.md                      this file
README.md                      front door: points learners to curriculum/README.md
curriculum/
  README.md                    learner map, generated by scripts/build_index.py (never edit by hand)
  skill-tree.yaml              the DAG: every node, prereqs, outcomes, hours. Source of truth for sequencing
  tracks/<TRACK>/              one directory per track, including CAP (graduation capstones, DR-0006)
    MAP.md                     metalearning map for the track
    modules/<MODULE_ID>/
      README.md                objectives, theory, walkthrough, struggle challenge
      drills.md                rate-determining-step drills
      project.md               direct project on a real target + variations + Feynman task
      rubric.md                assessment rubric
      cards.yaml               retrieval cards (seed deck)
      resources.yaml           verified resource cards
      lab/                     Dockerfile / VM spec / checker, if the module needs one
research/
  domain-maps/                 raw research per domain (researcher output)
  benchmarks/                  expert paths, job postings, existing curricula analysed
decisions/                     DR-NNNN-*.md design decision records
labs/shared/                   base images reused across modules
maintenance/
  inbox.md                     defects reported from coaching or audits
  reports/                     audit and freshness reports, dated
  CHANGELOG.md
learner/                       learner state (gitignored in the public repo; see templates/learner/)
templates/                     canonical schemas. Never deviate without a decision record
scripts/validate.py            structural checks: DAG, DoD files, resource freshness
scripts/srs.py                 spaced repetition scheduler for learner/cards.yaml
scripts/build_index.py         regenerates curriculum/README.md from skill-tree.yaml
```

## Identifiers

- Track IDs: two to four uppercase letters. Seed set: `FND` foundations, `RE` reverse engineering, `BX` binary exploitation, `VD` vulnerability discovery, `LK` Linux kernel, `WIN` Windows, `BRW` browsers, `EMB` embedded/firmware, `MOB` mobile, `HV` hypervisors, `PRO` professional practice, `CAP` graduation capstones (DR-0006). The architect may change this set via a decision record.
- Module IDs: `<TRACK>-<NN>-<slug>`, e.g. `BX-07-tcache-poisoning`. NN is a two-digit order within the track. IDs never get reused; deprecated modules keep their ID with `status: deprecated`.

## Module Definition of Done

A module is `status: ready` only when all of these hold. `scripts/validate.py` checks the structural ones; the auditor checks the rest.

- **D1 Directness**: `project.md` targets a real artefact (named CVE, real open-source codebase at a pinned commit, real firmware image, or a CTF challenge that mirrors a real bug class with a cited real-world analogue).
- **D2 Objectives**: 3 to 7 objectives, each observable and testable (verbs like *exploit, root-cause, write, bypass, explain, triage*; never *understand, learn about, be familiar with*).
- **D3 Rate-determining step**: `drills.md` names the single hardest sub-skill and gives at least 3 drills isolating it.
- **D4 Retrieval**: `cards.yaml` has at least 12 cards, mixed between facts, concepts and procedures, none answerable by pattern-matching the question wording.
- **D5 Struggle challenge, conditional on prior knowledge** (DR-0004): `README.md` opens with a short prerequisite check, then a subgoal-labelled worked example, then a closed-book struggle challenge on a different instance, then the walkthrough, then a consolidation step. A learner who passes the prerequisite check and has met the technique before skips the worked example and attempts the challenge cold. A learner meeting the technique for the first time studies the worked example first. Every path ends with consolidation: comparing their own attempt to the reference solution and naming the gap.
- **D6 Feedback**: `rubric.md` exists with pass criteria the assessor can apply without guessing; labs have an automated checker where possible.
- **D7 Sources**: every entry in `resources.yaml` has `verified:` within the last 180 days and was actually fetched, not recalled.
- **D8 Prereqs**: all prereqs exist in `skill-tree.yaml`; no cycles; estimated hours stated.
- **D9 Mitigation era**: the module states which mitigations are in play (e.g. NX, ASLR, PIE, canaries, RELRO, CET/shadow stack, CFI, PAC, MTE, kASLR, SMEP/SMAP, KPTI) and does not teach a technique as current if modern defaults kill it without saying so.
- **D10 Ethics**: lab targets are local, intentionally vulnerable, or archived versions; nothing points the learner at systems they do not own.

## Source integrity

Fabricated resources are the main way an LLM-built curriculum rots. These rules are absolute.

1. Never write a URL, book title, author, talk, CVE number or commit hash from memory into curriculum content. Fetch it, confirm it says what you claim, then record it with `verified: YYYY-MM-DD`.
2. If a source cannot be fetched (paywall, allowlist, dead), record it with `verified: null` and `status: unverified`, and say so in your report. Unverified sources cannot satisfy D7.
3. CVE claims must cite the vendor advisory, NVD/MITRE record, or the researcher's own writeup.
4. Prefer primary sources: vendor advisories, original researcher writeups, conference talks (slides or video), papers, source code, man pages, ISA manuals. Aggregators and listicles are leads, not sources.
5. When you are unsure whether a technique still works on current defaults, say so and mark the claim `needs-lab-verification` rather than guessing.

## Ethics and scope

OSVR teaches offensive skills for research, defence and responsible disclosure.

- All hands-on work happens in labs the learner controls, on CTF infrastructure, on archived vulnerable versions, or within the published scope of a bug bounty / vendor research programme.
- Every track includes the disclosure workflow; the PRO track covers coordinated vulnerability disclosure, CVE assignment, advisory writing, and the legal landscape (point learners to their local law and to programme safe-harbour terms rather than giving legal advice).
- Do not produce exploit content aimed at a specific live third-party system, or help a learner use course material against targets outside those bounds. If a learner asks for that in COACH mode, decline that part plainly and steer to a lab equivalent.
- Exploits for patched, public CVEs reproduced in a lab are core curriculum material and are fine.

## Agent roster

Subagents cannot spawn other subagents. Orchestration lives in skills, which run in the main thread and call agents.

| Agent | Model | Job | Writes to |
|---|---|---|---|
| `curriculum-architect` | opus | Skill tree, sequencing, track maps, decision records | `curriculum/skill-tree.yaml`, `tracks/*/MAP.md`, `decisions/` |
| `researcher` | sonnet | Find, fetch, verify and evaluate sources; benchmark experts and existing curricula | `research/` only |
| `module-builder` | opus | Write module content to the templates | `curriculum/tracks/*/modules/*` |
| `lab-engineer` | sonnet | Build reproducible labs, vulnerable targets, checkers | `modules/*/lab/`, `labs/shared/` |
| `curriculum-auditor` | opus | Read-only review against DoD and the ultralearning contract | report returned to caller |
| `maintainer` | sonnet | Freshness sweeps, link rot, deprecations, new-research intake | `maintenance/`, targeted fixes |
| `assessor` | opus | Grade learner submissions against rubrics | report returned to caller |

## Standard workflows

- **New track**: `/research <domain>` → `/design <track>` → `/build-module <id>` per module in DAG order → `/audit <track>` → fix → pilot with a real learner via `/coach` → absorb `maintenance/inbox.md`.
- **Change to sequencing or scope**: architect writes `decisions/DR-NNNN-<slug>.md` (context, options, decision, consequences) before editing `skill-tree.yaml`.
- **After any content change**: run `python3 scripts/validate.py` and fix errors, then `python3 scripts/build_index.py` to regenerate the learner map `curriculum/README.md`, before reporting done.

## Writing style for curriculum content

- Direct, second person, no filler, no motivational padding.
- Show the mechanism, not just the recipe: why the primitive exists, why the mitigation stops the naive version, what the bypass relies on.
- Code blocks are complete and runnable or explicitly marked `# sketch`.
- Use precise terms (UAF, type confusion, OOB write, arbitrary R/W, info leak, primitive, gadget) and define each the first time a track uses it.
- Prefer few em dashes; use commas, colons or full stops.
