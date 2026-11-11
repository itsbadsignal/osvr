# DR-0007: Pipeline retrospective 1 (vertical slice FND-01 to FND-04)

Date: 2026-11-11   Status: proposed (none of the changes below are applied; awaiting user approval per prompt 03)

## Context
Prompt 03 built the shortest path to the first real-CVE module: FND-01 (lab and learning protocol, cJSON CVE-2023-53154 smoke test), FND-02 (C pointers and memory, iperf3 CVE-2025-54349), FND-03 (build and debug with gdb and sanitizers, cJSON `ENABLE_SANITIZERS` defect), FND-04 (first CVE crash reproduction, TinyDir CVE-2023-49287). The pipeline ran research, then build-module (module-builder, lab-engineer, curriculum-auditor, fix loop). This record captures what the slice showed about the pipeline and proposes concrete changes. Evidence is the main-thread running log kept during the slice and the agents' reports.

### Outcome per module
| Module | Text/lab reconciliation passes | Corrections from lab | Audit rounds | Final |
|---|---|---|---|---|
| FND-01 | 3 (reconcile, fix round, alignment of exact messages) | 12 | 2 | ready |
| FND-02 | 3 | 18 (host-derived worked example materially wrong) | 2 (final 1-line blocker fixed by main thread) | ready |
| FND-03 | 2 so far | 12 | 1 so far, REVISE (3 of 4 blockers in checker/rubric consistency) | FINAL-STATUS-FND03 |
| FND-04 | 1 | 14 (most were marker closures, few wrong values) | FINAL-STATUS-FND04 | FINAL-STATUS-FND04 |

Cost: about 1M+ subagent tokens per module reaching ready (each audit+fix round 150 to 250k). The 5-hour usage limit was hit three times; each hit killed 2 to 5 agents mid-task and cost hours of wall-clock. Wall-clock for the slice: about 1.5 days.

### What went well
- **Builder measuring in a container FROM the lab base image** (FND-03, FND-04) eliminated host drift. FND-04's text needed almost no value corrections; FND-01/02, written from the host (Arch, gcc 16), needed 12 and 18.
- **Lab-engineer owning checker design.** Twice the lab-engineer replaced an unsound builder-specified checker contract (FND-03 `OSVR_FORCE_NO_ASAN`, which a script could satisfy without a working verify stage) with a sound one (mutated-source run).
- **Auditors running the lab** caught real defects no static read would: checker grading its own run (FND-01), false FAIL on a legitimate route and an ungraded objective (FND-03), and upgraded FND-02's D1 by showing the real bug was reproducible in about 15 lines.
- **Long reports routed through scratch files** rather than pasted into messages.
- **Real findings fell out of the build**: the cJSON `ENABLE_SANITIZERS=ON` silent ASan drop (still present at the newest commit 6d9f2443), the ASan fast-unwinder truncating malloc stacks at `CRYPTO_malloc`, GEF's radix-16 gdbinit silently changing every transcript.

### What went wrong (root causes)
1. **Text before lab.** The builder wrote expected output before any lab existed, so every module needed 2 to 3 reconciliation passes. Biggest single waste in the slice.
2. **Mechanism claims from general knowledge.** Builders and lab-engineers asserted container behaviour from memory (LSan needs ptrace and Docker seccomp denies it; default seccomp allows ptrace on 4.8+). The builder prompt forbids invented *sources* but not unsourced *mechanism claims*.
3. **Checker/rubric/objective drift.** Checker changes landed without the text being told the new contract (FND-03 B2), and objectives existed that no checker line or assessor step graded (FND-03 B4). No artefact traced objective to check.
4. **Stale text after a fix adds a step.** FND-02's last blocker: Target and Deliverables still described the module before the required step 6 was added.
5. **Validator vs source rule conflict.** CLAUDE.md source rule 2 says record unfetchable sources as `verified: null, status: unverified`; `validate.py` makes any such entry a D7 error. Builders therefore hid gaps in YAML comments the validator cannot see (FND-03, FND-04). The rule's intent (visible gaps) is defeated.
6. **Parallelism vs usage limit.** 8 parallel agents tripped the limit on the first night; even 3 tripped it later.
7. **Shared image churn.** Parallel agents rebuilt or removed shared base images under each other (auditor NO_CACHE rebuilds, `FULL=1 reset`).
8. **Researcher errors with a common shape.** Stray output file (`research/foundations.md` instead of the domain map); fix commits from search snippets (stb_image); a truncated `git tag --contains` list read as "first fixed in v3.1.10", raising a false discrepancy with the CVE record; one attempted User-Agent spoof (blocked).
9. **Builders stopping mid-task to ask in-scope judgement questions** (FND-04), costing a round trip each.
10. **Missing tooling on the build host**: no `pdftotext`, so several PDFs (syllabi, ASan paper body) were unread.
11. **Templates gaps**: `project.md` deliverables are exploit-shaped and infrastructure modules improvise; `templates/learner/session.md` lacks a Distractions line (the Focus mechanic); `templates/lab-SPEC.md` has no rules for read-only grading, clean rebuilds, or host-vs-lab; the skill-tree example lacks the `conditional:` field (DR-0005).
12. **Hours drift.** FND-01 to FND-04 total 42 h vs the MAP's 40 h; auditors judge FND-03's 10 h as realistically 15 to 18 h. The tree's hours were estimates made before any content existed.

