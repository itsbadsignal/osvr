# Project: FND-03-building-and-debugging-with-gdb-and-sanitizers

## Target
Real artefact: **cJSON**, repository `https://github.com/DaveGamble/cJSON` (`research/targets/FND.md`), as a build-and-debug target.
Version: tag `v1.7.17` = commit `87d8f0961a01bf09bef98ff89bae9fdec42181ee`, in the lab at `/src/cjson` (full clone, so later tags such as `v1.7.18` and `v1.7.19`, and the newest commit at image build time recorded in `/src/cjson.newest`, can be inspected and built offline).
Fix: not applicable. This project is not about the CVE-2023-53154 parser bug, and you should not read its fix or issue 800's discussion. The defect you root-cause here is in cJSON's **build system**: the documented `-DENABLE_SANITIZERS=On` option produces, with the lab's gcc, a build without AddressSanitizer (derived by the module-builder and measured again by the lab-engineer in `osvr-fnd03:1`, 2026-11-11; you re-derive it).
Lab: `lab/` (see `lab/SPEC.md`). Image `osvr-fnd03:1`. Work in `~/osvr-work/fnd03/project/` (mounted at `/work/fnd03/project`).
Mitigations on: none are bypassed. Your builds carry ASan + UBSan (detection only), plus whatever the project and the lab's gcc add by default (PIE, NX, partial RELRO, `-fcf-protection=full`; cJSON's CMake build adds `-fstack-protector-strong`). FORTIFY is off (incompatible with sanitizers, OpenSSF guide).

D1 note: the artefact is a real open-source codebase at a pinned commit (CLAUDE.md D1). The finding is a real defect in that codebase, found and root-caused by you, but it is a build defect, not a vulnerability. That is the right first finding: it costs a researcher real bugs in real work, it is fully checkable, and the reporting skills transfer.

## Goal
Done when:
1. `build-asan.sh [SRC] [WORKDIR]` copies `SRC` (default `/src/cjson`) into `WORKDIR`, produces a CMake build of cJSON's test suite there with ASan, fatal UBSan, `-g`, `-O0` and frame pointers in every object, prints the evidence for it, runs the tests, exits non-zero if any evidence is missing or any test fails, and prints `BUILD_DIR=<path>` as its **last** output line. The build tree lives under `WORKDIR` and is kept even when verification fails. `"$M/lab/check.sh" project` exits 0. It runs your script twice from `/src/cjson`, re-verifies each build itself (instrumentation, runtimes, tests, and that UBSan findings are fatal with the flags the build actually used), then runs it on a **mutated** copy of the source whose build silently loses ASan instrumentation while still linking `libasan`. On the mutant your script must **build, then reject**: the checker looks for the built test programs under `WORKDIR` and requires a non-zero exit. It also checks that `/src/cjson` is unchanged. `PASS  verify stage: script built the mutant (parse_examples: libasan linked, 0 __asan_report) and then rejected it (exit N)`
2. `rootcause.md` explains to the line why `-DENABLE_SANITIZERS=On` yields no ASan with this gcc, and which other two requested flags are dropped and why.
3. `debug-log.md` answers three runtime questions about cJSON with gdb transcripts as evidence.
4. `bug-report.md` is a maintainer-grade report of the build defect, ready to file after a duplicate search.

## Constraints
- Do not edit anything under `/src/cjson`. `build-asan.sh` builds from a copy of `SRC` and never patches it. Variation 1 patches a separate scratch copy, by hand.
- `build-asan.sh` must work on any cJSON tree passed as `SRC`, including a modified one. It may record the commit and `git status --short` of `SRC`, but it must not refuse to build a modified tree: the verify stage, not the pin stage, is what has to catch a bad build.
- `build-asan.sh` must not depend on `ENABLE_SANITIZERS` for ASan. It may turn the option on, but your own flags must be what guarantees the result.
- No network at runtime. Any claim about later cJSON versions must come from `git show <tag>:...` in the lab clone, with the command quoted.
- Every number in `rootcause.md` (line numbers, cache values, symbol counts) must come from a command you ran, quoted next to it.

