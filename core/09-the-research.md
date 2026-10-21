# 09 · The Research

> Stop being handed bugs.

**Requires:** [08 gate](08-the-theory.md) · **Hours:** 600–1,000+ · **Next:** [10 · Tracks](../tracks/README.md)

## Outcomes

- Select a target on your own reasoning and enumerate its attack surface.
- Audit a real codebase adversarially and find things.
- Build a fuzzing harness that finds bugs, not one that merely runs.
- Triage exploitability without assistance.
- Carry a finding through coordinated disclosure to resolution, in public, without harming users.

## Resources

| Role | Resource | Cost | Notes |
|------|----------|------|-------|
| Core | *The Art of Software Security Assessment* (Dowd, McDonald & Schuh, 2006) | ~€60 used | Still the only book-length treatment of code auditing as a methodology. Reading code adversarially hasn't changed. |
| Core | Read codebases alongside their CVE histories: the Linux kernel, OpenSSL, SQLite, a media parser, a browser component | Free | The closest available approximation of supervised audit practice. There is no course for this. |
| Core | [Fuzzing101](https://github.com/antonio-morales/Fuzzing101) | Free | Ten exercises fuzzing real software to real CVEs with AFL++. The best free on-ramp to fuzzing. |
| Core | [AFL++](https://github.com/AFLplusplus/AFLplusplus) | Free | Read the engine, not the README. Harness design is learned by writing harnesses. |
| Core | [The Fuzzing Book](https://www.fuzzingbook.org/) | Free | Executable notebooks: grammar fuzzing, coverage, mutation, reduction, scheduling. |
| Core | [OSS-Fuzz](https://google.github.io/oss-fuzz/) · contribute a harness to a real project | Free | Achievable earlier than most believe, and it produces a public artifact with a project's name on it. |
| Core | [angr](https://docs.angr.io/) | Free | Concolic execution, path explosion, constraint solving. Gated behind module 08 for a reason: without it, this is tool operation. |
| Core | [GitHub Security Lab · CodeQL](https://codeql.github.com/) | Free | Turn one bug into a query and find its siblings. Where module 08 pays for itself and one finding becomes a body of work. |
| Core | [Project Zero blog](https://googleprojectzero.blogspot.com/) and the [0-days in the wild root-cause analyses](https://googleprojectzero.github.io/0days-in-the-wild/rca.html) | Free | The field's public standard for finished research. Read one per fortnight, as models of method. |
| Core | Bug bounty programmes with explicit safe harbour, and open-source projects that welcome security work | Free | Under written authorization, every time. |
| Alt | [OST2 · RE3201: Symbolic Analysis](https://ost2.fyi/RE3201) | Free | Structured treatment if the angr docs are too thin a scaffold. |
| Paper | Klees, Ruef, Cooper, Wei & Hicks, [*Evaluating Fuzz Testing*](https://www.cs.umd.edu/~mwh/papers/fuzzeval.pdf) (CCS 2018) | Free | Read it before you believe any fuzzer's benchmark, including your own. |

AI-assisted auditing, harness generation and triage are a genuine skill here now, not a gimmick: DARPA's AIxCC final, Big Sleep's live SQLite bug, OSS-Fuzz's AI-written harnesses. Build it as an explicit tool, on domains already gated, so you can still judge the output.

## Milestones

- **~150 h:** A harness you wrote finds a crash in real software.
- **~350 h:** A triage writeup distinguishing three crashes by exploitability, with reasoning.
- **~550 h:** A CodeQL query that finds a variant of a known bug in a codebase you chose.
- **~750 h:** A finding reported to a vendor, with a timeline you published.

## Ship

A coordinated disclosure with a published timeline, **or** a technique or tool with documented independent adoption by someone you don't know.

## Gate

Find a previously unknown defect in software **you selected on your own reasoning**, not software someone identified as vulnerable and not a target from a list. Triage its exploitability without assistance. Carry it through coordinated disclosure to resolution.

**Fail if:** the target was chosen for its reputation as low-hanging fruit. Target selection under uncertainty is the thing being tested.

**This is the first original research checkpoint: your first CVE or first published original work.**
