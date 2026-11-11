# Prompt 05: migrate an existing OSVR repo onto the kit

Use: instead of prompts 01 and 02 if the repo already has curriculum content (e.g. github.com/itsbadsignal/osvr). Run on a new branch.
Expected output: an inventory, a gap analysis, a migration plan for approval. Nothing deleted.

---

Read CLAUDE.md. BUILD mode. This repo already contains OSVR content written before this kit existed. Work on a new branch named kit-migration. Do not delete or overwrite any existing file in this session.

1. Inventory: list every existing curriculum file, what topic it covers, its apparent level, and every external resource it links. Write research/benchmarks/existing-osvr-inventory.md.
2. Dispatch researcher subagents in parallel to verify every external link in the inventory (exists, still says what the repo claims, date). Results into the same file.
3. Run prompt 01's five research briefs, but skip any where the existing repo already has equivalent, verifiable research.
4. Dispatch the curriculum-auditor on the existing content as if it were drafting modules: which DoD items each part already meets, which ultralearning mechanics are missing (typically drills, retrieval cards, struggle challenges, direct targets, rubrics).
5. Dispatch the curriculum-architect to propose a migration plan as decisions/DR-0001-migration.md:
   - mapping of existing sections to skill-tree nodes (keep, split, merge, retire)
   - new nodes needed to close gaps
   - the proposed curriculum/skill-tree.yaml, all at planned or drafting
   - order of work
6. Show me the plan and stop. After I approve, existing content moves into the module layout with git mv so history is kept, then module-builder fills the missing files per module.