## Options
1. **Apply all proposed changes below** as one batch, then run prompt 04 (scale-out). Pros: fixes every observed root cause before multiplying them across ~60 modules. Cons: about half a day of edits; changes are untested until the next module.
2. **Apply only the cheap rule changes (P1 to P6, P9) now; defer validator and template changes (P7, P8, P10 to P12).** Pros: faster. Cons: the D7 conflict keeps hiding source gaps; the trace table never gets built.
3. **Change nothing; absorb lessons in briefs.** Cons: the lessons live only in the main thread's prompts and are lost on context compaction or a new session.

## Decision
Proposed: Option 1. Pending user approval.

## Proposed changes (diffs, not applied)

### P1. Lab before walkthrough (build-module skill, module-builder agent)
`.claude/skills/build-module/SKILL.md`, replace steps 2 and 3 with:
```
2. **Spec and measure.** Dispatch `module-builder` in SPEC mode: it writes `lab/SPEC.md`, objectives, and the outline, and runs its own measurements in a scratch image `FROM` the lab base image (never on the host). No expected output in README/drills/project yet.
3. **Lab.** Dispatch `lab-engineer` on the SPEC. It owns checker design and returns the exact PASS/FAIL/INFO lines, the --health list, and measured answers to every open question in the SPEC.
4. **Write.** Dispatch `module-builder` in WRITE mode with the lab report file. Every quoted output is copied from the lab report or a measurement in the lab image; anything else is `needs-lab-verification`.
```
(renumber later steps). `.claude/agents/module-builder.md`, add under the source rules:
```
- Run every experiment in a scratch container built FROM the module's lab base image (e.g. `osvr-fnd-base:1`), never on the host. Host toolchains differ (FND-02: canary and layout were wrong from the host).
- Do not state mechanism claims (kernel, container, toolchain, allocator behaviour) from general knowledge. Either measure it in the lab image, cite filed research, or write `> needs-lab-verification`.
- For in-scope judgement calls (which worked example, which variation), decide, note the decision and the reason in your report, and carry on. Stop only for scope changes that conflict with the node or a DR.
- After any change that adds, removes or changes a required step, re-read Target, Goal and Deliverables for contradictions.
```

### P2. Objective-to-check trace table (lab-SPEC template, auditor)
`templates/lab-SPEC.md`, add after "Checker idea":
```
## Grading trace
| Objective / rubric Pass criterion | Graded by (checker mode + exact line, or "assessor: <step>") | Contract stated to learner in |
|---|---|---|
```
`.claude/agents/curriculum-auditor.md`, add to the checks: "Every objective and rubric Pass criterion appears in the SPEC grading trace with a real checker line or an explicit assessor step; every contract the checker enforces is stated in project.md; try at least one legitimate variant learner route against the checker and report any false FAIL."

### P3. Lab conventions in the template (lab-SPEC template, lab-engineer agent)
`templates/lab-SPEC.md`, add a "House rules" block (and the same list in `.claude/agents/lab-engineer.md`):
```
- The checker grades the learner's artefacts read-only (`:ro`, `--network=none`, `--cap-drop=ALL`) and never regenerates them. Self-tests live under `--health`.
- Fixtures assert exact exit codes (0 pass, 1 fail, 2 usage).
- `build.sh` honours `NO_CACHE=1` and tees a log to `~/osvr-work/<module>/build-logs/`; an uncached log has 0 "Using cache" lines. The shared base is rebuilt only if missing or with `BASE=1`.
- Use `LAB_CFLAGS`, never ambient `CFLAGS`.
- Grade by report text, not exit status, whenever the target's exit status is the same on both builds.
- Transcripts are captured with the exact command the learner types (the base gdbinit loads GEF; use `gdb -q -nx`).
- Never assert Docker behaviour; label it untested. Rootless podman is the verified engine.
- Never remove or retag images you did not create; `reset.sh` removes only this module's images.
- Before declaring a CVE non-reproducible, attempt one minimal harness against the real code.
```

