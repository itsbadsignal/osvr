# DR-0006: Capstone content lives under curriculum/tracks/CAP/

Date: 2026-11-10   Status: accepted (direction approved by the user on 2026-11-10)

## Context
DR-0001 added a `CAP` track (`CAP-01`, `CAP-02`, `CAP-03`, core) so that capstone prereqs are part of the DAG and `validate.py` checks them. That created a layout conflict, recorded as open in DR-0001's Consequences and in `curriculum/tracks/CAP/MAP.md`:
- `scripts/validate.py` (`check_module`) looks for every module at `curriculum/tracks/<track>/modules/<id>/`. `curriculum/tracks/CAP/MAP.md` already exists there.
- The layout block in CLAUDE.md lists `curriculum/capstones/  open-ended 0-day capstones`. The directory exists and is empty.
- `prompts/04-scale-out.md` step 5 tells the scale-out run to write per-track capstones to `curriculum/capstones/<TRACK>-capstone.md`. Those files would sit outside the DAG, and their prereqs and hours would never be validated.

## Options
1. **Keep `curriculum/tracks/CAP/`, retire `curriculum/capstones/`** (chosen). Graduation capstones are ordinary `CAP-*` modules. A per-track capstone is either named in that track's MAP.md "Track capstone" section (when an existing module already serves as the proof point, as FND-04 does) or added as a normal last node of that track (`<TRACK>-NN-capstone-<slug>`) with prereqs and hours in the tree. Pros: no validator change, one layout rule for all content, and capstone prereqs and hours are always checked. Matches the existing CAP MAP. Cons: CLAUDE.md and prompt 04 need text edits, and per-track capstones count toward track hours, which they should anyway.
2. **Move CAP modules to `curriculum/capstones/<id>/` and teach the validator a special case.** Pros: CLAUDE.md layout unchanged. Cons: adds a special case to `validate.py` and two places for module content. The CAP MAP.md has to move or be orphaned.
3. **Hybrid: modules under `tracks/CAP/`, free-form briefs in `curriculum/capstones/`.** Pros: keeps both paths in use. Cons: two sources of truth for capstone requirements. The briefs are not validated, and a per-track capstone brief has no hours or prereqs, which breaks principle 5 (hour budgets are real) and the rule that every node traces to an outcome.

## Decision
Option 1.
- All capstone content goes in `curriculum/tracks/CAP/modules/<CAP-id>/`, with the same files and DoD as any module. DR-0004 still makes capstones the minimal-scaffolding end state: no worked example.
- Per-track capstones are tree nodes in their own track, or are named in the MAP "Track capstone" section. They never go in a separate directory.
- The empty `curriculum/capstones/` directory is removed.

**Replacement text for CLAUDE.md** (Repository layout block). The user applies it; the architect does not edit CLAUDE.md. Replace these lines:

```
  tracks/<TRACK>/
    MAP.md                     metalearning map for the track
    modules/<MODULE_ID>/
      README.md                objectives, theory, walkthrough, struggle challenge
      drills.md                rate-determining-step drills
      project.md               direct project on a real target + variations + Feynman task
      rubric.md                assessment rubric
      cards.yaml               retrieval cards (seed deck)
      resources.yaml           verified resource cards
      lab/                     Dockerfile / VM spec / checker, if the module needs one
  capstones/                   open-ended 0-day capstones
```

with:

```
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
```

Optionally, in the Identifiers section, add `CAP` capstones to the seed track list (DR-0001 already added it). Example: "... `HV` hypervisors, `PRO` professional practice, `CAP` graduation capstones."

**Replacement text for `prompts/04-scale-out.md` step 5.** Prompt files are outside the architect's write scope.

```
5. Track capstone: if the track MAP.md "Track capstone" section names an existing module as the proof point, confirm it. Otherwise ask /design to add a final node <TRACK>-NN-capstone-<slug> to skill-tree.yaml (open-ended, learner picks the target within ethical bounds, deliverables mirror the five terminal outcomes, graded with a capstone rubric), then /build-module it like any other module.
```

## Consequences
- No change to `skill-tree.yaml` nodes or hours: CAP-01..03 already sit under `tracks/CAP/`.
- `curriculum/tracks/CAP/MAP.md` "Track capstone" now cites this DR instead of the open question.
- The empty `curriculum/capstones/` directory has been removed.
- When electives are designed, each elective's capstone becomes a node with hours, so elective hour totals will grow. The /design step for each elective must budget for it.
- Watch: any agent or prompt that still writes to `curriculum/capstones/`. Grep for it after the CLAUDE.md edit.
