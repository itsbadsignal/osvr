# 03 · The Instruction Stream

> Read x86-64 fluently, without a decompiler.

**Requires:** [02 gate](02-the-program.md) · **Hours:** 200–300 · **Next:** [04 · The System](04-the-system.md)

## Outcomes

- Read compiled code and reconstruct what the source did.
- Identify calling convention, argument count and types from disassembly alone.
- Explain the memory hierarchy, paging and privilege rings as mechanisms.
- Drive gdb fluently.

## Resources

| Role | Resource | Cost | Notes |
|------|----------|------|-------|
| Core | [pwn.college · Computing 101, Playing With Programs](https://pwn.college/dojos) | Free | ~95% hands-on. Do these before the books. |
| Core | [OST2 · Arch1001: x86-64 Assembly](https://ost2.fyi/Arch1001) | Free | The deepest free architecture material. High dropout risk, so pair it with pwn.college. |
| Core | [OST2 · Dbg1012: Introductory GDB](https://ost2.fyi/Dbg1012) | Free | Debugger fluency, needed by module 06. |
| Core | [CS:APP](https://csapp.cs.cmu.edu/) (3rd ed.) · chs. 2–3, 6 + Bomb Lab & Attack Lab | ~€70 used | The labs are the reason to use it. Not the IA-32 2nd edition. |
| Core | [Compiler Explorer](https://godbolt.org/) | Free | Keep it open always. |
| Alt | [OST2 · Arch1005: RISC-V](https://ost2.fyi/Arch1005) | Free | Cleaner ISA for concepts. A supplement, not a substitute. |
| Ref | [Intel SDM](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html) | Free | The primary source. |
| Ref | [Reverse Engineering for Beginners](https://beginners.re/) (Yurichev) | Free | |
| Practice | [crackmes.one](https://crackmes.one/) · [challenges.re](https://challenges.re/) · picoCTF reversing | Free | Volume. Fluency comes from repetition. |

## Milestones

- **~80 h:** Reconstruct a compiled function's control flow from disassembly, no decompiler.
- **~160 h:** With source and disassembly side by side, explain every instruction.
- **~250 h:** Reverse a 200-line stripped binary to accurate pseudocode.

## Ship

An annotated disassembly of a program you wrote: walk the generated assembly line by line, explaining what the compiler did and why.

## Gate · 3 hours

Given a stripped binary you haven't seen, identify the calling convention, the number and types of arguments to a function someone else chooses, and the syscall boundary. Use a disassembler only: no decompiler, no internet.

**Fail if:** you can only work with the decompiler on.
