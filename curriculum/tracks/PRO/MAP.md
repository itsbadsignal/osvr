# PRO: Professional practice and disclosure (metalearning map)

Updated: 2026-11-10   Research: pending /research PRO (CVD process, CNA routes, programme policies)   Decisions: DR-0001, DR-0002, DR-0004

Status: stub. Why, Outcome statement and Module path are set by the architect; the other sections wait for track-level research.

## Why
PRO serves disclose. Written reporting is the most frequently required skill in the job sample, and hiring asks for one personally-found bug the candidate can explain, with public writeups as a recurring signal (research/benchmarks/job-market.md). Disclosure appears in only one syllabus read (research/benchmarks/curricula-and-trainings.md). PRO is woven through the core, not appended: ethics and advisory-reading at hours 40-49, a public N-day writeup right after the first N-day exploit, disclosure and programme rules before the first hunt, a real disclosure run after it.

## Outcome statement
"After this track you can write a vendor-grade advisory and a public technical writeup a reader can reproduce cold, run coordinated disclosure through a vendor or CNA fallback to a CVE or fix, and map your public artefacts to the evidence a specific posting asks for."

## Concepts / Facts / Procedures
pending /research PRO.

| Concepts (understand) | Facts (memorise) | Procedures (automate) |
|---|---|---|
| pending /research | pending /research | pending /research |

## Benchmarks
pending /research PRO. Field-level benchmarks already filed: research/benchmarks/expert-paths.md, research/benchmarks/curricula-and-trainings.md, research/benchmarks/job-market.md, research/benchmarks/learning-science.md. Note: CTF-style practice is a labelled entry ramp only; its effectiveness evidence is rated Low to Very Low (research/benchmarks/learning-science.md, FIELD-SYNTHESIS finding 10).

## Emphasise
pending /research PRO.

## Exclude
pending /research PRO.

## Module path
Modules in recommended order within the track. The interleaved core order across tracks is in `curriculum/skill-tree.yaml` (node order) and DR-0001.

| # | Module | Hours | RDS | Direct target |
|---|---|---|---|---|
| 1 | `PRO-01-ethics-scope-and-legal-landscape` Ethics, scope and the legal landscape for research | 4 | deciding from a programme's published scope and safe-harbour text whether a planned test is in bounds | set by module-builder |
| 2 | `PRO-02-advisories-cve-and-cwe` Reading advisories, the CVE system and CWE | 5 | extracting affected versions, root cause, CWE and fix commit from a real advisory and its references | set by module-builder |
| 3 | `PRO-03-technical-writeup-of-an-n-day` Writing a public technical writeup of an N-day | 6 | explaining the bug to the line and the exploit step by step so a reader can reproduce it cold | set by module-builder |
| 4 | `PRO-04-coordinated-disclosure-and-advisories` Coordinated disclosure and writing a vendor-grade advisory | 8 | writing a reproduction section a vendor triager can follow cold | set by module-builder |
| 5 | `PRO-05-bounty-and-vendor-programmes` Bug bounty and vendor programmes, duplicates and triage | 5 | reading a programme's scope, AI-report and duplicate rules and deciding where a finding should go | set by module-builder |
| 6 | `PRO-06-disclosure-run-and-public-writeup` Run disclosure on your hunt result and publish the writeup | 10 | keeping a disclosure moving: first contact, follow-ups, CNA fallback, publication timing | set by module-builder |
| 7 | `PRO-07-portfolio-and-hiring-map` Portfolio, hiring evidence and role gates | 4 | matching your public artefacts to the evidence a specific posting asks for | set by module-builder |

Total hours: 42  (about 4 weeks at 10 h/week; pilot parameter, not a measured figure)

## Midpoint check
At `PRO-04` the learner compares their `PRO-03` writeup against the advisory template and the assessor's feedback; coach prompts.

## Track capstone
`PRO-06` (disclosure run on the learner's own hunt result) and the disclosure half of `CAP-02`.
