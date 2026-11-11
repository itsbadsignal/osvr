# OSVR: Open Security Vulnerability Research

OSVR is a curated, ordered path through **existing** learning resources (courses, wargames, books, papers, docs) for vulnerability research. It takes a self-taught learner from "can use a terminal" to finding, root-causing, exploiting and disclosing previously unknown vulnerabilities.

**OSVR does not write course content.** No modules, lessons, drills, flashcards, labs, rubrics or coaching. The work is choosing, ordering, verifying and maintaining links to other people's material. If a request would add original teaching content, say so and ask before doing it.

## Repository layout

```
README.md          the curriculum: sections, tables of resources, milestones
FAQ.md             learner questions
CONTRIBUTING.md    how to propose, replace or remove a resource
research/          evidence behind the ordering and resource choices (domain maps, benchmarks, target shortlists)
.claude/agents/    researcher (find and verify resources), maintainer (link and freshness checks)
```

## The curriculum (README.md)

- Sections in order: Foundations, Reverse engineering, Binary exploitation, Vulnerability discovery, Disclosure and professional practice, Specialisations, Final project, Extras.
- Each section is one or more tables with columns `| | Resource | Cost | Effort | Notes |`. The first column is one of:
  - **Core**: do it, in order.
  - **Alt**: replaces the row above it.
  - **Ref**: reference to keep open, not to read through.
  - **Practice**: open-ended exercise source.
  - **Read**: a single article or writeup.
  - **Paid**: best-in-class paid option, always with price if the page states it.
- Each section ends with a **Milestone**: a concrete thing the learner does with the listed material to prove readiness. Milestones point at existing resources; they are not new content.
- **Cost policy**: pick the best resource for each step regardless of cost. Prefer free when quality is comparable. Mark paid resources clearly and list a free alternative when one exists.
- **Effort**: only what the provider states (challenge counts, stated hours, page counts). Never estimate hours.
- One line of notes per row, saying why it is there or what to watch for (dated mitigations, closed contests, version caveats).

## Source integrity (absolute)

1. Never add a URL, title, author, price, date or CVE number from memory. Fetch the page, confirm it exists and says what the row claims, then add it.
2. If a page cannot be fetched, do not add it. Note it in the PR or report as unverified.
3. Prefer primary sources: the course's own page, the publisher's page, the author's own writeup, official docs.
4. Flag dated material in the Notes column (e.g. "2015-era mitigations", "last updated 2022").
5. Record new or rechecked resources in the relevant `research/` file with `verified: YYYY-MM-DD`, and update the "Links were last checked" date in README.md.

## Inclusion criteria

A resource earns a row only if it:
- teaches by doing (exercises, challenges, labs) or is the clear reference for its topic;
- is current enough to be useful, or its age is flagged;
- is legally accessible (no piracy, nothing that requires attacking systems you do not own);
- covers something no existing row covers better.

Remove or demote rows that go dead, go stale without a flag, or are superseded.

## Ethics

All hands-on work in the curriculum happens in labs the learner controls, on CTF/wargame infrastructure, on archived vulnerable versions, or inside a published bug-bounty scope. Do not add resources that point learners at live third-party systems. Point to local law and programme safe-harbour terms; do not give legal advice.

## Agents

| Agent | Job |
|---|---|
| `researcher` | Find candidate resources for a section, fetch and verify them, write findings to `research/` |
| `maintainer` | Re-check every link in README.md, flag dead/moved/changed resources, propose replacements via the researcher |

## Writing style

Direct, no filler. Never use em dashes (—) or en dashes (–); use commas, colons, full stops or "to" for ranges. Notes column: one short line.