## Steps
1. **Re-derive the defect.** Build with `-DENABLE_SANITIZERS=ON` in a fresh directory. Collect: `ctest` summary, `nm`/`ldd` on `tests/parse_examples`, the `FLAG_SUPPORTED_*` lines from `CMakeCache.txt`, and the configure-log entries for each failed check.
2. **Read the mechanism.** `CMakeLists.txt` lines 64 to 76 (the option and its flag list) and 98 to 106 (the check loop). Write down what `CHECK_C_COMPILER_FLAG` compiled, what it linked, and with which flags (from the log, not from memory).
3. **Check the other versions.** Read `git show v1.7.18:CMakeLists.txt`, `git show v1.7.19:CMakeLists.txt` and the newest commit (`/src/cjson.newest`). Which of the three dropped flags changed? Then **build** each of the three with `-DENABLE_SANITIZERS=ON` in a copy, offline, and record the `ctest` summary, the `nm`/`ldd` result for `tests/parse_examples` and the `FLAG_SUPPORTED_*` lines. Your `bug-report.md` may state affected versions only from these builds, as "as of commit X". Find when `-01` was added and removed: from the pinned, detached checkout this needs `git log --all -S'-01' -- CMakeLists.txt`.
4. **Write `build-asan.sh`.** Copy `SRC` into `WORKDIR`, configure with explicit flags in a new build directory, build, evidence, tests, non-zero exit on any missing evidence or failing test, build tree kept under `WORKDIR` on failure, `BUILD_DIR=<path>` last. Then `"$M/lab/check.sh" project`.
5. **Debug.** Answer the three questions in `debug-log.md` (below).
6. **Write** `rootcause.md`, `feynman.md`, `bug-report.md`.

## Deliverables
All in `~/osvr-work/fnd03/project/`. Submit with `/submit FND-03-building-and-debugging-with-gdb-and-sanitizers`.

