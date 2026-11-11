# Project: FND-03-building-and-debugging-with-gdb-and-sanitizers

## Target
Real artefact: **cJSON**, repository `https://github.com/DaveGamble/cJSON` (`research/targets/FND.md`), as a build-and-debug target.
Version: tag `v1.7.17` = commit `87d8f0961a01bf09bef98ff89bae9fdec42181ee`, in the lab at `/src/cjson` (full clone, so later tags such as `v1.7.18` and `v1.7.19` can be inspected offline with `git show <tag>:<file>`).
Fix: not applicable. This project is not about the CVE-2023-53154 parser bug, and you should not read its fix or issue 800's discussion. The defect you root-cause here is in cJSON's **build system**: the documented `-DENABLE_SANITIZERS=On` option produces, with the lab's gcc, a build without AddressSanitizer (derived by the module-builder in the lab, 2026-11-11; you re-derive it).
Lab: `lab/` (see `lab/SPEC.md`). Image `osvr-fnd03:1`. Work in `~/osvr-work/fnd03/project/` (mounted at `/work/fnd03/project`).
Mitigations on: none are bypassed. Your builds carry ASan + UBSan (detection only), plus whatever the project and the lab's gcc add by default (PIE, NX, partial RELRO, `-fcf-protection=full`; cJSON's CMake build adds `-fstack-protector-strong`). FORTIFY is off (incompatible with sanitizers, OpenSSF guide).

D1 note: the artefact is a real open-source codebase at a pinned commit (CLAUDE.md D1). The finding is a real defect in that codebase, found and root-caused by you, but it is a build defect, not a vulnerability. That is the right first finding: it costs a researcher real bugs in real work, it is fully checkable, and the reporting skills transfer.

## Goal
Done when:
1. `build-asan.sh`, run from a clean copy of `/src/cjson`, produces a CMake build of cJSON's test suite with ASan, fatal UBSan, `-g`, `-O0` and frame pointers in every object, prints the evidence for it, runs `ctest`, and exits non-zero if any evidence is missing. `"$M/lab/check.sh" project` runs it twice from scratch and exits 0.
2. `rootcause.md` explains to the line why `-DENABLE_SANITIZERS=On` yields no ASan with this gcc, and which other two requested flags are dropped and why.
3. `debug-log.md` answers three runtime questions about cJSON with gdb transcripts as evidence.
4. `bug-report.md` is a maintainer-grade report of the build defect, ready to file after a duplicate search.

## Constraints
- Do not edit anything under `/src/cjson`. `build-asan.sh` copies the tree and may patch only its copy, and only in Variation 1.
- `build-asan.sh` must not depend on `ENABLE_SANITIZERS` for ASan. It may turn the option on, but your own flags must be what guarantees the result.
- No network at runtime. Any claim about later cJSON versions must come from `git show <tag>:...` in the lab clone, with the command quoted.
- Every number in `rootcause.md` (line numbers, cache values, symbol counts) must come from a command you ran, quoted next to it.

## Steps
1. **Re-derive the defect.** Build with `-DENABLE_SANITIZERS=ON` in a fresh directory. Collect: `ctest` summary, `nm`/`ldd` on `tests/parse_examples`, the `FLAG_SUPPORTED_*` lines from `CMakeCache.txt`, and the configure-log entries for each failed check.
2. **Read the mechanism.** `CMakeLists.txt` lines 64 to 76 (the option and its flag list) and 98 to 106 (the check loop). Write down what `CHECK_C_COMPILER_FLAG` compiled, what it linked, and with which flags (from the log, not from memory).
3. **Check the other versions.** `git show v1.7.18:CMakeLists.txt`, `git show v1.7.19:CMakeLists.txt` and the newest commit in the clone. Which of the three dropped flags were changed? Find the commit that removed `-01` (`git log -S'-01' -- CMakeLists.txt`). Do **not** claim that the newest version still has the defect unless you have built it (Variation 4).
4. **Write `build-asan.sh`.** Clean copy, configure with explicit flags in a new build directory, build, evidence, `ctest`, non-zero exit on any missing evidence. Then `"$M/lab/check.sh" project`.
5. **Debug.** Answer the three questions in `debug-log.md` (below).
6. **Write** `rootcause.md`, `feynman.md`, `bug-report.md`.

## Deliverables
All in `~/osvr-work/fnd03/project/`. Submit with `/submit FND-03-building-and-debugging-with-gdb-and-sanitizers`.

1. `build-asan.sh` (stands in for the exploit: the thing that must work every time):
   - Takes the source path (default `/src/cjson`) and a work directory; never builds inside the source.
   - Configures with `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` and your sanitizer flags; builds.
   - Prints, for **every** test executable registered with `ctest` and for `libcjson.so`: the `__asan_report` and `__ubsan_handle` counts and whether `libasan`/`libubsan` are linked. Exits 1 if any count is 0 or a runtime is missing.
   - Runs `ctest` and exits with its status.
   - Commented by stage: `pin`, `configure`, `build`, `verify`, `test`.
2. `rootcause.md` (the "bug" is the build defect):
   - Location: file and lines in `CMakeLists.txt` at `87d8f096`; the README line that documents the option.
   - Mechanism: what the check compiled and linked, the exact linker error, why CMake therefore concluded "unsupported", and what was silently dropped as a result. Quote the configure-log lines.
   - The broken assumption, in one sentence: what the authors assumed a compile-flag check tells you, and why that does not hold for a flag that also needs a runtime at link time.
   - Impact on users: what someone who follows the README gets, and what they would wrongly conclude from "100% tests passed".
   - The two other dropped flags (`-01`, `-fsanitize=integer`): why each failed, and whether that check's verdict was correct.
   - What changed in later tags (step 3), with commands.
