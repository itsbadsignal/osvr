# 08 · The Theory

> Automata, compilers, dataflow and static analysis, at the depth research consumes, placed where it is finally motivated.

**Requires:** [07 gate](07-the-defended-target.md) · **Hours:** 160–260 · **Next:** [09 · The Research](09-the-research.md)

Theory sits here, after exploitation, on purpose: you don't need automata to smash a stack, and front-loading it is how people burn out before they've had any fun. The counter-argument, that dataflow and grammars would make modules 06–07 easier if learned earlier, is genuinely strong; see [known gaps](../README.md#known-gaps).

## Outcomes

- State what a finite automaton cannot do, and name three vulnerability classes that exist because two implementations disagreed about a grammar.
- Write a dataflow analysis over a control-flow graph.
- Explain why no analyser decides an arbitrary property of an arbitrary program, and what that implies about your fuzzer and your auditor being complements.
- Read the program-analysis literature, not just consume its tools.

## Resources

| Role | Resource | Cost | Notes |
|------|----------|------|-------|
| Core | [Models of Computation](https://jeffe.cs.illinois.edu/teaching/algorithms/models/) (Erickson) | Free | Regular and context-free languages, automata, undecidability. Read for the results and constructions, not to grind every proof. |
| Core | [Crafting Interpreters](https://craftinginterpreters.com/) (Nystrom) | Free | Build a scanner, parser, bytecode VM and GC. You're here so that when you attack a JIT you're attacking something whose shape you've built once. The parsing and bytecode chapters are load-bearing. |
| Core | [Static Program Analysis](https://cs.au.dk/~amoeller/spa/) (Møller & Schwartzbach) | Free | Dataflow, lattices, fixed points, abstract interpretation, pointer analysis, with exercises. The highest-leverage resource in the module. |
| Core | [LLVM · writing a pass](https://llvm.org/docs/WritingAnLLVMNewPMPass.html) · [IR reference](https://llvm.org/docs/LangRef.html) | Free | Write a real pass. Instrumentation is how modern fuzzing works, so this pays out twice. |
| Alt | *Introduction to the Theory of Computation* (Sipser, 3rd ed.) | ~€70 | The canonical automata text. Skip the complexity-theory back half unless you're entering the symbolic-execution track. |
| Alt | *Engineering a Compiler* (Cooper & Torczon) | ~€80 | The analysis chapters only: dataflow, SSA, CFGs, dominators. Skip code generation. |
| Ref | [Algorithms](https://jeffe.cs.illinois.edu/teaching/algorithms/) (Erickson) · [Discrete Math](https://discrete.openmathbooks.org/dmoi3.html) (Levin) | Free | Carried over from module 02, as needed. |
| Practice | [ANTLR](https://www.antlr.org/) or a hand-written recursive-descent parser for a real input format | Free | Grammars become concrete only once you've written one for an input attackers control. |

## Milestones

- **~60 h:** Given two HTTP implementations, explain in grammar terms exactly why they can disagree about where one request ends.
- **~120 h:** A working interpreter with its own bytecode VM.
- **~200 h:** An LLVM pass that reports something useful about a real program.

## Ship

A published analysis tool, however small, with the theory written up: what it computes, what it soundly cannot compute, and where it produces false results. Naming your tool's incompleteness is the deliverable.

## Gate · 4 cumulative hours

1. Given an obfuscated control-flow graph, identify the flattening construct and describe the dataflow analysis that recovers the original structure.
2. Write a dataflow analysis (reaching definitions or taint) over a small CFG by hand, and state its lattice and its fixed point.
3. Explain why a static analyser cannot in general decide whether an arbitrary program contains a given bug, and what follows for how you allocate research time.

**Micro-discovery:** find one incorrect claim in published analysis tooling or documentation, and demonstrate it.

**Unlocks:** program analysis, symbolic execution, JIT and deobfuscation work.
