---
name: research
description: Run an OSVR metalearning research sweep for a domain or track (domain map, expert benchmarks, direct-target shortlist). Use when starting a new track or when the architect returns a research request.
argument-hint: "<domain or track, e.g. 'glibc heap exploitation' or BX>"
disable-model-invocation: true
---

# /research $ARGUMENTS

Mode: BUILD. Goal: produce the evidence base for "$ARGUMENTS" so the architect can design from facts, not memory.

1. Read `CLAUDE.md` and any existing files in `research/` for this domain. If a domain map exists and is under 90 days old, ask whether to extend it or start fresh.
2. Break the domain into 3 to 6 independent research briefs. Typical split:
   - Knowledge landscape and mitigation state (domain map)
   - Expert learning paths and training/university syllabi (benchmark)
   - Current job-market requirements for this specialisation (benchmark)
   - Real CVEs / codebases suitable as direct targets, with lab feasibility (targets)
   - Best free and paid learning resources, scored (resource cards)
3. Dispatch one `researcher` subagent per brief, in parallel. Each brief must state: the questions to answer, the output file path, and the format section of the researcher prompt to use.
4. When all return, read their files and write `research/<domain-slug>-SYNTHESIS.md`: the 5 to 10 findings that should shape design, conflicts between sources, unverified items the user should fetch manually, and a recommended track outcome statement.
5. Report to the user: synthesis summary, counts of verified vs unverified sources, and the suggested next command (`/design <TRACK>`).

Do not design modules in this skill.
