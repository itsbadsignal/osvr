# 01 · The Machine

> Understand what a computer physically does, from a single logic gate up to a CPU.

**Requires:** [M0 gate](../prerequisites/00-the-terminal.md) · **Hours:** 45-75 · **Next:** [M2 · The Program](02-the-program.md)

## Outcomes

- Decode a machine word four ways by hand.
- Explain power-on to prompt at block-diagram level.
- Have built enough of a CPU to believe the machine is comprehensible.

## Resources

| Role | Resource | Cost | Notes |
|------|----------|------|-------|
| Core | [Code](https://www.codehiddenlanguage.com/) (Petzold, 2nd ed.) | ~€30 | The one book to buy if you buy only one. |
| Core | [Nand2Tetris](https://www.nand2tetris.org/) · projects 1-5 | Free | ALU, memory, CPU. Runs in the [browser IDE](https://www.nand2tetris.org/software). Stop at project 5; project 6 is in M2. |
| Alt | [Nand2Tetris Part I on Coursera](https://www.coursera.org/learn/build-a-computer) | Free to audit | Same material, video-led and scheduled. |
| Alt | [Ben Eater · 8-bit breadboard computer](https://eater.net/8bit) | ~€300 parts | Physical build. Optional. |
| Ref | [The Elements of Computing Systems](https://mitpress.mit.edu/9780262539807/the-elements-of-computing-systems/) (Nisan & Schocken) | ~€40 | The book behind Nand2Tetris. |
| Practice | [picoCTF](https://picoctf.org/) | Free | Beginner encoding, forensics, trivial reversing. |

The Hack machine has no cache, MMU, privilege rings, interrupts or real ABI. Finishing it is not understanding modern architecture; M3 and M4 close that gap.

## Milestones

- **~30 h:** ALU (project 2) built and tested, and you can explain every control bit.

## Ship

A public repo implementing base conversion and fixed-width integer arithmetic from scratch (no built-in conversion), plus an explanation of two's complement and IEEE-754 for someone who has never seen either.

## Gate · 1 hour

Given a 32-bit hex word on paper, state what it is as: (a) unsigned integer, (b) two's-complement signed, (c) IEEE-754 single float, (d) four ASCII bytes. Do it by hand, with no calculator, in under five minutes. Then, for a second word, state what the sum overflows to and why, and what the bytes mean little-endian versus big-endian.

**Fail if:** you reach for a tool, or you can do (a) and (d) but not (b) and (c).

**Unlocks:** C and assembly.
