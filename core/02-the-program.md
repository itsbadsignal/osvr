# 02 · The Program

> C properly, the process as a laid-out address space, and the discrete math everything after M8 rests on.

**Requires:** [M1 gate](01-the-machine.md) · **Hours:** 320-480 · **Next:** [M3 · The Instruction Stream](03-the-instruction-stream.md)

## Outcomes

- Write and debug C that manages its own memory correctly.
- Draw a stack frame and verify it against the compiled binary.
- Implement the core data structures rather than import them.
- Write a proof by induction and reason about asymptotic cost.
- Treat undefined behaviour as a vulnerability class.

## Resources

| Role | Resource | Cost | Notes |
|------|----------|------|-------|
| Core | [CS50x](https://cs50.harvard.edu/x/) · weeks 1-5 | Free | First pass at C. Stop at week 5; after that it leaves systems. |
| Core | [Modern C](https://gustedt.gitlabpages.inria.fr/modern-c/) (Gustedt) | Free | Second pass, after CS50, never before. |
| Core | Implement in C: dynamic array, linked list, hash table, BST, graph with BFS/DFS | Free | No course. The bottleneck is code volume. |
| Core | [Algorithms](https://jeffe.cs.illinois.edu/teaching/algorithms/) (Erickson) | Free | Read the chapters your data-structure work touches. |
| Core | [Discrete Mathematics: An Open Introduction](https://discrete.openmathbooks.org/dmoi3.html) (Levin) | Free | Logic, sets, induction, combinatorics, graphs. Prerequisite for M5 crypto and M8. |
| Core | [Nand2Tetris](https://www.nand2tetris.org/) · project 6 | Free | Write the assembler. |
| Core | Valgrind, ASan, UBSan, gdb | Free | Run everything under them from week one. |
| Alt | [Beej's Guide to C Programming](https://beej.us/guide/bgc/) | Free | If CS50's video format doesn't suit you. |
| Alt | [MIT 6.042J · Math for CS](https://ocw.mit.edu/courses/6-042j-mathematics-for-computer-science-spring-2015/) | Free | Lecture-led alternative to Levin. |
| Ref | [cppreference · C](https://en.cppreference.com/w/c) · [undefined behaviour](https://en.cppreference.com/w/c/language/behavior) | Free | The standard-behaviour lookup. |
| Ref | *The C Programming Language* (K&R) | ~€35 | Pre-C99. A dictionary, never a teaching text. |
| Practice | [pwn.college · Intro to Cybersecurity](https://pwn.college/dojos) · picoCTF general skills | Free | |

## Milestones

- **~80 h:** CS50 week 5 done. Linked list in C with correct frees, clean under a memory checker.
- **~180 h:** Hash table from scratch with tests; explain the load-factor trade-off.
- **~280 h:** Nand2Tetris assembler passes all test files.
- **~400 h:** Your own C program, ≥1,000 lines, tested.

## Ship

A C program you actually wanted, public, with tests and a README explaining the design decisions, plus a post on a UB bug you caused and caught.

## Gate · 3 hours

1. For a recursive function you wrote, draw the stack frame at max depth on paper: saved registers, return address, local offsets, growth direction. Compile it and verify against the binary.
2. Classify five claims about program behaviour as defined, unspecified, implementation-defined or undefined, citing why.
3. Prove by induction that one of your data structures maintains its invariant.

**Fail if:** the drawing and the binary disagree and you can't say why.

After the gate, recalibrate every downstream hour estimate against your actual pace.