### P4. Agent concurrency and image hygiene (build-module skill)
Add to `.claude/skills/build-module/SKILL.md` under "Per module loop": "Run at most 3 agents at once. Agents never remove or retag shared images (`osvr-*-base:*` and other modules' images); auditors may not use `FULL=1 reset` or `NO_CACHE` on a base image."

### P5. Main thread may apply trivial post-audit fixes (build-module skill)
Add to step 5: "If the auditor's remaining blocking items are text-only and each is one or two lines, the main thread applies them directly, re-runs the lab fixtures and validate.py, and promotes without a further audit round if the auditor said so."

### P6. Researcher rules (researcher agent)
`.claude/agents/researcher.md`, add:
```
- Write only to the absolute path the brief gives. Never create a new top-level `research/*.md` unless asked.
- Fix commits and first-fixed releases are verified in git: `git describe --contains <commit>`, plus a patch-id search for cherry-picks. Never read them from search snippets, distro trackers, or the head of a tag list.
- Never spoof a User-Agent or work around a bot wall. Record the source as unverified.
```

### P7. Resolve the D7 conflict (scripts/validate.py, CLAUDE.md wording unchanged)
In `check_module`, replace the unconditional error for unverified entries with:
```python
            if v in (None, "", "null") or r.get("status") == "unverified":
                if r.get("role") == "core":
                    rep.err(nid, f"core resource '{title}' unverified (D7)")
                else:
                    rep.warn(nid, f"resource '{title}' unverified (D7: does not count as a source)")
                continue
```
and add: error if any prose claim cites an unverified card (deferred: needs a citation syntax), and error if a module has zero verified core resources. Effect: gaps become visible entries again instead of comments.

### P8. Validator additions (scripts/validate.py)
- Run `build_index.py --check` and report out-of-date `curriculum/README.md` as an error.
- Print core hours with and without `conditional:` nodes.
- Enforce the resource card schema from `templates/resource-card.yaml` (required fields), which would have caught the incomplete cjson-issue-800 card.
- Warn on `TODO(research)` inside `resources.yaml` comments, not only in README (closes the hiding path).

### P9. Templates
- `templates/learner/session.md`: add `Distractions:` under the timebox line and `Done when:` under Goal (the Focus mechanic; FND-01's first session log failed its own checker without them).
- `templates/skill-tree.example.yaml`: show the optional `conditional:` field (DR-0005).
- `templates/module/project.md`: add a deliverables variant for infrastructure and tooling modules (artefact + root cause of a real build or tooling defect), pending P10.

### P10. D1 for infrastructure modules (new DR, architect)
FND-01 and FND-03 target real codebases but their "finding" is a tooling defect or a smoke test, not a vulnerability. Both auditors passed D1 by judgement. Ask the architect for a DR that states D1 for infrastructure/meta-skill modules explicitly (real artefact at a pinned commit, real defect or real CVE reproduced, cited real-world analogue), so future auditors do not re-argue it.

### P11. Hours re-estimate (architect)
After the slice, the architect re-estimates FND hours from the built modules (FND-01 8 h, FND-03 realistically 15 to 18 h) and recalibrates the estimating rule for unbuilt nodes (built content ran about 1.2 to 1.8 times the tree estimate). Edits to `skill-tree.yaml` go through a DR per prompt 02.

### P12. Host tooling
Install `poppler` (`pdftotext`) on the build host, or add a PDF-reading step to the researcher brief, so primary-source PDFs are read rather than carded from landing pages.

## Consequences
- Expected effect: one reconciliation pass per module instead of three, and one audit round in the common case. Estimated saving 30 to 50% of tokens per module, which matters more than speed because the usage limit is the binding constraint.
- Modules affected: none retroactively. FND-01 to FND-04 already follow P1 to P5 in practice.
- Deferred items not covered here (separate DRs or architect passes): VD-10 negative-result outcome; D4 card guidance (synthesis finding 9); DR-0005 C-first vs Python-first conflict; BX tree edits from the glibc research (glibc 2.43 removed fastbins); Docker-in-VM verification; FND-00 diagnostic build.
- Revisit after the first track built under prompt 04.
