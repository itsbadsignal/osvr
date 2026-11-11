# Drills: FND-03-building-and-debugging-with-gdb-and-sanitizers

## Rate-determining step
Building an unfamiliar open-source project at a pinned commit with ASan/UBSan and debug symbols.

Every later module starts here: FND-04 reproduces a crash in a codebase you have never seen, VD builds fuzz targets, RE and BX debug real binaries. If the build is wrong, everything downstream lies to you, and it lies quietly. The struggle challenge showed the typical failure: a project's own "sanitizers on" switch produced a build that passed its tests with UBSan and without ASan, and nothing on screen said so. The hard part is not typing `cmake`. It is (a) finding where flags enter an unfamiliar build, (b) reading what the build really did, and (c) refusing to believe a build until the artefacts prove it. Research names this step as the likeliest place for a learner to quit (`research/domain-maps/foundations.md`, Rate-determining steps, researcher inference; treat as a pilot hypothesis).

All drills run inside `"$M/lab/run.sh"`, working in `/work/fnd03/drills/`. `/src/cjson` is the read-only source; copy it before building.

## Drill 1: Three doors in
Type: time-sliced (only the inject-and-verify phase, no debugging)
Goal: get ASan + UBSan + `-g -O0 -fno-omit-frame-pointer` into a target through whatever door its build offers, and prove it, fast.
Setup: one fresh copy of `/src/cjson` per rep. Each rep uses one route, in rotation:
- **A. Make**: `cJSON_test` via the Makefile (the worked example).
- **B. CMake**: the test suite via `CMAKE_C_FLAGS`, with `compile_commands.json`.
- **C. No build system**: one `gcc` command that builds `tests/parse_hex4.c` with the in-tree Unity framework (`tests/unity/src/unity.c`) and runs it. You must work out the include paths and sources from the files themselves (`head -40 tests/parse_hex4.c`, `tests/common.h`).
- **D. CMake with `cJSON_Utils`**: `-DENABLE_CJSON_UTILS=ON`. Which extra test programs appear, and do they get your flags?
For every route, the rep ends with the evidence triple for one test binary: its compile command, `nm | grep -c __asan_report` and `__ubsan_handle` (both > 0), and `ldd | grep -E 'asan|ubsan'`.
Time target: 8 minutes per route from `cp -a` to evidence (build time included; the cJSON builds take seconds).
Success check: evidence triple complete and correct, and the test binary runs clean (`exit 0`) under `ASAN_OPTIONS=detect_leaks=1`.
Make it harder: do route B with Ninja instead of Makefiles if the lab has it (`cmake -G Ninja`; check with `command -v ninja` first), or do any route with your shell history disabled (`set +o history`) so you cannot scroll back to last time's command.

## Drill 2: Is it really sanitized?
Type: cognitive-component
Goal: classify a binary's instrumentation from the artefact alone, in seconds, without trusting anyone's description of how it was built.
Setup: `/opt/osvr/fnd03/mystery/` holds six executables (`m1` to `m6`), all built from the same small program by the lab, each with a different flag set (see `lab/SPEC.md`). For each, write a line in `mystery.txt`:

```text
m1: asan_code=yes|no asan_runtime=yes|no ubsan=yes|no debug_info=yes|no opt=O0|O2 evidence: <the commands and the numbers>
```

Allowed tools: `nm`, `ldd`, `readelf`, `objdump`, `file`, and running the program with `ASAN_OPTIONS=help=1`. You may run the program itself only after you have written your line for it, to check the prediction against its behaviour.
Time target: 90 seconds per binary.
Success check: `/opt/osvr/fnd03/tools/mystery-check mystery.txt` prints `match` for every field of all six. It reports which fields differ, not the right value.
Make it harder: one binary is stripped (`strip`). Which fields can you still answer, and with which tool? For `opt`, explain your evidence: what in the disassembly of `main` gives an `-O2` build away?

## Drill 3: Predict the compile line
Type: cognitive-component
Goal: know, before running anything, which flags a CMake invocation will put on the compile line of `cJSON.c`, in which order, and which ones win.
Setup: for each invocation below, write your prediction of (a) whether `-fsanitize=address` reaches the compile of `cJSON.c` for `libcjson.so`, (b) whether it reaches the link of `tests/parse_examples`, (c) whether `-Werror` is present, (d) the effective `-O` level. Then run it in a new build directory with `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` and check against `compile_commands.json` and `cmake --build <dir> -v`.

```sh
# 1
cmake -S . -B d1 -DENABLE_SANITIZERS=ON
# 2
cmake -S . -B d2 -DCMAKE_C_FLAGS="-fsanitize=address"
# 3
cmake -S . -B d3 -DCMAKE_C_FLAGS="-O2 -fsanitize=address,undefined -Wno-error"
# 4
cmake -S . -B d4 -DENABLE_CUSTOM_COMPILER_FLAGS=OFF -DCMAKE_C_FLAGS="-O2 -fsanitize=address,undefined"
# 5
CFLAGS="-fsanitize=address -g" cmake -S . -B d5
# 6
cmake -S . -B d6 -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS="-g -O0 -fsanitize=address"
```

