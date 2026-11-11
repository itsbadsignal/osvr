# Prompt 01: field-wide metalearning sweep

Use: first session in Claude Code, from the repo root, after copying the kit in. Paste everything below the line.
Expected output: research/benchmarks/*.md and research/FIELD-SYNTHESIS.md. No curriculum content yet.

---

Read CLAUDE.md and docs/ULTRALEARNING.md section 1. We are in BUILD mode, starting the metalearning phase for the whole OSVR curriculum. Do not design or write any modules in this session.

Goal: build the evidence base for designing a zero-to-0-day vulnerability research curriculum for self-taught learners without degrees, studying about 10 hours a week.

Dispatch researcher subagents in parallel, one per brief below. Each writes to the path given and follows the researcher's Benchmark or Domain map format.

1. research/benchmarks/expert-paths.md
   How working vulnerability researchers and exploit developers say they learned the craft, in their own words: blog posts, interviews, talks, podcast transcripts. At least 8 people, ideally including several without CS degrees. Extract: order they learned things in, what they say they wish they had done earlier, what they say was wasted time, how long until their first real bug.

2. research/benchmarks/curricula-and-trainings.md
   Structure of serious existing curricula and trainings: free (e.g. pwn.college, OpenSecurityTraining2, university courses with public material) and paid (certification-linked courses and conference trainings in exploit development and vulnerability research). Structure and sequencing only; do not reproduce content. Tabulate topics, order, hours, prerequisites, and whether learners end on real targets.

3. research/benchmarks/job-market.md
   Current public job postings for vulnerability researcher, exploit developer, security researcher (offensive), and product security roles focused on finding bugs. At least 25 postings across vendors, consultancies, and research firms in Europe and the US. Tally required and preferred skills, languages, platforms, and whether degrees are required.

4. research/domain-maps/field-overview.md
   The landscape of where 0-days are found today by target class (browsers, kernels, mobile, embedded, hypervisors, enterprise software, open source libraries), which bug classes dominate in each, the default mitigation state per platform, and which target classes are realistic entry points for a self-taught learner on a laptop.

5. research/benchmarks/learning-science.md
   Evidence for the ultralearning mechanics we rely on (retrieval practice, spacing, interleaving, deliberate practice, feedback timing) from peer-reviewed or review-level sources, plus any evidence specific to learning programming or security skills. Flag where the evidence is weak.

When all five return, read them and write research/FIELD-SYNTHESIS.md:
- 10 findings that should shape the curriculum design, each citing which research file supports it
- proposed track set and the order of tracks, with rationale
- proposed terminal outcome wording if CLAUDE.md's five outcomes should change
- the realistic first 0-day target class for this learner profile, with reasoning
- conflicts between sources and open questions
- sources you could not reach, so I can fetch them manually

Finish with a short summary to me and the suggested next prompt (02).
