# 06 · The Bug

> Find a memory-corruption bug in something you didn't write, characterise the primitive it yields, and take control of execution. Mitigations stay off, so the mechanism is visible.

**Requires:** [M5 gate](05-the-boundary.md) · **Hours:** 450-650 · **Next:** [M7 · The Defended Target](07-the-defended-target.md)

Mitigations are deliberately off through this module. Turning them on before the mechanism is visible teaches defeat rather than understanding. Stack first; then the heap, which is where most people stall. That is normal and planned for.

## Outcomes

- Reverse a stripped binary to accurate pseudocode.
- Drive a debugger as an instrument, not a crash viewer.
- Recognise every major memory-corruption class on sight.
- Take a crash to instruction-pointer control unaided, and state the primitive precisely: what can be written, where, how many times, under what constraints.

## Resources

| Role | Resource | Cost | Notes |
|------|----------|------|-------|
| Core | [pwn.college · Program Security](https://pwn.college/dojos) | Free | ~95% hands-on, hundreds of challenges. The strongest single resource in the field. The ramp is steep; attrition at the belt boundaries is the gate working. |
| Core | [OST2 · Vulns1001 / Vulns1002: C/C++ vulnerabilities](https://ost2.fyi/Vulns1001) | Free | The bug-class taxonomy taught from the "how do I avoid writing this" direction. |
| Core | [exploit.education · Phoenix](https://exploit.education/phoenix/) | Free | Hand-planted bugs in tiny programs. Use Phoenix, not the deprecated Protostar. |
| Core | [pwntools](https://docs.pwntools.com/) | Free | The scripting standard. |
| Core | [how2heap](https://github.com/shellphish/how2heap) | Free | One technique per directory against pinned glibc versions. The version pinning is the lesson: record your glibc version in every writeup. |
| Core | A small, real, C-heavy open-source project of your own choosing | Free | The gate needs a bug nobody pointed you at. Start looking at hour one, not hour 450. |
| Alt | [HeapLAB pt. 1](https://www.udemy.com/course/linux-heap-exploitation-part-1/) (Kamper) | ~$30 | The cheapest high-value buy in the curriculum, if the free heap material stalls. |
| Ref | [ir0nstone · binary exploitation notes](https://ir0nstone.gitbook.io/notes/) | Free | The best free written reference for this material. |
| Ref | [Nightmare](https://guyinatuxedo.github.io/) | Free | 90+ challenges with writeups. Use as an unsticker, not reading material. |
| Ref | *Practical Binary Analysis* (Andriesse, 2018) | ~€50 | Builds your own tooling. |
| Ref | *The Ghidra Book* (Eagle & Nance, 2020) | ~€55 | The methodology holds even where Ghidra has moved on. |
| Paper | Aleph One, [*Smashing the Stack for Fun and Profit*](https://phrack.org/issues/49/14) (Phrack 49:14, 1996) | Free | The founding document. Read as history and mechanism, not current technique. |
| Paper | [*Once upon a free()*](https://phrack.org/issues/57/9) (Phrack 57:9) · blexim, [*Basic Integer Overflows*](https://phrack.org/issues/60/10) (Phrack 60:10) | Free | The heap and integer-arithmetic origin documents. |

Tools (Ghidra, gdb + [pwndbg](https://github.com/pwndbg/pwndbg), pwntools) are the medium and are allowed from day one. Automating a *technique* you haven't performed three times by hand is not.

## Milestones

- **~120 h:** Reverse a 200-line stripped binary to accurate pseudocode, unaided.
- **~250 h:** Hand-written position-independent shellcode under a bad-character constraint, no framework.
- **~380 h:** Supplied crash → instruction-pointer control, primitive stated precisely.
- **~500 h:** One exploitation challenge solved on a non-x86 architecture.

## Ship

A public writeup of a memory-safety bug **you found** (not one you solved) in a small piece of real open-source software, taken through disclosure. If no bug materialises within the module, substitute a full reverse-engineering writeup of a binary with no existing public solution, and treat it as second-best.

## Gate · 8 cumulative hours, logged

Given a binary with a memory-corruption bug, no source, and no hint as to class or location: locate it, characterise the primitive in precise terms, and demonstrate control of the instruction pointer. Unaided.

**Fail if:** you get IP control but can't characterise the primitive precisely. Characterisation, not the crash, is the skill.

From here the constrained (web/cloud + appsec) track can begin earning through in-scope bug bounty work.
