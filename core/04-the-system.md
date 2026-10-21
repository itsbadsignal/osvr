# 04 · The System

> Descend to the syscall boundary until the loader, the kernel and the wire are all visible at once.

**Requires:** [03 gate](03-the-instruction-stream.md) · **Hours:** 300–420 · **Next:** [05 · The Boundary](05-the-boundary.md)

## Outcomes

- Explain every step from `exec` to `main`.
- State which mitigations a toolchain applied, and how you know.
- Reason about concurrency as a correctness problem.
- Implement a protocol client from its spec and account for every byte on the wire.

## Resources

| Role | Resource | Cost | Notes |
|------|----------|------|-------|
| Core | [OSTEP](https://pages.cs.wisc.edu/~remzi/OSTEP/) | Free | Virtualization, concurrency, persistence. Do the homework and projects, not just the reading. |
| Core | [MIT 6.1810 · xv6 labs](https://pdos.csail.mit.edu/6.1810/) | Free | Implement page tables, traps, COW, threads. The highest-leverage free systems work. |
| Core | [OST2 · Arch2001: x86-64 OS Internals](https://ost2.fyi/Arch2001) | Free | Rings, interrupts, paging from the ISA side. Requires Arch1001. |
| Core | ELF & PE by hand: [ELF spec](https://refspecs.linuxfoundation.org/elf/elf.pdf), [PE format](https://learn.microsoft.com/en-us/windows/win32/debug/pe-format), `readelf`, `objdump`, a hex editor | Free | Write a parser for each. Sections, segments, relocations, PLT/GOT, TLS. |
| Core | [Computer Networks: A Systems Approach](https://book.systemsapproach.org/) | Free | The model. |
| Core | [Beej's Guide to Network Programming](https://beej.us/guide/bgnet/) | Free | Write the clients. |
| Core | Build: a networked service, and a protocol client from an RFC with no library | Free | |
| Ref | [Life of Binaries](https://ost2.fyi/Arch2821) (OST2) | Free | Compile → link → load → run. |
| Ref | [The Linux Programming Interface](https://man7.org/tlpi/) (Kerrisk) | ~€70 | The syscall reference. |
| Ref | *TCP/IP Illustrated, Vol. 1* (Fall & Stevens) | ~€60 | The bytes. |
| Ref | *Windows Internals* (Russinovich et al.) | ~€60 | If Windows-bound. |
| Ref | Codebases: [xv6-riscv](https://github.com/mit-pdos/xv6-riscv), [musl](https://musl.libc.org/), [SQLite](https://www.sqlite.org/src/doc/trunk/README.md) | Free | Read a whole system once. |
| Practice | picoCTF binary exploitation, first problems only | Free | First contact with a stack overflow. |

## Milestones

- **~70 h:** Trace `open()` from libc stub to kernel and back, naming the privilege transition.
- **~150 h:** Trace a dynamic call through PLT/GOT in a live process; explain lazy binding.
- **~250 h:** Write a deliberate race, show it firing, fix it, prove the fix.
- **~330 h:** xv6 page-table and trap labs done.

## Ship

1. A loader-to-entry-point teardown of a real binary, from your own observation.
2. A small tool operating at the syscall layer.

## Gate · 4 hours

1. Given a binary, state which mitigations were applied and how you know.
2. Explain from memory what the kernel does on a page fault, and how that differs from a segfault reaching the process.
3. Given a racy program, identify the interleaving and the minimal fix.
4. Implement a binary-protocol client from its spec, capture your traffic, and account for every byte, including padding and framing.

**Fail if:** any byte is unexplained.

**Unlocks:** exploitation (still only in your own lab until the module 05 gate). From here you're employable as a junior systems or backend engineer.
