---
name: research-gaps-open
description: Research requests the architect raised on 2026-11-10 that block specific design/build steps (glibc defaults, embedded mitigations, VD-10 target shortlists, Windows defaults, agentic systems)
metadata:
  type: project
---

Requested 2026-11-10; check research/ before assuming still open.
- BX domain map: glibc allocator hardening per version, distro hardening flags, Linux userland CET state. Blocks /design BX detail and BX-02/05/06/09 mitigation labels (TODO(research) in tree).
- research/targets/ shortlists for VD-10 lanes A (small under-fuzzed OSS C library) and B (OSS network service / embedded web stack). Blocks VD-09/VD-10 build.
- Embedded mitigation state post-2020. Blocks /design EMB and CAP lane C claims.
- Windows userland/kernel defaults (CET, kernel stack protection). Blocks WIN design.
- Agentic/LLM systems bug classes: needed before reconsidering an attacking-agentic-systems module.
- Time-to-first-bug: only the pilot can produce it.

**Why:** architect must not design these from memory.
**How to apply:** when asked to /design one of these tracks, first check whether the matching research file now exists. Related: [[project-architecture-v1]].
