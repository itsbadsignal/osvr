# Prompt 03: build a vertical slice

Use: after the skill tree is approved. Builds the first few modules end to end so the whole pipeline (research, content, lab, audit, coaching) is proven on a small scale before scaling out.
Expected output: 3 to 4 ready modules with labs, audit reports, and a list of pipeline fixes.

---

Read CLAUDE.md. BUILD mode.

1. Pick the shortest path in skill-tree.yaml from the first FND module to the first module whose project is a real CVE reproduction. If that is more than 4 modules, take the first 4 on that path. Tell me which you chose.
2. Run /research for the topics those modules need that are not yet covered under research/ (domain map plus target shortlist). Narrow briefs, not a whole-track sweep.
3. Run /build-module for each in DAG order, including labs.
4. Run /audit on the slice.
5. Then do a retrospective on the pipeline itself, not the content:
   - where agents produced unverified claims or TODO(research) items, and why
   - where the templates or validate.py forced bad structure or missed real problems
   - how long each stage took and what was wasted
   - proposed edits to the agent prompts, skills, templates or validator, as a diff I can approve
   Write this to decisions/DR-NNNN-pipeline-retro-1.md.

Do not apply the pipeline changes until I approve them.