1. `build-asan.sh` (stands in for the exploit: the thing that must work every time):
   - Usage `build-asan.sh [SRC] [WORKDIR]`: `SRC` defaults to `/src/cjson`, `WORKDIR` to a fresh temporary directory. Copies `SRC` into `WORKDIR` and builds **under `WORKDIR`** (not in a directory of its own choosing, such as a separate `mktemp -d`); never builds inside `SRC`.
   - Keeps the build tree when verification fails. Do not `rm -rf` the work directory on failure: the checker inspects it to confirm that a rejected build was built first and then rejected by your verify stage.
   - Configures with `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` and your sanitizer flags; builds.
   - Prints, for **every** test executable registered with `ctest` and for `libcjson.so`: the `__asan_report` and `__ubsan_handle` counts (`nm -D` works on both, stripped or not) and whether `libasan`/`libubsan` are linked. Fails if any count is 0 or a runtime is missing. A build with `libasan` linked and 0 `__asan_report` symbols must fail: that is exactly the mutated source `check.sh project` feeds you.
   - Runs the tests (`ctest`) and fails if any fails.
   - Prints `BUILD_DIR=<absolute path of the build directory>` as its last line, also when it is about to fail, then exits 0 only if verify and test both passed.
   - On the checker's mutated source (objects compiled with `-fno-sanitize=address`, link still pulling in `libasan`) it must build and then exit non-zero from the verify stage. If your build route keeps real ASan instrumentation even on the mutant (for example through a compiler wrapper that re-adds the flag), and your verify stage therefore accepts it, the checker does not fail you for that: it checks the mutant's actual `__asan_report` count first.
   - Commented by stage: `pin`, `configure`, `build`, `verify`, `test`.
   - Starting point if shell scripting is new to you (fill in the blanks; `ctest -N` lists the registered tests as `Test  #1: cJSON_test` lines ending in `Total Tests: 19`, and `ctest --show-only=json-v1` gives the same as JSON with each test's `command`, both measured in the lab):

     ```sh
     #!/bin/bash
     # sketch: build-asan.sh [SRC] [WORKDIR]
     set -u
     SRC=${1:-/src/cjson}
     WORK=${2:-$(mktemp -d)}
     # pin: copy the tree, record what you built
     cp -a "$SRC" "$WORK/cjson"
     chmod -R u+w "$WORK/cjson"   # cp -a keeps /src/cjson's read-only modes
     git -C "$WORK/cjson" rev-parse HEAD 2>/dev/null; git -C "$WORK/cjson" status --short 2>/dev/null
     BUILD="$WORK/cjson/build-asan"
     # configure: your flags (and -DCMAKE_EXPORT_COMPILE_COMMANDS=ON)
     # build
     # verify: for every registered test executable and libcjson.so,
     #         count __asan_report and __ubsan_handle with nm -D, check ldd; set ok=0 on any miss
     # test: run the tests, set ok=0 on any failure
     echo "BUILD_DIR=$BUILD"
     # exit 0 only if every stage passed
     ```
2. `rootcause.md` (the "bug" is the build defect):
   - Location: file and lines in `CMakeLists.txt` at `87d8f096`; the README line that documents the option.
   - Mechanism: what the check compiled and linked, the exact linker error, why CMake therefore concluded "unsupported", and what was silently dropped as a result. Quote the configure-log lines.
   - The broken assumption, in one sentence: what the authors assumed a compile-flag check tells you, and why that does not hold for a flag that also needs a runtime at link time.
   - Impact on users: what someone who follows the README gets, and what they would wrongly conclude from "100% tests passed".
   - The two other dropped flags (`-01`, `-fsanitize=integer`): why each failed, and whether that check's verdict was correct.
   - What changed in later tags and whether each is affected (step 3), with commands and build results.
3. `debug-log.md`: three answers with transcripts (`gdb -nx`, `ASAN_OPTIONS=detect_leaks=0`):
   - **Q1.** In `tests/print_value`, the first time `print_value` is entered: what is the node's `type` (number and the name of the macro in `cJSON.h` it matches), and which test function is on the stack?
   - **Q2.** In `tests/parse_examples`, how many times is `cJSON.c`'s `parse_object` called during a full run? Give the breakpoint you used, show that it is scoped to cJSON's code, and say how you made sure the count is not inflated by a sanitizer-runtime function of the same name.
   - **Q3.** Build the tripwire (`/opt/osvr/fnd03/src/tripwire.c`) with your flags. Stop gdb **before** ASan prints its report. Show the faulting line, the address written, its shadow address computed by hand from the formula in the README Theory, and the shadow byte read with `x/1xb` at that address. Explain the value. The rows of the report's shadow map are labelled with application addresses, not shadow addresses, so the shadow address has to come from your own arithmetic (`p/x (addr >> 3) + 0x7fff8000`).
4. `feynman.md`: under 400 words (see below).
5. `bug-report.md`: a report to the cJSON maintainers, with these headings: Summary, Affected versions (only what you checked, with commands), Environment (image digest, gcc, cmake), Steps to reproduce (paste-able), Expected vs actual (with `nm`/`ldd` output), Root cause, Suggested fix, Workaround for users today. Before the Summary, a line saying how you searched the upstream tracker for duplicates and what you found. You cannot search from the lab (no network): do it on the host before filing anything. It must cite cJSON issue 728 (`resources.yaml`), the existing open report of the `-01` typo, and say that it does not cover the dropped `-fsanitize=address`. Filing is optional and is your decision; if you file, record the link in your session log.

> Novelty status (`research/domain-maps/foundations.md`, cJSON tracker searches of 2026-11-11): a word search of cJSON's issues and pull requests found no report of `ENABLE_SANITIZERS` silently dropping `-fsanitize=address` and no fix. The closest item is issue 728 (open since 2023-01-03), which asks only about the `-01` typo. Word search can miss a differently worded report, so repeat the search yourself before filing. The rubric does not reward filing; it rewards a report that would survive triage.

## Feynman task
In `feynman.md`, under 400 words, explain to a smart non-specialist (a friend who runs a small web shop and has never compiled anything):
- what a sanitizer build is, and why a researcher builds a program that way before looking for bugs;
- what went wrong with cJSON's "turn sanitizers on" switch, without the words CMake, flag, link or runtime unless you explain them in the same sentence;
- why "all tests passed" was not evidence that the safety checks were present;
- the three kinds of evidence you now collect, and what each would catch.

## Variations (experimentation)
Each variation changes one thing. Predict in writing first, then run, then record predicted vs observed in `variations.md`.
- [ ] **Patch the check (different fix).** Make `-DENABLE_SANITIZERS=On` produce a real ASan build on gcc by changing only the flag-check logic in a scratch copy of `CMakeLists.txt`. Prove it with the same `nm`/`ldd` evidence your verify stage uses, on a build that uses the option and no sanitizer flags of your own. Compare your patch with the smallest alternative you can think of, and say which you would send upstream and why.
- [ ] **Change the optimisation level.** Rebuild at `-O2` with sanitizers. With the project's own warning flags it fails under `-Werror` in the lab (measured). Get it to build without editing source files, run the tests, then try to repeat the challenge's `parse_number` stop and Q1 of `debug-log.md`. Record exactly what gdb can no longer tell you (`<optimized out>`, missing breakpoint locations, moved lines) and why.
  <details><summary>Lab-measured result (open after recording your prediction)</summary>

  Built with `-DENABLE_CUSTOM_COMPILER_FLAGS=OFF` and `-g -O2 -fno-omit-frame-pointer` plus the sanitizers: 19/19 tests pass. `break cJSON.c:parse_number` gives `Function "parse_number" not defined in "cJSON.c".` `break cJSON.c:306` gives `No compiled code for line 306`. `break cJSON.c:308` works: the stop shows `parse_number` as an inline frame, with `#1 parse_value ... :1355` and `#2 parse_object (item=<optimized out>...) :1683`, and `item=<optimized out>` in frame 0. `break cJSON.c:322` slides to line 323. So an inlined function can be reached by `FILE:LINE`, not by name.
  </details>
- [ ] **Strip the binary.** `strip` a copy of `tests/parse_examples`. Which evidence from the triple still works? Then keep the debug info in a separate file and get file:line back in gdb. Predict first where gdb will look for that file.
  <details><summary>Lab-measured result (open after recording your prediction)</summary>

  Stripped, with no debug file: `nm` says `no symbols`; `nm -D` still counts 9 `__asan_report` and 10 `__ubsan_handle`; `ldd` shows both runtimes; gdb says `No symbol table is loaded`. Working sequence: `objcopy --only-keep-debug pe pe.debug; strip pe; objcopy --add-gnu-debuglink=pe.debug pe`. gdb then gives file:line from any working directory, provided `pe.debug` sits next to the binary. It also looks in `<bindir>/.debug/` and in the debug-file directory (`/usr/lib/debug`, see `show debug-file-directory`). It does **not** find the file in the current directory when the binary is elsewhere.
  </details>
- [ ] **Archaeology.** How long was `-DENABLE_SANITIZERS=On` broken on gcc? From the full clone (`git log --all`), find the commit that introduced the option and its flag list, and the commit that removed `-01`. Then argue from the configure log, not from memory, whether the option *ever* gave ASan with gcc and the CMake versions of that time. Mark every step you could not verify offline as unverified. needs-lab-verification: the lab confirmed only the add and remove commits of `-01`, not the option's behaviour on old CMake or gcc versions.

## Overlearning stretch
**Unfamiliar build system, your own pin.** Build iperf3 at the FND-02 commit `4eab661da0bbaac04493fa40164e928c6df7934a` (autotools: `./bootstrap.sh` or `./configure`, whichever the tree provides; find out from its files) with ASan + fatal UBSan + `-g -O0`, prove instrumentation with the evidence triple for the `iperf3` binary **and** for `libiperf`, and run its own `make check`. Then answer one runtime question of your choice with gdb, with a transcript. FND-02's optional lab variant (`osvr-fnd02-iperf:1`, see `../FND-02-c-pointers-and-memory/lab/SPEC.md`) is a starting point; check its Implementation notes for what was verified. needs-lab-verification throughout: research marks the iperf build "unverified", and autotools passes flags through `CFLAGS`/`LDFLAGS` differently from CMake. Do not run iperf3 against anything but loopback inside the container.

Submit with `/submit FND-03-building-and-debugging-with-gdb-and-sanitizers`.
