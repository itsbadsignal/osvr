# Lab spec: FND-03-building-and-debugging-with-gdb-and-sanitizers

Target: cJSON, repository `https://github.com/DaveGamble/cJSON`, as a build-and-debug target (no exploit, no CVE root-causing).
Version: tag `v1.7.17` = commit `87d8f0961a01bf09bef98ff89bae9fdec42181ee` (`research/targets/FND.md`), verified by `git rev-parse` at build time.
Kind: docker, `FROM osvr-fnd-base:1` (same resolution as FND-01/FND-02). Must work under podman and Docker (Docker untested on the maintainer machine; say so).
Bug: none required at runtime. The module's "finding" is a build-system defect the learner re-derives: cJSON's `-DENABLE_SANITIZERS=ON` drops `-fsanitize=address` with gcc 14 because `CHECK_C_COMPILER_FLAG` links its probe without the flag (derived by the module-builder, see below). The lab must **not** patch or work around it in `/src/cjson`.

## Interface contract (module text depends on these names)
| Item | Name / behaviour |
|---|---|
| Recipe | `curriculum/tracks/FND/modules/FND-03-building-and-debugging-with-gdb-and-sanitizers/lab/Dockerfile`, context = this `lab/` dir, first line `FROM osvr-fnd-base:1` |
| Image tag | `osvr-fnd03:1` |
| cJSON source | `/src/cjson`: a **full** clone (all history and tags; the project's variations use `git show v1.7.18:...`, `git log -S`), HEAD detached at `87d8f096...`, verified with `test "$(git rev-parse HEAD)" = 87d8f0961a01bf09bef98ff89bae9fdec42181ee`. Also verify tags `v1.7.18` and `v1.7.19` resolve. Make the tree read-only for the learner if practical (e.g. `chmod -R a-w` after clone); learners `cp -a` it. `git config --system --add safe.directory '*'` as in FND-01 |
| Newest-commit record | `/src/cjson.newest`: one line, the hash of the newest commit on the default branch at image build time plus its commit date (`git log -1 --format='%H %cs' origin/HEAD` or equivalent). Project Variation 4 uses it |
| Exercise sources | `/opt/osvr/fnd03/src/tripwire.c` exactly: `#include <stdlib.h>` on line 1, `int main(void){char *p=malloc(8); p[8]=1; free(p); return 0;}` on line 2. **Line 2 is load-bearing** (README quotes `tripwire.c:2`). Also `/opt/osvr/fnd03/src/ubtrip.c`: a 3-line signed-overflow program (`INT_MAX + argc`) for the rubric's behavioural UBSan check |
| Mystery binaries | `/opt/osvr/fnd03/mystery/m1` ... `m6` (Drill 2), see below |
| Tools | `/opt/osvr/fnd03/tools/mystery-check FILE` (inside the image, Python 3 stdlib) |
| Shell wrapper | `lab/run.sh`: interactive shell, `--rm -it --network=none`, `-v ~/osvr-work/fnd03:/work/fnd03` (create host dir), host-owned files under both engines as in FND-01 (no `--user` under rootless podman; `--user "$(id -u):$(id -g)"` under Docker). If `ASLR_OFF=1`, add `--security-opt seccomp=unconfined` and print one line saying so. Under Docker also add `--cap-add=SYS_PTRACE` only if testing shows gdb needs it (record). Honours `ENGINE`, `IMAGE` (default `osvr-fnd03:1`) |
| Checker | `lab/check.sh [challenge|project]` (host side; runs the image) |
| Other wrappers | `build.sh`, `reset.sh` as in FND-01/FND-02 |
| Working dir | `/work/fnd03` (WORKDIR) |
| Packages | base image only. Do not add clang, ninja or llvm-symbolizer unless the caller asks (the README tells learners to check `command -v ninja` and not assume it) |

## Expected behaviour (derived by the module-builder, 2026-11-11)
Run in images derived from `osvr-fnd-base:1` (`osvr-fnd01:1`, then `osvr-fnd02:1` with a scratch clone of cJSON at `87d8f096` after `osvr-fnd01:1` was removed during a parallel rebuild), rootless podman, gcc 14.2.0-19, gdb 16.3, cmake 3.31.6. Please re-run each on `osvr-fnd03:1` and record differences in Implementation notes; the README quotes these.

**A. Makefile route (worked example).** `make cJSON_test CFLAGS="-g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined"` builds; command shows the flags and no `-fstack-protector`. `make -B -n cJSON_test` without `CFLAGS` shows `-fstack-protector` (not `-strong`). `nm cJSON_test | grep -c __asan_report` = 8, `__ubsan_handle` = 6; `ldd` lists `libasan.so.8`, `libubsan.so.1`. `./cJSON_test` exits 0. gdb (`ASAN_OPTIONS=detect_leaks=0 gdb -nx`, `break print_number`, `run`): stops at `cJSON.c:552`; `bt` = print_number, print_value :1411, print_object :1784, print_value :1438, print_object :1784, print_value :1438, print :1211, cJSON_Print :1259, print_preallocated test.c:53, create_objects test.c:178, main test.c:265; `p *item` shows `valueint = 1920`, `string = "width"`; after `finish`, `x/s output_buffer->buffer` ends in `"width":\t1920`. Before `finish`, `p *output_buffer` shows `'\276' <repeats 122 times>`.

**B. Documented CMake route.** `cmake -S . -B build-doc -DCMAKE_BUILD_TYPE=Debug -DENABLE_SANITIZERS=ON -DENABLE_CJSON_TEST=ON -DCMAKE_C_FLAGS="-g -O0 -fno-omit-frame-pointer"`: build OK, `ctest` 19/19 pass. `tests/parse_with_opts` and `tests/parse_examples`: 0 `__asan_report`, 11 `__ubsan_handle`, `ldd` shows `libubsan.so.1` only. `CMakeFiles/cjson.dir/cJSON.c.o`: 0 `__asan_report`, 6 `__ubsan`. Cache: `FLAG_SUPPORTED_fsanitizeaddress`, `FLAG_SUPPORTED_01`, `FLAG_SUPPORTED_fsanitizeinteger` empty. `CMakeConfigureLog.yaml` entry for `fsanitizeaddress`: compile line includes `-fsanitize=address`, link line does not; error `undefined reference to '__asan_init'` and `'__asan_version_mismatch_check_v8'`.

**C. Explicit CMake route (reference solution).** `-DCMAKE_C_FLAGS="-g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined -fno-sanitize-recover=undefined" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`: build OK, `ctest` 19/19, `tests/parse_examples` 9 `__asan_report`, `libasan.so.8` + `libubsan.so.1` + `libcjson.so.1` linked; `cJSON.c.o` 8 `__asan_report`; `compile_commands.json` 23 entries.

**D. gdb on `parse_examples`** (from `build-asan/tests`, `ASAN_OPTIONS=detect_leaks=0 gdb -nx`): `break cJSON.c:parse_number`, `run`: first stop at `cJSON.c:306` in frame chain ending `parse_file ("inputs/test3") parse_examples.c:36`, `do_test ("test3") :76`, `file_test3_should_be_parsed_and_printed () :121`, `main () :258`. `p item->string` = `"width"`; `input_buffer->offset` = 143, `length` = 604; after `finish`, `p item->valuedouble` = 500. `info breakpoints` after first stop: 2 locations with `cJSON.c:parse_number` (exe and `libcjson.so.1`), 4 with bare `parse_number` (two more in `sanitizer_common_interceptors_format.inc`). With `ignore 1 100000`: 62 hits (`cJSON.c:parse_number`) vs 74 (bare). Without `detect_leaks=0`: run ends `LeakSanitizer has encountered a fatal error`, `HINT: LeakSanitizer does not work under ptrace (strace, gdb, etc)`, exit code 01. From the build root instead of `build/tests`: exit 1, file tests fail, LSan leak report.

**E. Tripwire.** ASan build: `heap-buffer-overflow`, `WRITE of size 1`, shadow line `fa fa 00[fa]`. Under gdb: plain `run` exits code 01, `bt` = `No stack.`; `ASAN_OPTIONS=abort_on_error=1`: SIGABRT, `#9 main () at tripwire.c:2`; `break __asan_report_store1`: `#1 main () at tripwire.c:2`. Disassembly of `main` contains `shr rdx,0x3; add rdx,0x7fff8000` before the store. Link-only (`gcc -c` without, link with `-fsanitize=address`): `ldd` shows libasan, 0 `__asan_report`, exit 0, no report. `-fsanitize=undefined` only: exit 0, no report. `-static -fsanitize=address`: `gcc: error: cannot specify -static with -fsanitize=address`.

**F. Toolchain defaults** (bare gcc, `gcc -g -O0 t.c`): `--enable-default-pie`; `-fstack-protector*` `[disabled]`; `-fcf-protection=full`; `-fstack-clash-protection [disabled]`; ELF `DYN`, `FLAGS_1 PIE`, `GNU_STACK RW`, `GNU_RELRO` present, no `BIND_NOW`, 0 `__stack_chk_fail`. (This also answers FND-02's open needs-lab-verification on the bare-gcc stack protector: off in this image, unlike the Arch observation.)

**G. -O2 sanitizer build** with project flags on: fails, `parse_examples.c:68:5: error: null destination pointer [-Werror=format-overflow=]`; `-Wno-error` in `CMAKE_C_FLAGS` does not help (project appends `-Werror` later). With `-DENABLE_CUSTOM_COMPILER_FLAGS=OFF`: builds, `ctest` reports 18/18 (one test fewer; please record which and why), `break cJSON.c:parse_number` says `Function "parse_number" not defined in "cJSON.c"`.

## Mystery binaries (Drill 2)
Build all six from one small source with at least one heap access and one signed addition (for example a variant of `tripwire.c` that does not trigger at runtime), so each runs to exit 0. Flag sets:

| Binary | Compile flags | Link flags | Then |
|---|---|---|---|
| m1 | `-g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined` | same | |
| m2 | `-g -O0` | `-fsanitize=address` | (runtime only: the link-only case) |
| m3 | `-g -O0 -fsanitize=undefined` | same | |
| m4 | `-O0 -fsanitize=address` (no `-g`) | same | |
| m5 | `-g -O0` | none | |
| m6 | `-g -O2 -fsanitize=address,undefined` | same | `strip` it |

Answer key fields per binary: `asan_code`, `asan_runtime`, `ubsan`, `debug_info`, `opt`. For m6 `debug_info=no` (stripped) and `opt=O2`. `mystery-check` must store the key hashed or obfuscated enough that `cat` does not give it away, and print per field `match`/`differ`, never the expected value. If the lab-engineer finds any field that cannot be determined from the artefact with the allowed tools (`nm`, `ldd`, `readelf`, `objdump`, `file`, running with `ASAN_OPTIONS=help=1`), tell the caller so Drill 2 can be changed; `opt` for m6 is the riskiest.

## Checker idea
`check.sh [challenge|project]`, host side, runs the image with `--network=none` and the `~/osvr-work/fnd03` mount. `PASS`/`FAIL` per line with a one-line informational reason. It must not explain the defect, name the CMake option, or print expected answers. Exit 0 only if all pass. Target under 60 s (the project mode builds twice; cJSON builds in seconds).

`challenge` (against `/work/fnd03/cjson/build-asan`, override `BUILD=`):
1. `CMakeCache.txt` exists; `ENABLE_CJSON_TEST` on.
2. For **every** executable registered with ctest (`ctest -N` in the build dir) and for `libcjson.so`: `nm` (or `nm -D` for the library) `__asan_report` count > 0 and `__ubsan_handle` count > 0; executables `ldd`-link `libasan` and `libubsan`. Report the first offending binary by name only.
3. `compile_commands.json` exists, or `cmake --build BUILD -v -- -n` shows the commands; every compile command for `cJSON.c` and `tests/*.c` contains `-g` and `-fno-omit-frame-pointer` and an `-O0` (or no `-O` other than `-O0`).
4. UBSan fatal, behaviourally: compile `/opt/osvr/fnd03/src/ubtrip.c` with the C flags from the cache (`CMAKE_C_FLAGS` plus build-type flags) and assert non-zero exit with a `runtime error:` line. Informational FAIL: "UBSan findings would not fail a test".
5. `ctest` in the build dir: all pass.
6. `/work/fnd03/challenge/evidence.txt` exists and is non-empty.
7. `/work/fnd03/challenge/answers.md`: parse the four `key: value` lines (case-insensitive keys, trim whitespace, accept `inputs/test3` or a path ending in it). Compare to hashed expected values; print `match`/`differ` per key only.

`project` (against `/work/fnd03/project/build-asan.sh`, override `SCRIPT=`):
1. Script exists and is executable.
2. Run it twice, each time against a fresh `cp -a /src/cjson` into a temp dir inside the container. Exit 0 both times.
3. After each run, independently re-run steps 2 and 5 of `challenge` on the build directory the script produced (the script must print the path on its last line as `BUILD_DIR=<path>`; state this in the FAIL message if missing).
4. Negative test of the script's verify stage: run the script with an environment override that the script must honour, `OSVR_FORCE_NO_ASAN=1`, meaning "configure with your normal flags minus `-fsanitize=address`"; assert the script exits non-zero. Tell the caller if this contract is awkward; the alternative is the assessor reading the verify stage by hand (rubric already allows that).
5. Never modifies `/src/cjson` (compare `git status --porcelain` and a tree hash before and after).

## Mitigation build matrix
| Variant | Flags / config | Used by |
|---|---|---|
| make-asan | `make cJSON_test CFLAGS="-g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined"` | worked example |
| cmake-doc | `-DCMAKE_BUILD_TYPE=Debug -DENABLE_SANITIZERS=ON -DENABLE_CJSON_TEST=ON -DCMAKE_C_FLAGS="-g -O0 -fno-omit-frame-pointer"` | challenge (trap), project step 1 |
| cmake-asan | `-DCMAKE_BUILD_TYPE=Debug -DENABLE_CJSON_TEST=ON -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_FLAGS="-g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined -fno-sanitize-recover=undefined"` | challenge reference, project |
| cmake-asan-O2 | as cmake-asan with `-O2`, plus `-DENABLE_CUSTOM_COMPILER_FLAGS=OFF` | project variation 2 |
| default hardening | bare `gcc -g -O0` | mitigation table (record F) |

FORTIFY is off in every variant (OpenSSF guide: incompatible with sanitizers). Note for the record: gcc accepts `-O1 -fsanitize=address -D_FORTIFY_SOURCE=2` without error (derived), so nothing in the toolchain enforces this.

## Version facts to check (do not let the module assert them until checked)
- `git show v1.7.18:CMakeLists.txt` and `v1.7.19`: module-builder's scratch clone shows the `ENABLE_SANITIZERS` list without `-01` but otherwise unchanged, and the same check loop; `git log -S'-01'` finds `a20be79 fix: remove misused optimization flag -01` (short hash from the scratch clone; record the full hash). Newest commit in the scratch clone on 2026-11-11: `6d9f2443ab071f86e5d9b43025a40929ec41c46c` (2026-09-16), after `a29814f upgrade version of cmake_minimum_required (#986)`. Please build the newest commit with `ENABLE_SANITIZERS=ON` and record whether ASan is still dropped; the module currently forbids claiming it.
- Makefile lines 29 to 37: `expr "14" ">=" "4.9"` prints `0` (string comparison), so gcc 14 gets `-fstack-protector`. Record `gcc -std=c89 -dumpversion` output in the image.
- `cJSON.c` is 3129 lines at `87d8f096` by `wc -l` in the scratch clone; `research/targets/FND.md` says 3206. Record `wc -l` from the image clone; the module does not quote either number.

## Limits
RAM: 2 GB   Disk: under 150 MB on top of the base image (cJSON full clone plus mystery binaries; measure and record)   Network: build time only (`git clone`). None at runtime (`--network=none`). Do not set a virtual-memory ulimit (ASan).

Ethics (D10): local container, archived open-source code, no services, no listening ports, no network at runtime.

## Implementation notes (lab-engineer appends)
