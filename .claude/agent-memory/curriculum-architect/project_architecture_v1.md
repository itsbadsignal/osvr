---
name: project-architecture-v1
description: First OSVR architecture (2026-11-10): track set, core order, hour totals, key placements and options rejected in DR-0001..0006, so they are not re-litigated
metadata:
  type: project
---

First architecture pass done 2026-11-10. DR-0001..0006 all accepted by the user on 2026-11-10 (DR-0002 wording applied to CLAUDE.md).

- Core tracks FND, RE, BX, VD, PRO, plus CAP (3 capstone nodes, core: true). Electives in order EMB (widened to "embedded, firmware and appliances"), LK, HV, WIN, MOB, BRW. Core 654 h (514 without capstones).
- Key placements: FND-04 real CVE crash repro ends at hour 40; VD-02 fuzzing at hours 77-95 (before assembly, prereq honesty); RE-04 patch diffing feeds BX-05 first N-day exploit; VD-08 lab parity before VD-10 first hunt (hours 384-424) which sits BEFORE the heap block; PRO interleaved.
- Rejected: AI as a track (VD-07 cross-cutting instead); AArch64 in FND (moved to EMB-01); EMB/firmware in core (DR-0003, friction + not open-source); hunt after heap; agentic-systems module (deferred, no research); separate BX "odds and ends" module; symbolic execution.
- DR-0002 guard: impact-PoC clause for non-memory bugs only applies to the learner's own bug; CAP-03 still requires a memory-corruption exploit. Reliability bar 20 runs / 70% borrowed from kernelCTF, tunable.
- DR-0005: FND-00-programming-on-ramp (C first, 30 h, outcomes [rootcause]) is a second root with NO prereq edges in or out, gated by a 90-min any-language diagnostic after FND-01. New optional node field `conditional:`. Core 654 h without on-ramp / 684 with (validator prints 684). Rejected: hard prereq for all (dishonest edge, expertise reversal); "must already program" entry rule (contradicts learner range); Python first (language switch before C-heavy FND-02..05); both languages. Revisit if foundations.md or pilot shows high C-first attrition.
- DR-0006: capstones live in curriculum/tracks/CAP/modules/; curriculum/capstones/ removed. Per-track capstones = normal last node of the track or named in MAP "Track capstone". Rejected: validator special case for curriculum/capstones; hybrid free-form briefs (unvalidated hours/prereqs).
- Pending outside my scope (2026-11-10): user to apply CLAUDE.md layout text and prompts/04-scale-out.md step 5 text from DR-0006; template/validator support for `conditional:` proposed in DR-0005.
- Open with user: PRO-07 borderline outcome trace.

**Why:** user/caller wants decisions recorded so later runs build on them.
**How to apply:** check decisions/ for current status before changing any of these; if a DR is superseded, update this memory. See [[research-gaps-open]].