3. `debug-log.md`: three answers with transcripts (`gdb -nx`, `ASAN_OPTIONS=detect_leaks=0`):
   - **Q1.** In `tests/print_value`, the first time `print_value` is entered: what is the node's `type` (number and the name of the macro in `cJSON.h` it matches), and which test function is on the stack?
   - **Q2.** In `tests/parse_examples`, how many times is `cJSON.c`'s `parse_object` called during a full run? Give the breakpoint you used, show that it is scoped to cJSON's code, and say how you made sure the count is not inflated by a sanitizer-runtime function of the same name.
   - **Q3.** Build the tripwire (`/opt/osvr/fnd03/src/tripwire.c`) with your flags. Stop gdb **before** ASan prints its report. Show the faulting line, the address written, its shadow address computed by hand from the formula in the README Theory, and the shadow byte read with `x/1xb` at that address. Explain the value.
4. `feynman.md`: under 400 words (see below).
5. `bug-report.md`: a report to the cJSON maintainers, with these headings: Summary, Affected versions (only what you checked, with commands), Environment (image digest, gcc, cmake), Steps to reproduce (paste-able), Expected vs actual (with `nm`/`ldd` output), Root cause, Suggested fix, Workaround for users today. Before the Summary, a line saying whether you searched the upstream tracker for duplicates and what you found. In the lab you cannot (no network); write `Duplicate search: not done (offline lab)` and do it on the host before filing anything. Filing is optional and is your decision; if you file, record the link in your session log.

> TODO(research): whether the cJSON tracker already has an issue or fix for `ENABLE_SANITIZERS` dropping `-fsanitize=address` on gcc. Not searched. The rubric does not reward filing; it rewards a report that would survive triage.

## Feynman task
In `feynman.md`, under 400 words, explain to a smart non-specialist (a friend who runs a small web shop and has never compiled anything):
- what a sanitizer build is, and why a researcher builds a program that way before looking for bugs;
- what went wrong with cJSON's "turn sanitizers on" switch, without the words CMake, flag, link or runtime unless you explain them in the same sentence;
- why "all tests passed" was not evidence that the safety checks were present;
- the three kinds of evidence you now collect, and what each would catch.

## Variations (experimentation)
Each variation changes one thing. Predict in writing first, then run, then record predicted vs observed in `variations.md`.
- [ ] **Patch the check (different fix).** Make `-DENABLE_SANITIZERS=On` produce a real ASan build on gcc by changing only the flag-check logic in a scratch copy of `CMakeLists.txt`. Prove it with `build-asan.sh`'s verify stage (pointed at a build that uses the option and no explicit sanitizer flags). Compare your patch with the smallest alternative you can think of, and say which you would send upstream and why.
- [ ] **Change the optimisation level.** Rebuild at `-O2` with sanitizers. It fails under the project's `-Werror` in the lab (derived). Get it to build without editing source files, run `ctest`, then repeat Q1 of `debug-log.md`. Record exactly what gdb can no longer tell you (`<optimized out>`, missing breakpoint locations, reordered lines) and why. needs-lab-verification: whether gdb can still break on inlined `parse_number` at `-O2` by `FILE:LINE` instead of by name.
- [ ] **Strip the binary.** `strip` a copy of `tests/parse_examples`. Which evidence from the triple still works? Then keep the debug info separately (`objcopy --only-keep-debug`, then `--add-gnu-debuglink` on the stripped copy) and show that gdb gets file:line back. needs-lab-verification: the exact `objcopy` sequence and whether gdb 16.3 in the lab finds the debug file from the working directory.
- [ ] **Build the newest version.** The clone in `/src/cjson` holds the full history up to the day the image was built (the commit is recorded in `/src/cjson.newest`, see `lab/SPEC.md`). In a copy, check out that commit and repeat step 1, offline. Note that `cmake_minimum_required` was raised after v1.7.19 (`git log --oneline v1.7.19.. -- CMakeLists.txt`), which can change CMake's behaviour. Does `ENABLE_SANITIZERS` still drop ASan there? Only after this may `bug-report.md` say the newest version is affected, and only "as of commit X".

## Overlearning stretch
**Unfamiliar build system, your own pin.** Build iperf3 at the FND-02 commit `4eab661da0bbaac04493fa40164e928c6df7934a` (autotools: `./bootstrap.sh` or `./configure`, whichever the tree provides; find out from its files) with ASan + fatal UBSan + `-g -O0`, prove instrumentation with the evidence triple for the `iperf3` binary **and** for `libiperf`, and run its own `make check`. Then answer one runtime question of your choice with gdb, with a transcript. FND-02's optional lab variant (`osvr-fnd02-iperf:1`, see `../FND-02-c-pointers-and-memory/lab/SPEC.md`) is a starting point; check its Implementation notes for what was verified. needs-lab-verification throughout: research marks the iperf build "unverified", and autotools passes flags through `CFLAGS`/`LDFLAGS` differently from CMake. Do not run iperf3 against anything but loopback inside the container.

Submit with `/submit FND-03-building-and-debugging-with-gdb-and-sanitizers`.
