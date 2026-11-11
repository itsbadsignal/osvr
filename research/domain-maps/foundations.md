# Domain map: Foundations (FND track): Linux lab, C, build/debug, x86-64 via debugger, ELF/process internals, Python tooling, beginner on-ramp
Researched: 2026-11-10   Questions answered: 9/13 fully, 4/13 partially (see Question plan)
Mode: BUILD / metalearning. Author: researcher agent. Every claim is from a page fetched on 2026-11-10 unless tagged `local observation` (run on the researcher's machine), `inference` (researcher judgement, not sourced), `unverified`, or `needs-lab-verification`. Fetch tool summarises pages with a small model, so figures are as reported by that summary; module-builder should re-read any page before quoting numbers.

## Question plan (written before searching)
- Q1 What do the free beginner-programming options offer (active, exercise-based, autograded) and which should OSVR recommend for a learner who cannot program yet? ANSWERED (Python and C options; evidence of effectiveness for OSVR's population is inference)
- Q2 Which C learning resources fit "pointers, arrays, strings, structs, integers, UB" with exercises? PARTIAL (Exercism C, Beej, Modern C fetched; no resource found that targets the security reading of C)
- Q3 What do ASan and UBSan currently detect and what do they miss? ANSWERED (docs plus local test)
- Q4 What are default compiler/linker hardening settings on Debian, Ubuntu, Fedora, Arch today? PARTIAL (Debian and Arch answered; Ubuntu partial; Fedora blocked by bot protection)
- Q5 What gdb extension should FND use and what does it require? ANSWERED
- Q6 What public material exists for x86-64 asm and debugger skills (OST2, pwn.college, CS:APP)? ANSWERED, hours not published anywhere
- Q7 What authoritative references cover ELF, loader, PLT/GOT? PARTIAL (man pages fetched; System V psABI PDF not reached; Drepper/ELF-spec not fetched)
- Q8 pwntools current state and install? ANSWERED
- Q9 What do educators and experts name as the hardest step for each skill? PARTIAL (Delphi paper and pointer-misconception literature found but full text unreadable; most RDS statements below are `inference`)
- Q10 Which compiler flags should a lab build use for vulnerable-by-design builds versus sanitizer builds? ANSWERED (OpenSSF guide, ASan docs)
- Q11 Docker/VM lab guidance (ptrace, ASLR toggles, ptrace_scope)? PARTIAL (local observation only; Docker not installed locally, nothing verified for containers)
- Q12 Real CVE candidates for FND-04? NOT ANSWERED (out of time budget; no target selection performed, see Candidate direct targets)
- Q13 Hours to competence for C and assembly from zero? NOT ANSWERED (no provider publishes it; consistent with FIELD-SYNTHESIS Q6)

## Why it matters
FND serves `rootcause` first (reading C and machine state to the line), then `exploit` and `find`, and `map` via FND-07 (research/FIELD-SYNTHESIS.md section 2). Nothing downstream (BX heap, VD fuzzing harnesses, RE) works without: reading C with a correct memory model, building with sanitizers, stepping a debugger, reading x86-64, and understanding how the loader resolves libc calls. Real bugs in this domain appear everywhere a C library parses data: the integer-conversion and lifetime bugs of FND-05 are the root cause behind most memory-safety CVEs (CERT rates signed overflow handling High severity and notes it "can lead to buffer overflows and the execution of arbitrary code" [INT32-C]).

## Concepts / Facts / Procedures

### Concepts (to understand)
- Object lifetime and storage duration: stack frame, heap, static/global; where an object lives determines what an out-of-bounds write touches.
- A pointer is a typed address; arrays decay to pointers; `sizeof` of an array vs a pointer; pointer arithmetic scales by element size.
- C strings are NUL-terminated byte arrays, with no length carried; off-by-one and missing-terminator bugs follow.
- Signed overflow is undefined behaviour (UB), unsigned wraps; the compiler may assume UB never happens and delete checks on that basis [Lattner, INT32-C]. UB means "anything may happen", not "crashes" (null dereference is not guaranteed to fault) [Lattner].
- Integer promotion, signed/unsigned conversion and truncation turn a length check into an OOB access (CWE-190, CWE-191, CWE-680 per INT32-C mapping).
- Shadow-memory sanitizers: instrumentation plus a custom allocator report the error at the access, not later [ASan paper abstract, ASan docs].
- Compilation pipeline: preprocess, compile, assemble, link; debug info (DWARF) maps machine state back to C.
- x86-64 machine model: registers, flags, stack frame, calling convention (System V AMD64), caller/callee-saved registers. Experts claim ~20-30 instructions plus variants let you read most programs [OST2 Arch1001 page].
- ELF as a container: headers, segments (loader view) vs sections (linker view), dynamic section, relocations.
- Lazy binding: first call to a libc function goes through PLT stub to the resolver, then the GOT entry is patched; `LD_BIND_NOW` forces eager resolution [ld.so(8)]. Full RELRO makes GOT read-only after relocation [OpenSSF guide].
- Virtual memory layout of a process, ASLR, PIE.
- Mitigation inventory the learner must recognise (and does not yet have to bypass): stack protector (canary), PIE/ASLR, NX, RELRO, FORTIFY_SOURCE, stack clash protection, CET (`-fcf-protection`) [OpenSSF guide].

### Facts (to memorise)
- System V AMD64 argument registers (rdi, rsi, rdx, rcx, r8, r9), return in rax, callee-saved set, 16-byte stack alignment at call. Source to confirm against: System V psABI [x86-64 psABI repo; PDF not fetched, `status: unverified` for these specifics].
- Syscall number conventions on x86-64 Linux (e.g. exit is 60 per the pwn.college module) [pwn.college Computing 101, Your First Program].
- Default flags to compile intentionally weak lab binaries: needs explicit `-fno-stack-protector -no-pie -z norelro -D_FORTIFY_SOURCE=0` on current toolchains (see Mitigation landscape).
- Sanitizer facts: ASan about 2x slowdown, does not support static linking, maps 16+ TB virtual space on 64-bit [ASan docs]; UBSan sub-check list [GCC docs].
- ptrace/core-dump-related sysctls: `kernel.randomize_va_space`, `kernel.yama.ptrace_scope` (local observation: 2 and 1 on this Arch box).
- gdb commands for breakpoints, stepping (`si`, `ni`), examine memory (`x/`), registers, backtrace, watchpoints [gdb manual chapters 5, 8, 10].

### Procedures (to automate)
1. Start a timeboxed session: declared goal, end-of-session recall (FND-01; cross-track).
2. Build a C project at a pinned commit with `-g -O1 -fsanitize=address,undefined -fno-omit-frame-pointer` (ASan docs recommend -O1 or higher, -g, frame pointers); run the test suite or a crashing input; symbolise with `llvm-symbolizer`.
3. Read an ASan report top-down: error kind, access size and direction, frame of the access, allocation and free stacks, shadow bytes around the address.
4. Reproduce a crash in gdb: `run`, `bt`, `frame N`, `info locals`, `x/16gx $rsp`, `watch`, `catch`.
5. Compile the same function at `-O0` and `-O2`, `objdump -d -M intel` or gdb `disassemble /s`, map each C line to instructions; draw the frame.
6. Trace a libc call: break at call site, step into PLT, inspect GOT before and after first call, then repeat with `LD_BIND_NOW=1` [ld.so(8)].
7. Script a target with pwntools: `process()`, `ELF()`, `gdb.attach`/`gdb.debug`, `cyclic`, one command per attempt [pwntools docs module index].

## Mitigation landscape
Default compiler hardening on current distros. This is the fact most likely to mislead learners, because a naive `gcc -o t t.c` is no longer vulnerable-by-default. Triangulation status per distro:

| Distro | PIE | Stack protector | FORTIFY_SOURCE | RELRO/BIND_NOW | Other | Evidence |
|---|---|---|---|---|---|---|
| **Debian** (package builds, dpkg-buildflags) | gcc default on amd64 and many arches; no global dpkg default | stackprotectorstrong enabled (since dpkg 1.17.11) | level 2, needs -O1 | relro on, bindnow off (opt-in) | stackclash and branch protection (`-fcf-protection` on amd64) on since dpkg 1.22.0 | T1: dpkg-buildflags man page (Debian manpages, fetched). Current Debian release number not stated on the page. |
| **Ubuntu** | gcc configured `--enable-default-pie` per search summary of the Ubuntu wiki | -fstack-protector-strong default per same summary | level 3 by default with optimisation from Ubuntu 24.04 (gcc-13 13.2.0-9ubuntu1) | not verified | not verified | Level-3 claim: T1 Launchpad bug 2012440 (fetched). Rest: Ubuntu wiki `CompilerFlags` returned 404 on direct fetch; only a search-engine summary. `needs-lab-verification` on a real Ubuntu 24.04/26.04 box |
| **Fedora** | not verified | not verified | level 3 targeted for Fedora 38 (change accepted, final outcome not recorded on the page) | not verified | not verified | T2: Fedora change page (fetched). Packaging guidelines, redhat-rpm-config and buildflags.md were blocked by bot protection. `needs-lab-verification`; `rpm --eval '%{build_cflags}'` on Fedora. Note: the separate "HardenedCompiler" proposal (FORTIFY_SOURCE=2, stack-protector-strong as compiler defaults) is tagged ChangeRejected, so Fedora hardening is via build flags, not compiler defaults. |
| **Arch** | local gcc: PIE default (`--enable-default-pie`) | local gcc: `-fstack-protector-strong` enabled by default (`--enable-default-ssp`) | package builds: `-D_FORTIFY_SOURCE=3` in makepkg.conf; the bare compiler does not add it | package builds: `-z relro -z now`; a bare `gcc` link here gave no BIND_NOW (partial RELRO) | `-fstack-clash-protection -fcf-protection`, frame pointers in package CFLAGS; gcc local default `-fcf-protection=full` per `-Q --help` | `local observation`: gcc 16.2.1 on Arch, `/etc/makepkg.conf`, `readelf`. Not independently triangulated. |

Triangulated cross-distro statement: modern GCC on the mainstream distros produces PIE with stack protector (strong) by default; this is supported by Debian man page (PIE default on amd64 for gcc), Ubuntu summary, and the local Arch observation. FORTIFY_SOURCE=3 is the new distro default in Ubuntu 24.04 (T1) and Fedora 38 (T2 change page) and Arch makepkg (local). Compiler default for FORTIFY is not on in plain `gcc` on Arch (local); Debian and Ubuntu patch gcc to enable it with optimisation (Ubuntu: T1 above; Debian: package-build flag, not necessarily a compiler default, see Open questions).

Local observation (gcc 16.2.1 on Arch, `gcc t.c -o t`, strcpy into `char[16]`): ELF type DYN (PIE), `GNU_STACK` RW (NX), `GNU_RELRO` present, no `BIND_NOW` (partial RELRO), `__stack_chk_fail` referenced (canary), `-fstack-clash-protection` disabled and `-ftrivial-auto-var-init=uninitialized` by default, `kernel.randomize_va_space=2`. A learner on Debian/Ubuntu will see slightly different results; the module should have the learner run `readelf`/`checksec` on their own binary rather than trust a table.

Reference guide for what each flag does and the minimum compiler versions: OpenSSF Compiler Options Hardening Guide for C and C++ (dated 2026-08-20): `-fstack-protector-strong` (GCC 4.9, Clang 6), `-D_FORTIFY_SOURCE=3` (GCC 12, Clang 9; needs -O1+), `-fPIE -pie`, `-Wl,-z,relro -Wl,-z,now`, `-fstack-clash-protection` (GCC 8, Clang 11), `-fcf-protection=full` (GCC 8, Clang 7), `-ftrivial-auto-var-init` (GCC 12, Clang 8). Two points relevant to labs: `_FORTIFY_SOURCE` is incompatible with ASan and other sanitizers so disable it in sanitizer builds [OpenSSF guide]; the guide does not give sanitizer versions.

Bypass families are BX-track content and are not claimed here.

## Rate-determining steps
No expert in a fetched source names a single hardest step for the whole track. What is sourced:
- **Pointers/memory model are among the hardest topics for novices.** Search results report a Delphi expert survey ranking pointers, references and memory model among the hardest, a Dundee study of C++ students finding the most difficult topics relate to lack of understanding of memory, and a 2022 study stating that lack of a useful pointer mental model is a reason novices fail data structures. These were read from search-result summaries, not full texts; the primary Delphi paper (Goldman et al., SIGCSE 2008) was found but its PDF was not machine-readable here. `unverified` pending a manual read.
- **UB is counter-intuitive.** The same code behaves differently at -O0 and -O2, and the standard imposes no requirements [Lattner, 2011].
- **x86-64 reading is bounded.** Arch1001 claims 20-30 instructions suffice for reading most programs; so the hard part is the frame/ABI model, not a large instruction set.

Researcher inference (not sourced; module-builder should treat as hypotheses to pilot):
- FND-02: predicting, for a given declaration, where bytes land and what an index past the end overwrites. Drills: draw-then-verify with `&`, `sizeof`, `x/` in gdb.
- FND-03: getting an unfamiliar project to build with sanitizers and symbols (autotools/cmake/dependency friction). This is also where the learner is most likely to quit; the field note that environment setup costs more than the bug (FIELD-SYNTHESIS finding 5) applies.
- FND-05: seeing the implicit conversion (usually `int` or `short` compared with `size_t`). ASan will not report it; UBSan reports signed overflow but not unsigned wrap (local observation plus GCC docs).
- FND-06: connecting `-O0` frame layout to C, then knowing what optimisation changes.
- FND-07: distinguishing the sections view from the segments view and seeing GOT patching live.

## Emphasise
- **Predict-then-verify drills** with gdb `x/` and ASan on tiny programs, because misconceptions about the memory model persist unless confronted with execution (inference, consistent with the misconception literature above).
- **Teach UB through the compiler's behaviour**, not as a list: compile the same snippet at `-O0` and `-O2` and show disappearing checks (Lattner explains the mechanism).
- **Know what each sanitizer misses.** Local observation (gcc 16.2.1, `-fsanitize=address,undefined -O1`): ASan caught a heap OOB write one byte past a `malloc(8)`; it did not flag an index-9 write inside `char buf[8]` within a struct (intra-object); UBSan `bounds` flagged that; `int + INT_MAX` was flagged as signed-integer-overflow, but `UINT_MAX + 1` (unsigned wrap) produced no report. GCC docs list no unsigned-overflow check under `undefined`, and the ASan docs page does not mention intra-object overflow or uninitialised reads (so a learner should not assume coverage). Clang does have extra `-fsanitize=unsigned-integer-overflow` options but this was not fetched, so `needs-lab-verification` with clang.
- **Build a vulnerable lab binary deliberately**: show the default-hardened build next to a `-fno-stack-protector -no-pie -D_FORTIFY_SOURCE=0` build and `readelf`/`checksec` both. Prevents the common tutorial failure where a 2014 recipe silently does not work.
- **Use `LD_BIND_NOW` and `info proc mappings`/`readelf -r`** for the PLT/GOT drill [ld.so(8)].
- **Read the real manuals** (gdb manual, elf(5), ld.so(8), Intel SDM, psABI) as references; the learner should become comfortable looking things up.
- **Scripting from day one in FND-08**: every debugger attempt becomes one command.

## Exclude
- **32-bit x86 / IA-32 material as the main line.** The CS:APP Buffer Lab (IA32) and Architecture Lab (Y86) 32-bit versions are legacy, replaced by the x86-64 Attack Lab; the 3rd edition of CS:APP is x86-64 only [csapp labs page, Pearson search summary]. DR-0001 already confines FND to x86-64.
- **Python 2 pwntools tutorials.** pwntools 4.15.0 is the last release supporting Python 2 and Python <3.10 [pwntools releases]. Install docs say Python 2 is deprecated; "Ubuntu LTS 14.04-20.04 best supported" is a stale list on the install page, treat as a hint that docs lag releases.
- **peda and old gdb plugin guides**: pwndbg's own README names PEDA, gdbinit and GEF as predecessors with limitations; use pwndbg or GEF.
- **Hand-rolled assembly-only courses with no C context** as the first exposure (inference; the pwn.college Computing 101 starts at machine code and assembly with Intel syntax, which suits a learner who wants asm first, but for OSVR's order the learner already reads C).
- **`gets()`/`strcpy` toy overflow recipes taught as current** without stating that a default build now has canaries and PIE (D9).
- **Long theory-only video courses.** Conflicts with the Ultralearning contract (activity); keep as optional reference.

## Candidate direct targets
Not researched in this pass (Q12 unanswered), to keep within scope. FND-04 needs: a small C library or tool with a public heap/stack OOB or UAF CVE, a pinned vulnerable tag that builds with sanitizers on a laptop in minutes, a fix commit, and an ASan trace. Recommend a follow-up `/research` run limited to FND-04 target selection (criteria in researcher charter). Do not use any target the module-builder cannot pin and build.

## Resources
Cards follow `templates/resource-card.yaml`. Scores: directness, currency, depth, activity, cost, accessibility (1-5). Where a field was not on the fetched page it says `unknown`. `role` is left to module-builder; suggestions are in the notes beneath each cluster.

### A. Beginner programming on-ramp (for learners who cannot yet program)
Recommendation after evaluation (reasoning below the cards): primary path is **Python first** with an autograded, free course, then C. Suggested pairing: CS50x for breadth plus C-before-Python in its own order, or Helsinki MOOC/Python for Everybody for Python only; Exercism for mentored practice in both Python and C. Exit criterion (inference): learner can write a 50-100 line program using functions, loops, lists, dicts and file I/O without a tutorial, then moves on to C. Evidence of which option works best for no-degree learners was not found (`unverified`); the pilot should measure.

```yaml
- title: "CS50x 2026"
  url: "https://cs50.harvard.edu/x/"
  author: "Harvard (CS50)"
  kind: course
  tier: T2
  cost: free
  published: 2026
  targets: "C first, then Python, SQL, HTML/CSS/JS; Scratch week 0"
  covers: "Eleven weeks plus final project; weekly problem sets; teaches C pointers and memory in-course (week list not read in full)"
  assumes: "none (open to those with or without prior programming experience)"
  scores: {directness: 2, currency: 5, depth: 3, activity: 5, cost: 5, accessibility: 4}
  role: alternative
  verified: 2026-11-10
  status: ok
  # Cost caveat: free as OpenCourseWare; problem set submission for feedback needs an edX account; certificates are paid (prices not on page).
  # Weekly hours not stated on page.

- title: "Python Programming MOOC 2024"
  url: "https://programming-24.mooc.fi/"
  author: "University of Helsinki, Department of Computer Science"
  kind: course
  tier: T2
  cost: free   # page does not state cost; free per general knowledge of the MOOC but NOT shown on the fetched page: recheck
  published: 2024
  targets: "Python; BSCS1001 Parts 1-7 (intro) and BSCS1002 Parts 8-14 (advanced), 5 ECTS each"
  covers: "University intro and advanced programming with exercises and an exam; part 14 is project work"
  assumes: "none stated"
  scores: {directness: 1, currency: 4, depth: 4, activity: 5, cost: 4, accessibility: 5}
  role: alternative
  verified: 2026-11-10
  status: ok
  # 2024 edition; page says the 2024 course stays open to end of 2024. A newer edition probably exists: check programming-26 or the current URL manually. Whether exercises are autograded not stated on the page.

- title: "Python for Everybody (py4e.com)"
  url: "https://www.py4e.com/"
  author: "Charles Severance, University of Michigan (page does not name the author; attribution from site, not read from page)"
  kind: course
  tier: T2
  cost: free
  published: unknown
  targets: "Python; version not stated on the page"
  covers: "Free materials, lectures, book and autograded assignments; also on Coursera/edX/freeCodeCamp"
  assumes: "not stated"
  scores: {directness: 1, currency: 3, depth: 3, activity: 4, cost: 5, accessibility: 5}
  role: alternative
  verified: 2026-11-10
  status: ok

- title: "Automate the Boring Stuff with Python (3rd edition)"
  url: "https://automatetheboringstuff.com/"
  author: "Al Sweigart (not named on the fetched summary; confirm manually)"
  kind: book
  tier: T2
  cost: free
  published: unknown
  targets: "Python; version not stated"
  covers: "Task-oriented Python for beginners; practice questions per chapter; workbook paid/separate"
  assumes: "no prior programming experience required"
  scores: {directness: 1, currency: 4, depth: 2, activity: 3, cost: 5, accessibility: 5}
  role: alternative
  verified: 2026-11-10
  status: ok

- title: "Exercism: Python track"
  url: "https://exercism.org/tracks/python"
  author: "Exercism"
  kind: course
  tier: T2
  cost: free
  published: unknown
  targets: "Python; 146 exercises over 17 concepts"
  covers: "Exercises with automated analysis and optional volunteer mentoring; web or CLI"
  assumes: "none stated"
  scores: {directness: 1, currency: 4, depth: 3, activity: 5, cost: 5, accessibility: 4}
  role: alternative
  verified: 2026-11-10
  status: ok

- title: "Exercism: C track"
  url: "https://exercism.org/tracks/c"
  author: "Exercism"
  kind: course
  tier: T2
  cost: free
  published: unknown
  targets: "C; 84 exercises"
  covers: "Exercises with automated analysis and volunteer mentoring on idiomatic C; page promotes Jiki for absolute beginners"
  assumes: "none stated, but C as a first language is hard (inference)"
  scores: {directness: 3, currency: 3, depth: 3, activity: 5, cost: 5, accessibility: 3}
  role: core
  verified: 2026-11-10
  status: ok
  # Does not teach memory-safety reading; pair with sanitizers (FND-03). Which C standard the tests use was not on the page.

- title: "Nand to Tetris"
  url: "https://www.nand2tetris.org/"
  author: "Noam Nisan and Shimon Schocken (book authors named on page)"
  kind: course
  tier: T2
  cost: free   # self-study free in non-profit use; Coursera version paid
  published: unknown
  targets: "Hardware simulator, assembler, VM, compiler, OS built in projects"
  covers: "Builds a computer from logic gates up; relevant to the machine model before FND-06"
  assumes: "none stated"
  scores: {directness: 2, currency: 4, depth: 5, activity: 5, cost: 4, accessibility: 3}
  role: alternative
  verified: 2026-11-10
  status: ok
  # Optional side quest for learners with no hardware background (inference). Hours not stated.
```

Evaluation notes. CS50x is the only fetched option with C included plus problem sets, so it can double as bridge to FND-02. Its weakness is breadth (SQL, web) that dilutes time; 11 weeks is long against OSVR's 6-hour FND-01. Python-first options give faster early wins and the language used by pwntools in FND-08 (inference). Exercism is the only fetched option with a free mentoring channel and a C track. pwn.college's Computing 101 starts at machine code and assembly rather than high-level programming, so it is an on-ramp to assembly, not a substitute for learning to program (see cards below). No source found on dropout or completion rates for these courses among self-taught adults; `unverified`.

### B. Linux workstation, lab and process internals

```yaml
- title: "Linux Luminarium (pwn.college dojo)"
  url: "https://pwn.college/linux-luminarium/"
  author: "pwn.college (Arizona State University)"
  kind: wargame
  tier: T2
  cost: free   # platform stated as open and free on pwn.college home page
  published: unknown
  targets: "Linux command line and core Linux concepts; 128 challenges in 16 modules plus Further Learning (dojo listing says 17 modules)"
  covers: "Hands-on command-line fundamentals run in the browser/hosted environment"
  assumes: "no Linux knowledge; page says work in progress"
  scores: {directness: 2, currency: 4, depth: 2, activity: 5, cost: 5, accessibility: 5}
  role: core
  verified: 2026-11-10
  status: ok
  # Runs on pwn.college infrastructure, not the learner's own lab; FND-01 still needs the local Docker/VM setup.

- title: "Computing 101 (pwn.college dojo)"
  url: "https://pwn.college/computing-101/"
  author: "pwn.college (Arizona State University)"
  kind: wargame
  tier: T2
  cost: free
  published: unknown
  targets: "x86-64 assembly (Intel syntax) via 'Your First Program' module, 132 challenges over 13 modules"
  covers: "How computers run programs from machine code up: memory, stack, control flow, endianness, debugging refresher, building a web server"
  assumes: "none stated; the fetched module page covers assembling with as/ld, not high-level programming"
  scores: {directness: 3, currency: 4, depth: 3, activity: 5, cost: 5, accessibility: 4}
  role: core
  verified: 2026-11-10
  status: ok
  # Fit for FND-06. Order is assembly first, so OSVR sequencing (C before asm) differs; module-builder decide. The page does not list prerequisites.

- title: "ld.so(8) - Linux manual page"
  url: "https://man7.org/linux/man-pages/man8/ld.so.8.html"
  author: "Linux man-pages project (man7.org)"
  kind: docs
  tier: T1
  cost: free
  published: 2026-08-03
  targets: "Linux man-pages 6.19"
  covers: "Dynamic linker: lazy binding by default, LD_BIND_NOW, LD_PRELOAD, LD_LIBRARY_PATH and search order"
  assumes: "knowledge of shared libraries"
  scores: {directness: 4, currency: 5, depth: 3, activity: 1, cost: 5, accessibility: 3}
  role: reference
  verified: 2026-11-10
  status: ok

- title: "elf(5) - Linux manual page"
  url: "https://man7.org/linux/man-pages/man5/elf.5.html"
  author: "Linux man-pages project (man7.org)"
  kind: docs
  tier: T1
  cost: free
  published: 2026-08-07
  targets: "Linux man-pages 6.19"
  covers: "ELF header, program headers, sections, dynamic tags; mentions .got/.plt only briefly"
  assumes: "C structs and basic linking"
  scores: {directness: 4, currency: 5, depth: 3, activity: 1, cost: 5, accessibility: 2}
  role: reference
  verified: 2026-11-10
  status: ok

- title: "x86-64 psABI (System V Application Binary Interface, AMD64 supplement)"
  url: "https://gitlab.com/x86-psABIs/x86-64-ABI"
  author: "x86-psABIs group"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "x86-64 psABI repository (311 commits, 7 tags, created 2019-03-01)"
  covers: "Authoritative calling convention source; the repository page itself does not link the PDF in the fetched text"
  assumes: "assembly basics"
  scores: {directness: 4, currency: 4, depth: 5, activity: 1, cost: 5, accessibility: 2}
  role: reference
  verified: 2026-11-10
  status: changed
  # Repository fetched; the rendered PDF and its current version/date were NOT located. Module-builder must fetch the PDF before citing specifics (registers, alignment, red zone). Facts above tagged unverified until then.

- title: "Intel 64 and IA-32 Architectures Software Developer's Manual (SDM)"
  url: "https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html"
  author: "Intel"
  kind: docs
  tier: T1
  cost: free   # PDFs downloadable; page does not use the word free
  published: 2026-10-09
  targets: "Volumes 1, 2 (A-Z instruction set), 3, 4; IA-32 SDM version 093"
  covers: "Authoritative instruction semantics and system programming"
  assumes: "assembly basics; Vol 2 is lookup only"
  scores: {directness: 4, currency: 5, depth: 5, activity: 1, cost: 5, accessibility: 2}
  role: reference
  verified: 2026-11-10
  status: ok
```

### C. C language and undefined behaviour

```yaml
- title: "What Every C Programmer Should Know About Undefined Behavior #1/3"
  url: "https://blog.llvm.org/2011/05/what-every-c-programmer-should-know.html"
  author: "Chris Lattner (LLVM Project Blog)"
  kind: writeup
  tier: T1
  cost: free
  published: 2011-05-13
  targets: "C semantics generally; Clang/LLVM behaviour of 2011"
  covers: "Why signed overflow, null deref and uninitialised reads are UB, how compilers exploit it, why results vary by platform"
  assumes: "basic C"
  scores: {directness: 3, currency: 3, depth: 4, activity: 1, cost: 5, accessibility: 4}
  role: core
  verified: 2026-11-10
  status: ok
  # 15 years old: concepts hold; compiler detail has moved on. Parts 2 and 3 of the series were not fetched.

- title: "INT32-C. Ensure that operations on signed integers do not result in overflow"
  url: "https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/rules/integers-int/int32-c"
  author: "SEI CERT C Coding Standard (Carnegie Mellon University SEI)"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "C; mentions C23 ckd_add/ckd_sub/ckd_mul"
  covers: "Rule, compliant checks, severity rating, CWE-190/191/680 mappings"
  assumes: "C integer types"
  scores: {directness: 4, currency: 4, depth: 3, activity: 1, cost: 5, accessibility: 3}
  role: reference
  verified: 2026-11-10
  status: ok
  # Wiki URL redirected (301) to this GitHub Pages site on 2026-11-10; the page lists no specific CVEs.

- title: "Modern C (C23 edition)"
  url: "https://gustedt.gitlabpages.inria.fr/modern-c/"
  author: "Jens Gustedt"
  kind: book
  tier: T2
  cost: free   # free public version dated 2024-10-15; print/eBook via Manning paid
  published: 2024-10-15
  targets: "C23 (bit-precise integers, stdckdint.h, nullptr, constexpr)"
  covers: "Whole-language book on current C"
  assumes: "not stated on page"
  scores: {directness: 2, currency: 5, depth: 4, activity: 2, cost: 5, accessibility: 2}
  role: reference
  verified: 2026-11-10
  status: ok
  # Page does not mention exercises. License CC BY-NC-ND 4.0. Heavy for a first C text; inference.

- title: "Beej's Guide to C Programming (chapter 5, Pointers)"
  url: "https://beej.us/guide/bgc/html/split/pointers.html"
  author: "Beej (Brian Hall); author not named on fetched page, confirm"
  kind: book
  tier: T3
  cost: free
  published: unknown
  targets: "C; notes memory examples reflect 'ca. 2024' hardware"
  covers: "Beginner explanation of addresses, &, *, passing pointers, NULL, sizeof; no exercises in this section"
  assumes: "earlier chapters"
  scores: {directness: 2, currency: 4, depth: 2, activity: 1, cost: 5, accessibility: 5}
  role: alternative
  verified: 2026-11-10
  status: ok
  # The guide's index page described itself as beta-quality with errors; T3 for that reason. Use only to fill the gentle-intro gap.

- title: "Computer Systems: A Programmer's Perspective, 3rd edition (CS:APP3e) and labs page"
  url: "https://csapp.cs.cmu.edu/3e/labs.html"
  author: "Randal E. Bryant and David R. O'Hallaron, Carnegie Mellon University (Pearson)"
  kind: course
  tier: T2
  cost: freemium   # book paid (Pearson); self-study lab handouts free per page, but download needs a CS:APP account
  published: 2015
  targets: "x86-64; Data Lab, Bomb Lab, Attack Lab (buffer overflow, code injection and ROP), Cache, Malloc, Shell, Proxy etc."
  covers: "Public self-study handouts without solutions; Bomb Lab is a Linux/x86-64 binary to defuse by reverse engineering; Attack Lab exploits x86-64 targets with buffer overflow bugs"
  assumes: "C; the book (not fetched)"
  scores: {directness: 3, currency: 3, depth: 5, activity: 5, cost: 3, accessibility: 2}
  role: reference
  verified: 2026-11-10
  status: ok
  # Page says handouts require a CS:APP account and are not clearly open to anyone; the Attack Lab targets listed as 'Ubuntu 12.4' (as written on page): dated targets, so use as exercise ideas, not as mitigation-era guidance. Book 3rd edition (2015, 1,120 pages per CMU page) is x86-64 only per publisher-listing summary. Book publisher date inconsistent across Pearson listings (2015 vs 2023/2024 store dates).
```

### D. Building, sanitizers, debuggers

```yaml
- title: "AddressSanitizer (Clang documentation)"
  url: "https://clang.llvm.org/docs/AddressSanitizer.html"
  author: "LLVM project"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "Clang/LLVM current docs (copyright 2007-2026); Linux, macOS, Android, FreeBSD, NetBSD, Windows 8.1+"
  covers: "Detects heap/stack/global OOB, UAF, UAR, use-after-scope, double/invalid free, leaks; about 2x slowdown; recommends -O1+, -g, -fno-omit-frame-pointer; no static linking; not for production"
  assumes: "C/C++ build basics"
  scores: {directness: 5, currency: 5, depth: 3, activity: 2, cost: 5, accessibility: 4}
  role: core
  verified: 2026-11-10
  status: ok
  # Page does not discuss shadow memory, redzones, intra-object overflow or uninitialised reads.

- title: "AddressSanitizer: A Fast Address Sanity Checker (USENIX ATC '12)"
  url: "https://www.usenix.org/conference/atc12/technical-sessions/presentation/serebryany"
  author: "Konstantin Serebryany, Derek Bruening, Alexander Potapenko, Dmitriy Vyukov"
  kind: paper
  tier: T1
  cost: free
  published: 2012
  targets: "C/C++; paper reports 73% average slowdown and 300+ Chromium bugs"
  covers: "Design (specialised allocator plus instrumentation); only the abstract page was read, not the PDF"
  assumes: "systems background"
  scores: {directness: 3, currency: 3, depth: 5, activity: 1, cost: 5, accessibility: 2}
  role: deep-dive
  verified: 2026-11-10
  status: ok
  # Shadow-memory mechanism not on the fetched page; fetch the PDF before citing mechanism.

- title: "Instrumentation Options (GCC manual): -fsanitize=address, undefined, -fsanitize-recover"
  url: "https://gcc.gnu.org/onlinedocs/gcc/Instrumentation-Options.html"
  author: "GNU Project"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "current GCC docs"
  covers: "Sanitizer flags; UBSan sub-check list; no unsigned-overflow check under undefined; recovery off by default only for address"
  assumes: "gcc usage"
  scores: {directness: 5, currency: 5, depth: 3, activity: 1, cost: 5, accessibility: 3}
  role: reference
  verified: 2026-11-10
  status: ok

- title: "Compiler Options Hardening Guide for C and C++"
  url: "https://best.openssf.org/Compiler-Hardening-Guides/Compiler-Options-Hardening-Guide-for-C-and-C++.html"
  author: "OpenSSF Best Practices Working Group"
  kind: docs
  tier: T1
  cost: free
  published: 2026-08-20
  targets: "GCC and Clang; minimum versions per flag"
  covers: "Hardening flags, their purpose and minimum compiler versions; notes FORTIFY_SOURCE incompatibility with sanitizers"
  assumes: "compiler basics"
  scores: {directness: 5, currency: 5, depth: 4, activity: 1, cost: 5, accessibility: 3}
  role: core
  verified: 2026-11-10
  status: ok
  # Only the first 100,000 of 187,653 characters were read (flag table). Defaults-per-distro not covered here.

- title: "dpkg-buildflags(1)"
  url: "https://manpages.debian.org/unstable/dpkg-dev/dpkg-buildflags.1.en.html"
  author: "Debian dpkg project"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "Debian unstable dpkg; features with 'since' versions up to 1.22.0"
  covers: "Which hardening features are default (format, fortify, stackprotectorstrong, stackclash, branch, relro) and which are opt-in (bindnow); pie follows gcc default per arch"
  assumes: "packaging basics"
  scores: {directness: 4, currency: 4, depth: 3, activity: 1, cost: 5, accessibility: 3}
  role: reference
  verified: 2026-11-10
  status: ok

- title: "Please add -D_FORTIFY_SOURCE=3 to default build flags (Launchpad bug 2012440)"
  url: "https://bugs.launchpad.net/ubuntu/+source/gcc-12/+bug/2012440"
  author: "Ubuntu (Launchpad)"
  kind: advisory
  tier: T1
  cost: free
  published: 2023
  targets: "Ubuntu 24.04 LTS and later; gcc-13 13.2.0-9ubuntu1"
  covers: "Confirms FORTIFY_SOURCE=3 is the default with optimisation from Ubuntu 24.04; no other flags listed"
  assumes: "none"
  scores: {directness: 4, currency: 4, depth: 1, activity: 1, cost: 5, accessibility: 4}
  role: reference
  verified: 2026-11-10
  status: ok

- title: "Changes/Add FORTIFY_SOURCE=3 to distribution build flags (Fedora)"
  url: "https://fedoraproject.org/wiki/Changes/Add_FORTIFY_SOURCE=3_to_distribution_build_flags"
  author: "Fedora Project"
  kind: advisory
  tier: T2
  cost: free
  published: 2023-01-04
  targets: "Fedora 38; redhat-rpm-config build flags; systemd exception"
  covers: "Proposal accepted for F38; final outcome after 2023-02-07 contingency not recorded on the page"
  assumes: "none"
  scores: {directness: 3, currency: 3, depth: 2, activity: 1, cost: 5, accessibility: 4}
  role: reference
  verified: 2026-11-10
  status: changed
  # Outcome unconfirmed. Fedora packaging guidelines and redhat-rpm-config buildflags.md could not be fetched (Anubis bot protection). Fetch manually.

- title: "pwndbg (GitHub)"
  url: "https://github.com/pwndbg/pwndbg"
  author: "pwndbg project"
  kind: tool
  tier: T2
  cost: free
  published: unknown
  targets: "GDB 12.1+ (Ubuntu 22.04/24.04 battle-tested), Python 3.10+; experimental LLDB 19+; qemu-user needs QEMU 8.1+, qemu-system 6.2+"
  covers: "GDB/LLDB plug-in for exploit developers; MIT; positions itself against PEDA, GEF, gdbinit"
  assumes: "gdb basics; install steps are on pwndbg.re/stable/setup (not read)"
  scores: {directness: 5, currency: 5, depth: 3, activity: 2, cost: 5, accessibility: 4}
  role: core
  verified: 2026-11-10
  status: ok

- title: "GEF (GDB Enhanced Features)"
  url: "https://github.com/hugsy/gef"
  author: "hugsy"
  kind: tool
  tier: T2
  cost: free
  published: unknown
  targets: "GDB 10.0+ with Python 3.10+; Python 3 only; x86, ARM, AArch64, MIPS, SPARC, PowerPC"
  covers: "Single-file GDB script, no external dependencies; MIT; 2,511 commits"
  assumes: "gdb basics"
  scores: {directness: 5, currency: 4, depth: 3, activity: 2, cost: 5, accessibility: 4}
  role: alternative
  verified: 2026-11-10
  status: ok
  # Easier in odd environments (single file, minimal deps). Latest release not shown on page.

- title: "Debugging with GDB (current manual)"
  url: "https://sourceware.org/gdb/current/onlinedocs/gdb.html/"
  author: "GDB developers / Free Software Foundation"
  kind: docs
  tier: T1
  cost: free
  published: 2026-11-10
  targets: "GDB 19.0.50.20261110-git (development snapshot; the stable release is older). Local: GDB 18.1"
  covers: "Stopping/continuing, reverse execution, record/replay, examining the stack and data, Python API"
  assumes: "none"
  scores: {directness: 5, currency: 5, depth: 5, activity: 1, cost: 5, accessibility: 3}
  role: reference
  verified: 2026-11-10
  status: ok
  # Pinned to a development snapshot; for stable use the release docs matching the learner's gdb version.

- title: "Debuggers 1012: Introductory GDB (OpenSecurityTraining2)"
  url: "https://p.ost2.fyi/courses/course-v1:OpenSecurityTraining2+Dbg1012_IntroGDB+2024_v1/about"
  author: "Xeno Kovah (OpenSecurityTraining2)"
  kind: course
  tier: T2
  cost: free
  published: 2024
  targets: "gdb"
  covers: "Mini-course to use gdb well enough for Arch1001 (x86-64) or Arch1005 (RISC-V); topic list not on page (search snippets mention breakpoints, registers/memory, stepping, attaching)"
  assumes: "Comfort with C and one assembly language"
  scores: {directness: 4, currency: 4, depth: 3, activity: 3, cost: 5, accessibility: 3}
  role: core
  verified: 2026-11-10
  status: ok
  # Duration not stated. Course page requires OST2 account for content (not tested). Prerequisite includes assembly, so for OSVR's order (asm after) it may be better used inside FND-06.

- title: "Architecture 1001: x86-64 Assembly (OpenSecurityTraining2)"
  url: "https://p.ost2.fyi/courses/course-v1:OpenSecurityTraining2+Arch1001_x86-64_Asm+2021_v1/about"
  author: "Xeno Kovah (OpenSecurityTraining2)"
  kind: course
  tier: T2
  cost: free
  published: 2021
  targets: "x86-64; prerequisite for Arch2001"
  covers: "x86-64 hardware concepts and common instructions; page says 20-30 instructions plus variants let you read most programs"
  assumes: "Comfort with C; recommends Learn-C.org and Dartmouth's 'C Programming with Linux' (edX) for learning C"
  scores: {directness: 4, currency: 4, depth: 4, activity: 4, cost: 5, accessibility: 3}
  role: core
  verified: 2026-11-10
  status: ok
  # Duration and tools not stated on the page (course content, e.g. Visual Studio vs gdb, not verified). Course content behind login.

- title: "pwntools documentation"
  url: "https://docs.pwntools.com/en/stable/"
  author: "Gallopsled / pwntools"
  kind: docs
  tier: T2
  cost: free
  published: unknown
  targets: "pwntools 4.15.0 (last release supporting Python 2 and <3.10; release date year not stated on the page, October 12); modules tubes, elf, gdb, asm, shellcraft, rop, context, cyclic"
  covers: "Exploit development library"
  assumes: "Python 3 basics"
  scores: {directness: 5, currency: 4, depth: 3, activity: 2, cost: 5, accessibility: 4}
  role: core
  verified: 2026-11-10
  status: ok
  # Releases page: https://github.com/Gallopsled/pwntools/releases. Install page lists Ubuntu 14.04-20.04 as best supported (stale); install needs binutils and Python dev headers.
```

## Open questions / conflicting sources
1. **Ubuntu and Fedora defaults** are not confirmed from primary pages (Ubuntu wiki 404, Fedora docs blocked). Needs a lab check on real Ubuntu 24.04 or 26.04 and Fedora containers: `gcc -v`, `readelf -lW`, `dpkg-buildflags --dump`/`rpm --eval '%{build_cflags}'`. Marked `needs-lab-verification`.
2. **PIE default conflict.** A 2014 blog (via search summary) says Ubuntu did not default to PIE; the current Ubuntu wiki summary says gcc is built `--enable-default-pie`. Debian's man page says PIE depends on the gcc default per architecture. Local Arch gcc defaults to PIE. Treat PIE-by-default as current but confirm per distro.
3. **FORTIFY_SOURCE default location.** Debian man page ties FORTIFY to dpkg package builds (level 2); Ubuntu patches gcc (level 3 from 24.04); Arch uses makepkg flags only (local). A learner compiling by hand gets different results per distro, so the lab Docker image should pin the base distro and state its defaults.
4. **ASan vs sanitizers in containers/ptrace:** Docker, `ptrace_scope` and `ASAN` interplay not tested (Docker is not installed on this machine). gdb in containers usually needs `SYS_PTRACE` and relaxed seccomp (inference, `needs-lab-verification`).
5. **CS:APP lab access.** Handouts listed as self-study but page says a CS:APP account is needed; availability of Attack Lab and its dated targets for 2026 learners needs a manual check.
6. **Pointer difficulty evidence** came from search-result summaries and mirrors of academic papers (Delphi paper full text unreadable here; PDF saved at /home/miguel/.claude/projects/-home-miguel-Repos-osvr/a28ace43-37bc-48d3-a261-9a2ce487b821/tool-results/webfetch-1794346339496-wr74hd.pdf, needs `pdftotext` to read; treat as untrusted download).
7. **Hours from zero** to C competence or asm reading: no provider publishes them. FND hour budgets (104 h) stay a pilot parameter.
8. **FND-04 target** is unselected (see Candidate direct targets).
9. **x86-64 psABI PDF** not located; calling-convention facts are unsourced in this file.
10. **OST2 learning paths page** (ost2.fyi/Learning-Paths.html) returned truncated/empty content; course syllabi (topics, hours) therefore unconfirmed.

## Sources
All fetched 2026-11-10 (verified: 2026-11-10) unless noted.
- https://clang.llvm.org/docs/AddressSanitizer.html
- https://gcc.gnu.org/onlinedocs/gcc/Instrumentation-Options.html
- https://www.usenix.org/conference/atc12/technical-sessions/presentation/serebryany
- https://blog.llvm.org/2011/05/what-every-c-programmer-should-know.html
- https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/rules/integers-int/int32-c (redirect from wiki.sei.cmu.edu)
- https://best.openssf.org/Compiler-Hardening-Guides/Compiler-Options-Hardening-Guide-for-C-and-C++.html (first 100k chars)
- https://manpages.debian.org/unstable/dpkg-dev/dpkg-buildflags.1.en.html
- https://bugs.launchpad.net/ubuntu/+source/gcc-12/+bug/2012440
- https://fedoraproject.org/wiki/Changes/Add_FORTIFY_SOURCE=3_to_distribution_build_flags
- https://fedoraproject.org/wiki/Changes/HardenedCompiler (rejected proposal)
- https://wiki.debian.org/Hardening (read; defaults not stated, points to dpkg-buildflags)
- https://github.com/pwndbg/pwndbg ; https://pwndbg.re/stable/ ; https://github.com/hugsy/gef
- https://sourceware.org/gdb/current/onlinedocs/gdb.html/
- https://docs.pwntools.com/en/stable/ ; https://docs.pwntools.com/en/stable/install.html ; https://github.com/Gallopsled/pwntools/releases
- https://p.ost2.fyi/courses/course-v1:OpenSecurityTraining2+Arch1001_x86-64_Asm+2021_v1/about ; https://p.ost2.fyi/courses/course-v1:OpenSecurityTraining2+Dbg1012_IntroGDB+2024_v1/about
- https://csapp.cs.cmu.edu/3e/labs.html ; https://csapp.cs.cmu.edu/3e/about.html
- https://pwn.college/ ; /dojos ; /linux-luminarium/ ; /computing-101/ ; /computing-101/your-first-program/
- https://man7.org/linux/man-pages/man5/elf.5.html ; https://man7.org/linux/man-pages/man8/ld.so.8.html
- https://gitlab.com/x86-psABIs/x86-64-ABI (PDF not located)
- https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html
- https://cs50.harvard.edu/x/ ; https://programming-24.mooc.fi/ ; https://www.py4e.com/ ; https://automatetheboringstuff.com/ ; https://www.nand2tetris.org/ ; https://exercism.org/tracks/c ; https://exercism.org/tracks/python
- https://gustedt.gitlabpages.inria.fr/modern-c/ ; https://beej.us/guide/bgc/ and /html/split/pointers.html
- Search-only leads, not sources (not fetched as pages): Ubuntu wiki CompilerFlags, Pearson product listings, academia.edu pointer-misconception mirrors, Class Central OST2 pages.
- Unreachable or unreadable: Fedora packaging guidelines and redhat-rpm-config (Anubis block); Arch wiki security guidelines (Anubis block); wiki.ubuntu.com CompilerFlags (404); ubuntu.com 24.04 security blog (404); ost2.fyi Learning-Paths (empty); Delphi PDF (binary); ideals.illinois.edu (403).
- Local observations (not sources): gcc 16.2.1, gdb 18.1, `/etc/makepkg.conf`, `readelf` and sanitizer runs on Arch Linux; clang, pwndbg, pwntools and docker were not installed.

## FND-01 lab sources (added 2026-11-11)

Scope: install pages and container-mechanism sources for the FND-01 lab, plus LeakSanitizer under containers. All cards below were fetched 2026-11-11. WebFetch returns summaries, so wording quoted is as relayed by the fetch tool; re-read the page if exact wording matters.

```yaml
- title: "Podman Installation Instructions"
  url: "https://podman.io/docs/installation"
  author: "Podman project (podman.io)"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "Debian 11+, Ubuntu 20.10+, Fedora, Arch (page gives apt/dnf/pacman one-liners; no Podman release version stated)"
  covers: "Distro install commands; notes passt is the Fedora rootless-network default (slirp4netns optional); Arch rootless problems point to the Arch wiki (not fetchable, Anubis)."
  assumes: "sudo access"
  scores: {directness: 4, currency: 4, depth: 2, activity: 3, cost: 5, accessibility: 5}
  role: reference
  verified: 2026-11-11
  status: ok

- title: "Install Docker Engine on Ubuntu"
  url: "https://docs.docker.com/engine/install/ubuntu/"
  author: "Docker Inc."
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "Ubuntu 26.10, 26.04 LTS, 24.04 LTS, 22.04 LTS (64-bit)"
  covers: "apt repository (recommended), manual .deb, convenience script (test/dev only). Warns published ports bypass ufw/firewalld; Docker supports only iptables-nft and iptables-legacy."
  assumes: "Remove docker.io/containerd/runc distro packages first"
  scores: {directness: 4, currency: 5, depth: 2, activity: 3, cost: 5, accessibility: 5}
  role: reference
  verified: 2026-11-11
  status: ok

- title: "Install Docker Engine on Debian"
  url: "https://docs.docker.com/engine/install/debian/"
  author: "Docker Inc."
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "Debian 13 Trixie (stable), Debian 12 Bookworm (oldstable); amd64, armhf, arm64, ppc64le"
  covers: "apt repository, manual .deb, convenience script (test/dev only)."
  assumes: "sudo access"
  scores: {directness: 4, currency: 5, depth: 2, activity: 3, cost: 5, accessibility: 5}
  role: reference
  verified: 2026-11-11
  status: ok

- title: "Install Docker Engine on Fedora"
  url: "https://docs.docker.com/engine/install/fedora/"
  author: "Docker Inc."
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "Fedora 45, 44, 43"
  covers: "RPM repository via dnf config-manager (recommended), manual RPM, convenience script (test/dev only)."
  assumes: "sudo access"
  scores: {directness: 4, currency: 5, depth: 2, activity: 3, cost: 5, accessibility: 5}
  role: reference
  verified: 2026-11-11
  status: ok

- title: "Rootless mode (Docker Engine security)"
  url: "https://docs.docker.com/engine/security/rootless/"
  author: "Docker Inc."
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "Docker Engine rootless mode"
  covers: "Needs newuidmap/newgidmap (uidmap package) and >=65536 entries for the user in /etc/subuid and /etc/subgid; install with dockerd-rootless-setuptool.sh (docker-ce-rootless-extras) or get.docker.com/rootless; verify via docker info showing context rootless. The fetched text had NO known-limitations section; limitations live elsewhere (not fetched)."
  assumes: "Linux user namespaces; systemd user session"
  scores: {directness: 4, currency: 5, depth: 3, activity: 3, cost: 5, accessibility: 4}
  role: reference
  verified: 2026-11-11
  status: ok

- title: "Seccomp security profiles for Docker"
  url: "https://docs.docker.com/engine/security/seccomp/"
  author: "Docker Inc."
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "Docker default seccomp profile (blocked-syscall table)"
  covers: "Table of syscalls the default profile blocks. ptrace row: 'Tracing/profiling syscall. Blocked in Linux kernel versions before 4.8 to avoid seccomp bypass.' Same page: 'Tracing/profiling arbitrary processes is already blocked by dropping CAP_SYS_PTRACE' because it 'could leak a lot of information on the host.' personality row: 'Prevent container from enabling BSD emulation. Not inherently dangerous, but poorly tested,' with 'potential for a lot of kernel vulnerabilities.' Fetch relayed no kernel condition on the personality row, and no statement of what personality arguments are permitted."
  assumes: "syscall and capability concepts"
  scores: {directness: 5, currency: 4, depth: 3, activity: 2, cost: 5, accessibility: 4}
  role: core
  verified: 2026-11-11
  status: ok

- title: "Bind mounts (Docker storage docs)"
  url: "https://docs.docker.com/engine/storage/bind-mounts/"
  author: "Docker Inc."
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "Docker Engine bind mounts"
  covers: "-v host:ctr[:opts] vs --mount type=bind,src=,dst= (preferred); -v creates a missing host dir, --mount errors unless bind-create-src; writable by default, ro/readonly to block; :z shared, :Z private SELinux relabel, changes host labels (do not use on /home or /usr), only -v supports labels."
  assumes: "none"
  scores: {directness: 5, currency: 5, depth: 3, activity: 3, cost: 5, accessibility: 5}
  role: core
  verified: 2026-11-11
  status: ok

- title: "podman-run (Podman documentation, man page)"
  url: "https://docs.podman.io/en/latest/markdown/podman-run.1.html"
  author: "Podman project"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "Podman latest docs (page text 145k chars; both halves read via offset)"
  covers: "--userns=keep-id with suboptions uid=, gid=, size= (size unsupported as root); --volume :z (shared relabel), :Z (private relabel), :U (chown host source to container UID/GID; slow, modifies host); --security-opt seccomp=unconfined|file.json; --privileged disables seccomp; default seccomp profile applied unless overridden."
  assumes: "container basics"
  scores: {directness: 5, currency: 5, depth: 3, activity: 3, cost: 5, accessibility: 4}
  role: core
  verified: 2026-11-11
  status: ok

- title: "namespaces(7) - Linux manual page"
  url: "https://man7.org/linux/man-pages/man7/namespaces.7.html"
  author: "Linux man-pages project (man-pages 6.19, page dated 2026-02-08)"
  kind: docs
  tier: T1
  cost: free
  published: 2026-02-08
  targets: "Linux namespaces; man-pages 6.19"
  covers: "Eight namespace types with clone flags: cgroup, IPC, network, mount (CLONE_NEWNS), PID, time, user, UTS. No numeric flag values."
  assumes: "syscall basics"
  scores: {directness: 3, currency: 5, depth: 3, activity: 1, cost: 5, accessibility: 3}
  role: reference
  verified: 2026-11-11
  status: ok

- title: "user_namespaces(7) - Linux manual page"
  url: "https://man7.org/linux/man-pages/man7/user_namespaces.7.html"
  author: "Linux man-pages project (man-pages 6.19, page dated 2026-02-08)"
  kind: docs
  tier: T1
  cost: free
  published: 2026-02-08
  targets: "Linux user namespaces; man-pages 6.19"
  covers: "uid_map format (inside-start, outside-start, length), single write, CAP_SETUID requirement, setgroups deny before gid_map; unprivileged creation since 3.8; full caps inside new userns but none outside; caps recomputed on execve; global ops and block-fs mounts need init-ns privilege."
  assumes: "capabilities, uid/gid model"
  scores: {directness: 4, currency: 5, depth: 5, activity: 1, cost: 5, accessibility: 2}
  role: deep-dive
  verified: 2026-11-11
  status: ok

- title: "cgroups(7) - Linux manual page"
  url: "https://man7.org/linux/man-pages/man7/cgroups.7.html"
  author: "Linux man-pages project (man-pages 6.19, page dated 2026-02-08)"
  kind: docs
  tier: T1
  cost: free
  published: 2026-02-08
  targets: "cgroup v1 and v2; man-pages 6.19"
  covers: "v1 per-controller hierarchies vs v2 unified hierarchy, no-internal-processes rule, delegation of a subtree to an unprivileged user (cgroup.procs, cgroup.subtree_control), nsdelegate (4.13+)."
  assumes: "process model"
  scores: {directness: 3, currency: 5, depth: 4, activity: 1, cost: 5, accessibility: 2}
  role: reference
  verified: 2026-11-11
  status: ok

- title: "podman 6.2.0-1 (Arch Linux package)"
  url: "https://archlinux.org/packages/extra/x86_64/podman/"
  author: "Arch Linux"
  kind: docs
  tier: T2
  cost: free
  published: unknown
  targets: "Arch extra repo, podman 6.2.0-1"
  covers: "Confirms podman is packaged in Arch [extra] at the version shown on 2026-11-11."
  assumes: "pacman"
  scores: {directness: 3, currency: 5, depth: 1, activity: 1, cost: 5, accessibility: 5}
  role: reference
  verified: 2026-11-11
  status: ok

- title: "Intermittent mozpack.errors.ErrorMessage: Error while signing ../../dist/firefox/libsoftokn3.so (Bugzilla 1545095)"
  url: "https://bugzilla.mozilla.org/show_bug.cgi?id=1545095"
  author: "Mozilla (reporter Narcis Beleuzu; patch by Wander Lairson Costa)"
  kind: writeup
  tier: T2
  cost: free
  published: unknown
  targets: "Mozilla CI docker-worker v201904171218, ASan builds (2019, fixed mozilla70)"
  covers: "Real-world report: LSan fatal error attributed to ptrace restrictions in newer Docker. Quote from patch description: 'In newer docker versions the LeakSanitizer will fail unless it runs in a privileged container.' Fix was to disable LSan in ASan builds; ASAN_OPTIONS detect_leaks=0 was suggested. allowPtrace reportedly did not help there. 2019 evidence, one CI environment, not a statement about current Docker."
  assumes: "ASan/LSan basics"
  scores: {directness: 3, currency: 2, depth: 2, activity: 1, cost: 5, accessibility: 3}
  role: reference
  verified: 2026-11-11
  status: ok
```

### Claim-by-claim support (FND-01 lab sources)
- Podman install on Debian 11+/Ubuntu 20.10+/Fedora/Arch: supported by podman.io page.
- Docker Engine install on Debian 12/13, Ubuntu 22.04/24.04/26.04/26.10, Fedora 43-45: supported by the three Docker install pages.
- Docker rootless needs uidmap and 65536 subuids/subgids: supported. Rootless limitations list: NOT in fetched text; unsupported.
- Docker default seccomp ptrace/personality: see verbatim quotes in the card. The page says ptrace is blocked before kernel 4.8 and that process tracing is blocked by dropping CAP_SYS_PTRACE. It does not (per fetch) state that ptrace is allowed on 4.8+; that is an inference and must not be asserted. Whether Docker's personality rule allows some arguments: not stated.
- `--userns=keep-id`, `:z`/`:Z`/`:U`: supported by podman-run page.
- Docker bind mounts `-v`/`--mount`, `:z`/`:Z`, ro: supported.
- namespaces/user namespace/cgroup mechanism: supported by man7.org 6.19 pages.
- LeakSanitizer requires ptrace: NOT stated in clang LeakSanitizer docs or the google/sanitizers wiki (both checked, neither mentions ptrace or containers). Only secondary evidence: Mozilla bug 1545095 (comment 0 quotes the LSan message "does not work under ptrace (strace, gdb, etc)"; patch says it fails in newer Docker unless privileged). A web search snippet also said `--cap-add SYS_PTRACE` fixed it for a Bitbucket user (community.atlassian.com thread, not fetched, so unverified). Status: `needs-lab-verification` for current Docker/Podman defaults; a one-line lab test (ASan+leak program in default container) is the way to settle it.
- Arch wiki unprivileged-containers section: not fetched (bot-blocked); unverified.

Sources (all fetched 2026-11-11): the URLs of the cards above, plus https://clang.llvm.org/docs/LeakSanitizer.html and https://github.com/google/sanitizers/wiki/AddressSanitizerLeakSanitizer (neither mentions ptrace). Unfetched lead: community.atlassian.com Bitbucket thread (search result only).


## FND-02 sources (added 2026-11-11)

All fetched 2026-11-11 (WebFetch summaries; quotes as relayed). N3220 PDF was a compressed binary stream the fetcher could not read, so it is not used.

```yaml
- title: "N1570 Committee Draft, ISO/IEC 9899:201x, Programming languages -- C (April 12, 2011), 6.2.4 Storage durations of objects"
  url: "https://port70.net/~nsz/c/c11/n1570.html"
  author: "ISO/IEC JTC1/SC22/WG14 (HTML rendering hosted on port70.net, not open-std.org)"
  kind: docs
  tier: T1
  cost: free
  published: 2011-04-12
  targets: "C11 draft; C17/C23 differ in detail but keep the same durations"
  covers: "Four storage durations: static (lifetime 'is the entire execution of the program', initialised once before startup), thread, automatic (lifetime from block entry until the block ends; fresh instance per recursive entry), allocated (rules deferred to 7.22.3)."
  assumes: "reading standardese; 842k-char page, section is in chars ~100k-200k"
  scores: {directness: 4, currency: 3, depth: 4, activity: 1, cost: 5, accessibility: 2}
  role: reference
  verified: 2026-11-11
  status: ok

- title: "Storage-class specifiers (cppreference, C language)"
  url: "https://en.cppreference.com/w/c/language/storage_duration"
  author: "cppreference.com contributors"
  kind: docs
  tier: T2
  cost: free
  published: unknown
  targets: "C through C23"
  covers: "Automatic, static, thread and allocated durations with one-line definitions and a short example (file-scope int static, local int automatic, malloc allocated). VLA exception noted. No last-modified date in fetched text."
  assumes: "basic C"
  scores: {directness: 4, currency: 4, depth: 3, activity: 1, cost: 5, accessibility: 4}
  role: core
  verified: 2026-11-11
  status: ok

- title: "elf(5) - Linux manual page"
  url: "https://man7.org/linux/man-pages/man5/elf.5.html"
  author: "Linux man-pages project (man-pages 6.19; footer dated 2026-08-07 per fetch)"
  kind: docs
  tier: T1
  cost: free
  published: 2026-08-07
  targets: "ELF; man-pages 6.19"
  covers: ".bss: uninitialised data, SHT_NOBITS, ALLOC+WRITE, zero-initialised at start. .data: initialised data, PROGBITS, ALLOC+WRITE. .rodata: read-only data, PROGBITS, ALLOC, typically in a non-writable segment."
  assumes: "none"
  scores: {directness: 4, currency: 5, depth: 3, activity: 1, cost: 5, accessibility: 3}
  role: core
  verified: 2026-11-11
  status: ok

- title: "Symbols (GDB manual): info symbol"
  url: "https://sourceware.org/gdb/current/onlinedocs/gdb.html/Symbols.html"
  author: "GDB project"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "GDB (current docs; local gdb was 18.1)"
  covers: "`info symbol addr` prints the symbol at an address, or nearest symbol plus offset, with section name (example '_start + 5 in section .text of /tmp/a.out'); inverse of `info address`. `info files` is NOT on this page."
  assumes: "running gdb"
  scores: {directness: 5, currency: 5, depth: 3, activity: 3, cost: 5, accessibility: 4}
  role: core
  verified: 2026-11-11
  status: ok

- title: "Commands to Specify Files (GDB manual): info files / info target"
  url: "https://sourceware.org/gdb/current/onlinedocs/gdb.html/Files.html"
  author: "GDB project"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "GDB current docs"
  covers: "`info files` and `info target` are aliases showing the current target: executable and core files in use and files symbols were loaded from. The fetch summary did not relay section-address output; confirm that by running it."
  assumes: "running gdb"
  scores: {directness: 5, currency: 5, depth: 2, activity: 3, cost: 5, accessibility: 4}
  role: core
  verified: 2026-11-11
  status: ok

- title: "Setting Watchpoints (GDB manual)"
  url: "https://sourceware.org/gdb/current/onlinedocs/gdb.html/Set-Watchpoints.html"
  author: "GDB project"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "GDB current docs"
  covers: "`watch expr`; `watch -l`/`-location` evaluates expr, takes its address and watches that memory sized by type, ignoring scope; rwatch/awatch need hardware; hardware vs single-stepping software watchpoints (set can-use-hw-watchpoints 0); local-variable watchpoints deleted when the block exits."
  assumes: "running gdb"
  scores: {directness: 5, currency: 5, depth: 4, activity: 4, cost: 5, accessibility: 4}
  role: core
  verified: 2026-11-11
  status: ok
```

Claim support:
- C has static/automatic/allocated storage durations: supported by N1570 6.2.4 and cppreference (both also list thread).
- Static objects are initialised once before startup / live the whole run: supported (N1570 quote; cppreference).
- Automatic lifetime is block entry to exit, new instance per recursion: supported by N1570.
- Allocated rules: N1570 only points to 7.22.3 (not read); cppreference gives the malloc/free summary.
- N3220 on open-std.org: NOT confirmed; PDF unreadable via fetcher. N1570 used via port70.net mirror, not open-std.org.
- .data/.bss/.rodata semantics: supported by elf(5). Does it say .bss is zero-filled: yes ("zero-initializes"). Which variable kinds land in which section (e.g. static int x = 0, string literals): NOT stated by it; needs-lab-verification via `readelf`/`info symbol`.
- `info symbol` behaviour: supported. `info files` behaviour: supported only at alias/overview level, output format not relayed.
- `watch -l` semantics: supported.

## FND-03 sources (added 2026-11-11)

All fetched 2026-11-11 (WebFetch summaries unless noted; quotes as relayed). The GNU make page was read directly with curl.

```yaml
- title: "CheckCCompilerFlag (CMake)"
  url: "https://cmake.org/cmake/help/latest/module/CheckCCompilerFlag.html"
  author: "Kitware / CMake project"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "CMake latest docs; CMAKE_REQUIRED_LINK_OPTIONS added in 3.14"
  covers: "check_c_compiler_flag(<flag> <variable>). CMAKE_REQUIRED_FLAGS: 'A space-separated string of additional flags to pass to the compiler. A semicolon-separated list will not work.' CMAKE_<LANG>_FLAGS contents are 'automatically prepended' to the compiler command before it. CMAKE_REQUIRED_LINK_OPTIONS: 'A semicolon-separated list of options to add to the link command.' The page does NOT say that the tested flag itself is passed at link time; it says the check target defaults to an executable (so it is linked), STATIC_LIBRARY compiles without linking."
  assumes: "CMake basics"
  scores: {directness: 5, currency: 5, depth: 3, activity: 2, cost: 5, accessibility: 3}
  role: core
  verified: 2026-11-11
  status: ok

- title: "CheckCSourceCompiles (CMake)"
  url: "https://cmake.org/cmake/help/latest/module/CheckCSourceCompiles.html"
  author: "Kitware / CMake project"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "CMake latest docs"
  covers: "Same CMAKE_REQUIRED_FLAGS / CMAKE_REQUIRED_LINK_OPTIONS wording. Says the check 'compiles and links the test source code as an executable program' by default; with CMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY it is 'compiled but not linked'. Does not say whether CMAKE_REQUIRED_FLAGS reaches the link step (fetch relayed no statement)."
  assumes: "CMake basics"
  scores: {directness: 4, currency: 5, depth: 3, activity: 2, cost: 5, accessibility: 3}
  role: reference
  verified: 2026-11-11
  status: ok

- title: "CMAKE_<LANG>_FLAGS (CMake)"
  url: "https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_FLAGS.html"
  author: "Kitware / CMake project"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "CMake latest docs"
  covers: "'Language-wide flags for language <LANG> used when building for all configurations'; CMAKE_C_FLAGS is 'Initialized by the CFLAGS environment variable'; relayed as applying to every compiler invocation (compile and link)."
  assumes: "CMake basics"
  scores: {directness: 5, currency: 5, depth: 2, activity: 2, cost: 5, accessibility: 4}
  role: reference
  verified: 2026-11-11
  status: ok

- title: "CMAKE_EXPORT_COMPILE_COMMANDS (CMake)"
  url: "https://cmake.org/cmake/help/latest/variable/CMAKE_EXPORT_COMPILE_COMMANDS.html"
  author: "Kitware / CMake project"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "CMake >= 3.5; Makefile and Ninja generators only; output compile_commands.json"
  covers: "Writes exact compiler invocation per translation unit; ignored for other generators; poor fit with unity builds."
  assumes: "CMake basics"
  scores: {directness: 5, currency: 5, depth: 2, activity: 3, cost: 5, accessibility: 4}
  role: reference
  verified: 2026-11-11
  status: ok

- title: "cmake-configure-log(7)"
  url: "https://cmake.org/cmake/help/latest/manual/cmake-configure-log.7.html"
  author: "Kitware / CMake project"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "CMake >= 3.26"
  covers: "${CMAKE_BINARY_DIR}/CMakeFiles/CMakeConfigureLog.yaml (location may change; query via cmake-file-api(7)). Records try_compile events with backtrace, variables, combined build output and exit code. Not a full configure log."
  assumes: "CMake basics"
  scores: {directness: 5, currency: 5, depth: 3, activity: 3, cost: 5, accessibility: 3}
  role: core
  verified: 2026-11-11
  status: ok

- title: "WORKING_DIRECTORY (CMake test property)"
  url: "https://cmake.org/cmake/help/latest/prop_test/WORKING_DIRECTORY.html"
  author: "Kitware / CMake project"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "CMake latest docs"
  covers: "Default: the test runs in the binary directory associated with where the test was created."
  assumes: "ctest basics"
  scores: {directness: 5, currency: 5, depth: 1, activity: 2, cost: 5, accessibility: 4}
  role: reference
  verified: 2026-11-11
  status: ok

- title: "add_test (CMake)"
  url: "https://cmake.org/cmake/help/latest/command/add_test.html"
  author: "Kitware / CMake project"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "CMake latest docs"
  covers: "add_test(NAME ... WORKING_DIRECTORY <dir>): 'If not specified, the test will be run in CMAKE_CURRENT_BINARY_DIR.'"
  assumes: "ctest basics"
  scores: {directness: 5, currency: 5, depth: 1, activity: 2, cost: 5, accessibility: 4}
  role: reference
  verified: 2026-11-11
  status: ok

- title: "9.5 Overriding Variables (GNU make manual)"
  url: "https://www.gnu.org/software/make/manual/html_node/Overriding.html"
  author: "Free Software Foundation, GNU make manual"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "GNU make (current manual)"
  covers: "A command-line 'v=x' means 'all ordinary assignments of the same variable in the makefile are ignored'; example make CFLAGS='-g -O'; the makefile can still change an overridden variable with the 'override' directive ('override variable = value'). The override-directive page itself (Override-Directive.html) was not fetched."
  assumes: "make basics"
  scores: {directness: 5, currency: 5, depth: 3, activity: 3, cost: 5, accessibility: 4}
  role: core
  verified: 2026-11-11
  status: ok

- title: "AddressSanitizerAlgorithm (google/sanitizers wiki)"
  url: "https://github.com/google/sanitizers/wiki/AddressSanitizerAlgorithm"
  author: "Google sanitizers project"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "AddressSanitizer, x86-64 and 32-bit mappings as stated on the page"
  covers: "8 app bytes map to 1 shadow byte. Page states: 64-bit 'Shadow = (Mem >> 3) + 0x7fff8000;', 32-bit offset 0x20000000. Heap redzones poisoned around malloc regions; stack redzones around local arrays, poisoned on entry; on free the region's shadow is poisoned and the chunk is held in a quarantine queue so malloc does not reuse it for a while. Page is old; offset may differ on current builds (needs-lab-verification against a running binary)."
  assumes: "pointer arithmetic"
  scores: {directness: 4, currency: 3, depth: 4, activity: 1, cost: 5, accessibility: 3}
  role: core
  verified: 2026-11-11
  status: ok

- title: "AddressSanitizerFlags (google/sanitizers wiki)"
  url: "https://github.com/google/sanitizers/wiki/AddressSanitizerFlags"
  author: "Google sanitizers project"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "AddressSanitizer flags"
  covers: "malloc_fill_byte default 0xbe ('Value used to fill the newly allocated memory'), max_malloc_fill_size default 4096. abort_on_error, detect_leaks and help are not in its table. Page says the list may be incomplete and suggests ASAN_OPTIONS=help=1 ./a.out."
  assumes: "ASan basics"
  scores: {directness: 4, currency: 3, depth: 3, activity: 3, cost: 5, accessibility: 4}
  role: reference
  verified: 2026-11-11
  status: ok

- title: "SanitizerCommonFlags (google/sanitizers wiki)"
  url: "https://github.com/google/sanitizers/wiki/SanitizerCommonFlags"
  author: "Google sanitizers project"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "Flags common to sanitizers"
  covers: "abort_on_error default false (true on Darwin): abort() instead of _exit() after the report. detect_leaks default true. help default false: prints the flag options. malloc_fill_byte is not here (it is on AddressSanitizerFlags)."
  assumes: "ASan basics"
  scores: {directness: 4, currency: 3, depth: 3, activity: 3, cost: 5, accessibility: 4}
  role: reference
  verified: 2026-11-11
  status: ok

- title: "Typo in compiler flags about Sanitizer in CMakeLists.txt? (cJSON issue 728)"
  url: "https://github.com/DaveGamble/cJSON/issues/728"
  author: "sdygt (reporter), DaveGamble/cJSON"
  kind: writeup
  tier: T2
  cost: free
  published: 2023-01-03
  targets: "cJSON CMakeLists.txt ENABLE_SANITIZERS block"
  covers: "Reporter asks if '-01' should be '-O1' in the ENABLE_SANITIZERS block; open, no maintainer reply shown. Not about -fsanitize=address being dropped."
  assumes: "none"
  scores: {directness: 2, currency: 3, depth: 1, activity: 1, cost: 5, accessibility: 4}
  role: reference
  verified: 2026-11-11
  status: ok
```

### cJSON tracker search (GitHub search API via curl and one issue page, 2026-11-11)
- Searched repo DaveGamble/cJSON issues and PRs for "ENABLE_SANITIZERS", "sanitize", "sanitizer". Nothing found that reports `ENABLE_SANITIZERS` silently dropping `-fsanitize=address`, and no fix PR.
- Closest: issue #728 (above, open, a `-01` typo question), PR #850 "Fix optimization flag" (closed), PR #794 "misspelling" (open). Issue #140 and PRs #1033, #92 matched only by the term. #1093 (stack overflow under ASan -O0) and ASan bug reports (#1081, #923, #778) are about cJSON bugs, not the build flags.
- Local read of CMakeLists.txt on master (v1.7.19-6-g6d9f244): the ENABLE_SANITIZERS block appends -fsanitize=address, undefined, float-cast-overflow, -fsanitize-address-use-after-scope, -fsanitize=integer, -fno-sanitize-recover to `custom_compiler_flags`. Added by commit a09defe. Whether gcc rejects some of these (for example `integer`, clang-only) is still the open lab question from FND-03 and is not answered by the tracker.
- Absence of search hits is not proof; the search API matches words, so a differently worded report could exist.

### Line count correction (research/targets/FND.md)
- `git show` on the local cJSON clone: cJSON.c is 3129 lines at 87d8f09 (= v1.7.17), 3110 at v1.7.15, 3119 at v1.7.16, 3143 at v1.7.18, 3206 at master/HEAD (v1.7.19-6-g6d9f244; the 3206-line version first appears at commit b2890c8, 2026-03-12). So 3206 was master, not v1.7.17; the builder's 3129 is correct. Both occurrences in FND.md were corrected.

Claim support:
- check_c_compiler_flag adds the flag at link time: NOT stated by the doc. It states CMAKE_REQUIRED_LINK_OPTIONS goes to the link command and the check links an executable by default. needs-lab-verification (read CMakeConfigureLog.yaml).
- CMAKE_REQUIRED_FLAGS must be a space-separated string, not a list: supported (verbatim).
- CMAKE_C_FLAGS from CFLAGS env: supported. CMAKE_EXPORT_COMPILE_COMMANDS Makefile/Ninja only: supported. Configure log path and 3.26: supported.
- ctest default working directory is the binary dir: supported by both pages.
- make command-line vars override makefile assignments; `override` can change them: supported (read in full).
- ASan shadow = (Mem>>3)+0x7fff8000 on 64-bit: the page says so; current-build value unverified. Redzones and quarantine: supported.
- abort_on_error, detect_leaks, help: supported on SanitizerCommonFlags; malloc_fill_byte on AddressSanitizerFlags.
- cJSON upstream issue for dropped -fsanitize=address: none found.

### FND-02 addendum: OpenSSL EVP_PKEY_decrypt (added 2026-11-11)
Text confirmed two ways: (a) raw pod source `doc/man3/EVP_PKEY_decrypt.pod` on branch openssl-3.5 (raw.githubusercontent.com/openssl/openssl/openssl-3.5/doc/man3/EVP_PKEY_decrypt.pod); (b) the rendered docs.openssl.org page, searched by curl for the quoted sentences (WebFetch could not summarise it: 476k-char page, body beyond the first 100k).

```yaml
- title: "EVP_PKEY_decrypt_init, EVP_PKEY_decrypt_init_ex, EVP_PKEY_decrypt - decrypt using a public key algorithm"
  url: "https://docs.openssl.org/3.5/man3/EVP_PKEY_decrypt/"
  author: "The OpenSSL Project Authors"
  kind: docs
  tier: T1
  cost: free
  published: unknown     # pod copyright line reads 2006-2025
  targets: "OpenSSL 3.5 man page; functions added in 1.0.0; implicit rejection for PKCS#1 v1.5 since 3.2.0"
  covers: "EVP_PKEY_decrypt contract: with out == NULL, *outlen receives the minimum output size; with out != NULL, *outlen must hold the buffer length on entry and gets the decrypted length on success. Returns 1 success, 0 or negative on failure (-2 = unsupported). Example allocates outlen bytes then calls again."
  assumes: "C pointers, size_t out-parameters, RSA padding concepts"
  scores: {directness: 5, currency: 5, depth: 3, activity: 2, cost: 5, accessibility: 3}
  role: reference
  verified: 2026-11-11
  status: ok
```

Claim support:
- `outlen` is in/out (buffer size on input, actual length on output): supported. Pod: "If out is not NULL then before the call the *outlen parameter must contain the length of the out buffer. If the call is successful the decrypted data is written to out and the amount of the decrypted data written to *outlen, otherwise an error is returned."
- Size query: supported. "If out is NULL then the minimum required size of the output buffer is written to the *outlen parameter."
- Return values: supported. "return 1 for success and 0 or a negative value for failure. In particular a return value of -2 indicates the operation is not supported by the public key algorithm."
- `out`/`outlen` defined after failure: NOT stated. The page says only "otherwise an error is returned"; treat contents of both as unspecified, so callers must not use `outlen` after a failed call.
- The page does not state that the returned size when `out == NULL` is exact; it says "minimum required", so the real plaintext can be shorter than the buffer and no NUL terminator is added (the property relevant to the iperf off-by-one; the page says nothing about NUL, it follows from the output being raw bytes).
