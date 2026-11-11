# Prompt 04: scale out, one track at a time

Use: after the vertical slice and the pipeline retro are done. Run once per track, in the order skill-tree.yaml defines. Replace <TRACK>.

---

Read CLAUDE.md. BUILD mode. Track: <TRACK>.

1. /research <TRACK>, full track sweep: domain map, expert benchmark for this specialisation, target shortlist, scored resources. Skip any brief whose file under research/ is under 90 days old.
2. /design <TRACK>. Show me the module list and hours, and wait for approval.
3. After I approve: /build-module <TRACK>. Build in DAG order. Where two modules do not depend on each other, their labs may be built in parallel.
4. /audit <TRACK>.
5. Track capstone: if the track MAP.md "Track capstone" section names an existing module as the proof point, confirm it. Otherwise ask /design to add a final node <TRACK>-NN-capstone-<slug> to skill-tree.yaml (open-ended, learner picks the target within ethical bounds, deliverables mirror the five terminal outcomes, graded with a capstone rubric), then /build-module it like any other module (DR-0006).
6. Update the track MAP.md (Module path, totals, Emphasise/Exclude from research).
7. Report: modules ready vs drafting, open TODO(research) and needs-lab-verification items, labs unverified, and the next track.
