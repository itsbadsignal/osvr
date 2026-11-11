# DR-0003: First real-bug target class and where the first hunt lives

Date: 2026-11-10   Status: accepted (approved by the user on 2026-11-10)

## Context
Two requirements pull in different directions:
- Prompt 02 and the architect's design principles require a first real-world bug hunt attempt **on an open-source target, ethically scoped, before the end of the core**.
- `research/FIELD-SYNTHESIS.md` section 4 and `research/domain-maps/field-overview.md` ("Ranked: suitability as a FIRST 0-day target") recommend **SOHO, IoT and network appliance firmware** (owned devices or emulated images, web-admin and daemon surfaces) as the first 0-day class, with **small under-fuzzed open-source C libraries** as runner-up. The field map states the rank-1 vs rank-2 choice is a judgement call with no time-to-first-bug data behind it.

Facts that bear on the choice:
- Appliance bug classes (command injection, auth bypass, traversal, daemon stack overflows) need no heap prerequisite; embedded mitigations are weak per 2019-20 data only, `needs-lab-verification` [field-overview: EMB-2019, P2O-I1, KEV].
- Firmware acquisition and emulation friction is the dominant cost: one router researcher spent about a year with bugs they could not trigger [expert-paths: Hypr].
- Popular OSS parsers are the most contested space (OSS-Fuzz scale, AI-discovered bug volumes, curl's falling confirmed rate); smaller, less-fuzzed projects and new features remain open [field-overview: rank 2, CURL, ANTH-0D].
- Most vendor firmware is proprietary, so a firmware hunt is usually not "open-source".

## Options
1. **OSS library hunt in core; EMB firmware as first-0-day elective and capstone lane.** Pros: meets the constraint exactly; no firmware friction in core. Cons: the core hunt lands in the most contested space; teaches memory classes only, ignoring the logic/injection majority.
2. **Emulated open-source firmware target in core** (e.g. an open-source router distribution's packages under QEMU system emulation). Pros: closest to the synthesis's rank-1 class while staying open-source. Cons: adds ARM/MIPS assembly and extraction/emulation work (about 28 h, `EMB-01`/`EMB-02`) to the core; emulation friction sits at the point where a failed setup most damages motivation; open-source firmware distributions are better maintained than vendor firmware, so the "weak mitigations, under-audited" advantage largely disappears.
3. **Two-lane core hunt on open-source code, run natively or under QEMU user mode; firmware stays in EMB** (chosen). `VD-10` offers:
   - **Lane A, library**: a small, under-fuzzed open-source C library (parser, codec, format), fuzz-led plus audit. Best for low-level VR hiring.
   - **Lane B, network service**: an open-source network daemon or embedded web/admin stack (the software class appliances ship), audit-led for injection, auth and traversal, plus fuzzing of its parsers. Closest to the field's rank-1 bug classes without firmware extraction.
   Both lanes: target picked through `VD-09` (source availability, build cost, prior CVEs, fuzzing coverage, disclosure path, AI-report policy); runs only in the learner's lab; ends with either a novel bug or a negative-result report with coverage evidence.
   `CAP-01`/`CAP-02` (first full 0-day lifecycle, split into hunt/root-cause and exploit/disclose) then offer three lanes: A, B, or **C, appliance firmware** on an owned device or emulated image, which requires the EMB elective.

## Decision
Option 3. The hunt sits in core at `VD-10` (hours 384-424 of the core sequence), before the heap block. Firmware-first 0-day work lives in the `EMB` elective and `CAP-01`/`CAP-02` lane C. Lane choice is the learner's, by goal; the coach records it so the pilot can compare lanes.

Why not option 2: the constraint is "open-source", the dominant cost of firmware work is environment friction [expert-paths], and the core already contains `VD-08` lab parity, which practises emulation and debugger attach on open-source daemons. A learner who wants firmware takes `EMB` immediately after the core (its prereqs are all core modules) and does `CAP-01`/`CAP-02` on lane C.

## Consequences
- `VD-05` must cover injection, auth and traversal in C and in the scripting languages embedded web stacks use, so lane B is a real option.
- `VD-08` must include QEMU user-mode emulation of a cross-compiled daemon, so the step to `EMB-02` is short.
- Research request: a `research/targets/` shortlist per lane (candidate projects, build cost, existing fuzzing coverage, CVE history, disclosure contact, AI-report policy). Blocks the builder for `VD-09`/`VD-10`.
- Research request: embedded mitigation state after 2020 (FIELD-SYNTHESIS Q3). Blocks `/design EMB` and the lane C claim that firmware is weakly mitigated.
- Pilot metric: time-to-first-candidate-bug and time-to-first-confirmed-bug per lane; if lane B is clearly faster and the learner's goal allows, make it the default.
- Revisit after the first pilot learner completes `VD-10`.
