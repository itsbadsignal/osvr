# 07 · The Defended Target

> Everything from module 06, against targets that fight back: mitigations on, reliability required, two architectures, the bug no longer handed to you.

**Requires:** [06 gate](06-the-bug.md) · **Hours:** 550–850 · **Next:** [08 · The Theory](08-the-theory.md)

This is the employability boundary. Someone who stops here has a career in exploit development or offensive security engineering.

## Outcomes

- State what each mitigation in the current default stack does, mechanically, and what class of bug still defeats it.
- Manipulate a modern allocator deliberately, recording the version.
- Build exploits that work when someone else runs them.
- Take a published CVE and its patch, recover the bug, and write the PoC.
- Do all of it on a second architecture.

## Resources

| Role | Resource | Cost | Notes |
|------|----------|------|-------|
| Core | [pwn.college · Software Exploitation](https://pwn.college/dojos) | Free | Mitigations on, plus the x86 and ARM community dojos. |
| Core | [Georgia Tech CS6265 · lab tutorials](https://tc.gts3.org/cs6265/tut/) | Free | Public material from a graduate binary-exploitation course. |
| Core | [how2heap](https://github.com/shellphish/how2heap) against pinned glibc | Free | Heap technique is allocator-version-specific. Record your version in every writeup. |
| Core | [ROP Emporium](https://ropemporium.com/) | Free | Code reuse, multi-architecture. |
| Core | [Azeria Labs · ARM assembly and exploitation](https://azeria-labs.com/) | Free | ARM64 is not an elective. A second architecture at working depth. |
| Core | Current vendor docs for the mitigations in play: glibc release notes, Intel CET, ARM PAC/BTI/MTE, Microsoft CFG/XFG | Free | The one place the recommendation is "read the changelog": any course crystallises a snapshot and is wrong within two years. |
| Core | Patch diffing: take three published CVEs with patches, diff, recover the bug, write the PoC. Tools: [BinDiff](https://github.com/google/bindiff), [Diaphora](https://github.com/joxeankoret/diaphora) | Free | The actual entry route into vulnerability research, and this module's micro-discovery requirement. |
| Core | [CTFtime](https://ctftime.org/) · join a team | Free | One competition per quarter. Join one badly and early rather than a good one later. |
| Practice | [pwnable.tw](https://pwnable.tw/) · [pwnable.kr](http://pwnable.kr/) | Free | Where CTF-grade difficulty lives after pwn.college's ramp. |
| Alt | [RET2 WarGames](https://wargames.ret2.systems/) | ~$400 (verify) | The one paid exploit-dev course routinely called better than certs costing four times as much. Buy only if the free path stalls. |
| Alt | *Blue Fox: Arm Assembly Internals and Reverse Engineering* (Markstedter, 2023) | ~€50 | For the ARM64 half if Azeria's material leaves you wanting depth. |
| Ref | [glibc malloc internals](https://sourceware.org/glibc/wiki/MallocInternals) | Free | Read alongside how2heap, not instead of it. |
| Paper | Shacham, [*The Geometry of Innocent Flesh on the Bone*](https://hovav.net/ucsd/dist/geometry.pdf) (CCS 2007) | Free | The paper that named ROP. |
| Paper | Szekeres, Payer, Wei & Song, [*SoK: Eternal War in Memory*](https://nebelwelt.net/publications/files/13Oakland.pdf) (IEEE S&P 2013) | Free | Makes mitigation bypass a system rather than a list. If you read one thing here, read this. |

**Honest gaps:** there is no good structured resource for CET/shadow-stack bypass at any price, and the Windows heap (LFH, segment heap) has no free structured treatment. The free path here is Linux-shaped.

## Milestones

- **~150 h:** Defeat NX and ASLR on a binary you haven't seen, given the bug.
- **~300 h:** Groom a glibc heap deterministically and achieve a controlled allocation. Record the version.
- **~450 h:** A working exploit on ARM64.
- **~600 h:** Take a published CVE, diff the patch, recover the bug, write the PoC.
- **~750 h:** Score in a team CTF with a solve you personally contributed.

## Ship

1. An end-to-end exploit against a target with modern mitigations enabled, with a writeup explaining each mitigation and how it was addressed.
2. One valid finding submitted to an in-scope bug bounty programme under written authorization, handled to resolution.
3. A patch-diffing writeup: CVE → diff → root cause → PoC.

## Gate · three parts, all required

1. **Reliability.** Against a binary with NX, full RELRO, PIE, stack canaries and ASLR all on, given a known primitive: arbitrary code execution unaided at ≥80% reliability across 100 consecutive automated runs. 12 cumulative hours.
2. **Discovery under mitigations.** A *different* binary, mitigations on, no bug disclosed to you: find it and exploit it. 16 cumulative hours.
3. **Speed.** A bug class you've already met, on an unfamiliar binary, within four contiguous hours.

**Fail if:** it works when you run it and not when someone else does.

**This is the employable line and the terminus of the constrained track.**