Time target: 2 minutes per prediction, written before running.
Success check: at least 20 of 24 predictions right; each wrong one gets a one-line explanation from the actual command. Number 3 fails to build in the lab with `-Werror=format-overflow=` (derived); explain why your `-Wno-error` did not save it. Number 5 tests whether CMake reads the `CFLAGS` environment variable on first configure: check it, do not assume it. Number 6: the build type adds its own optimisation flag; which one ends up last?
Make it harder: write a seventh invocation of your own that makes the sanitizer flags reach every object but **not** the `fuzzing/` targets. Explain how you checked.

## Drill 4: Read the configure log
Type: magnifying-glass
Goal: spend 10x normal time on the one artefact that explains silent build failures, until you can find and read a failed feature check in any CMake project.
Setup: one 60-minute session on the `ENABLE_SANITIZERS=ON` build from the challenge (`build-doc`). For each of the three failed checks (`FLAG_SUPPORTED_fsanitizeaddress`, `FLAG_SUPPORTED_01`, `FLAG_SUPPORTED_fsanitizeinteger`):
1. Find its entry in `CMakeFiles/CMakeConfigureLog.yaml`.
2. Copy the exact compile command and link command CMake ran, and the compiler's error.
3. Reproduce the failure by hand with a two-line `src.c` and the same commands, outside CMake.
4. State in one sentence whether the check's verdict was **correct** (the flag really is unusable with this gcc) or **wrong** (the flag works but the check could not tell).
5. Write the smallest change to `CMakeLists.txt` that would make the check for `-fsanitize=address` give the right answer, apply it to a scratch copy, and prove with `nm` that ASan now reaches the tests.
Time target: 60 minutes. Depth, not speed.
Success check: three filled entries, two verdicts "correct" and one "wrong" with the reason from the log, and a patched scratch build whose `tests/parse_examples` has `__asan_report` symbols. Bring it to `/coach` for one informational-feedback pass on your patch.
Make it harder: the Makefile's stack-protector choice (`Makefile` lines 29 to 37) is also a "feature check". On this gcc it picks `-fstack-protector`, not `-strong`. Find why from line 32 alone, prove it with one `expr` command, and say which gcc versions get which flag.

## Drill 5: Clean-room rebuild
Type: copycat
Goal: proceduralise the whole loop (pin, recon, inject, verify, test, debug) until it runs from memory.
Setup: rep 1 with the walkthrough open. Reps 2 and 3 on later days, closed-book: `rm -rf /work/fnd03/clean && cp -a /src/cjson /work/fnd03/clean`, then build the CMake test suite with ASan + fatal UBSan, produce the evidence triple for `tests/print_number`, run `ctest`, and in gdb stop at the first `print_number` call inside `tests/print_number`, then `finish` and print what was written to the output buffer.
Time target: 15 minutes for reps 2 and 3.
Success check: rep 3 under 15 minutes with every step's evidence pasted in your session log, and no step looked up.
Make it harder: rep 4 on a project you have not built, at a commit you pin yourself: the iperf3 tree from FND-02 (autotools: `./configure`, not CMake). See the overlearning stretch in `project.md`.

## Drill 6: gdb question sprint
Type: time-sliced (only the debug phase)
Goal: turn a question about runtime state into breakpoints and prints, quickly, with transcript evidence.
Setup: your `build-asan` from the challenge. Start every question with `cd build-asan/tests && ASAN_OPTIONS=detect_leaks=0 gdb -nx ./<test>`. Answer each with a pasted transcript:
1. `print_string`: the first time `print_string_ptr` runs, what is the input string, and how many bytes does the output buffer hold at that moment?
2. `parse_hex4`: how many times is `parse_hex4` (in `cJSON.c`) called in a full run? Use an ignore count. Scope the breakpoint.
3. `parse_array`: at the first `parse_array` call, what are `input_buffer->offset` and the next 8 input bytes?
4. `misc_tests`: set a breakpoint on `cJSON_Delete`, run, and at the first stop print the `type` of the node being deleted and its `string`.
5. `parse_examples`: put a watchpoint on the `valuedouble` field of the node from the challenge (`watch -l item->valuedouble` after stopping in `parse_number`) and continue. Which line writes it?
Time target: 3 minutes per question.
Success check: 5/5 answered with transcripts, each under the time. A wrong frame or an unscoped breakpoint that caught a sanitizer-runtime function counts as a miss.
Make it harder: answer 2 and 3 in one non-interactive command each (`gdb -nx -batch -ex ... -ex ...`), so the answer is reproducible by anyone with one paste.

## Owned when
3 consecutive clean reps under the time target, on fresh inputs, for Drills 1, 2 and 6; Drill 5 rep 3 under 15 minutes; one completed Drill 4 write-up; Drill 3 at 20 of 24 or better.
