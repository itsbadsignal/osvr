# Prompt 02: curriculum architecture

Use: after prompt 01 has produced research/FIELD-SYNTHESIS.md.
Expected output: curriculum/skill-tree.yaml (core tracks at planned status), decisions/DR-0001..N, track MAP.md stubs. You approve before anything is built.

---

Read CLAUDE.md and research/FIELD-SYNTHESIS.md. BUILD mode.

Dispatch the curriculum-architect to design the OSVR skeleton:

1. Decide the final track set and core/elective split. Write a decision record for the track set, one for the terminal outcomes (keep or amend CLAUDE.md's five), and one for the first real-bug target class.
2. Create curriculum/skill-tree.yaml from templates/skill-tree.example.yaml with every core module (FND, RE, BX, VD, PRO, or whatever the decision records settle on) at status: planned, with prereqs, outcomes, hours, rds and mitigations. Electives get track entries and 2 to 4 placeholder nodes each, not full detail yet.
3. Write a stub MAP.md per core track from templates/track-MAP.md, filling Why, Outcome statement and Module path. Leave sections that need track-level research marked "pending /research".
4. Constraints:
   - first contact with a real CVE reproduction within the first 40 hours
   - a first real-world bug hunt attempt (on an open-source target, ethically scoped) before the end of the core
   - PRO modules interleaved through the core, not bolted on at the end
   - core total between 500 and 800 hours unless the research argues otherwise; if so, say why
5. Run python3 scripts/validate.py --tree-only and fix errors.

If the architect returns research requests, run them with the researcher, then re-dispatch the architect once.

Then show me: tracks with hours, the core module list in DAG order, the five decisions you most want me to check, and anything the research could not settle. Stop and wait for my approval. Any change I ask for goes through a new decision record before skill-tree.yaml is edited.
