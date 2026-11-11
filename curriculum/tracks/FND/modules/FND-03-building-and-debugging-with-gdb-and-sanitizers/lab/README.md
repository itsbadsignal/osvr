# FND-03 lab: building cJSON with CMake, ASan/UBSan, and debugging with gdb

lab_status: verified on rootless podman 6.1.4 (Arch host, kernel 7.2.11), 2026-11-11. Docker: UNTESTED (not installed on the maintainer's machine; Docker code paths exist in run.sh, check.sh and build.sh).

Needs: 2 GB RAM. Disk: `osvr-fnd03:1` adds about 5 MB over the base (cJSON full clone plus six small binaries). Network only to build (git clone).

## Commands (from this directory; ENGINE defaults to podman, else docker)
```sh
./build.sh                 # builds osvr-fnd-base:1 only if missing, then osvr-fnd03:1; log in ~/osvr-work/fnd03/build-logs/
NO_CACHE=1 ./build.sh      # module image with --no-cache (an uncached log has 0 "Using cache" lines; verified)
./run.sh                   # interactive shell, --network=none --cap-drop=ALL, ~/osvr-work/fnd03 at /work/fnd03
ASLR_OFF=1 ./run.sh        # adds seccomp=unconfined so gdb can disable ASLR (prints one line saying so)
./check.sh challenge       # grades ~/osvr-work/fnd03/cjson/build-asan and ~/osvr-work/fnd03/challenge
./check.sh project         # runs ~/osvr-work/fnd03/project/build-asan.sh, see below
./check.sh --health        # lab self-test with fixtures in temp dirs inside a container; about 2 minutes (measured 97 s and 113 s wall on the maintainer machine with 11 fixtures; 52 s before the round-1 fixtures were added)
./reset.sh                 # removes only osvr-fnd03:1; your work dir and the base image are untouched
```
`check.sh` mounts your work dir READ-ONLY. It never deletes, regenerates or modifies your files (verified by checksum). It runs the registered test executables directly instead of `ctest` (ctest writes `Testing/` into the build dir). Ambient `CFLAGS` is ignored everywhere; nothing in this lab reads `LAB_CFLAGS`.

## Project script contract (what `check.sh project` runs)
`bash build-asan.sh [SRC] [WORKDIR]`: SRC defaults to `/src/cjson`, WORKDIR to a fresh temp dir. The script copies SRC into WORKDIR, builds there, and its LAST output line must be `BUILD_DIR=<path>`. It must build under WORKDIR and keep the build tree there when verification fails (the mutant run inspects `parse_examples` under WORKDIR). The checker then:
1. runs it twice from `/src/cjson` into fresh work dirs (exit 0 each time), and re-verifies each BUILD_DIR itself (every ctest executable and libcjson: `nm -D` ASan and UBSan symbols, libasan/libubsan linked; all tests exit 0);
2. runs it a third time with a mutated copy of the sources as SRC: the mutant's `CMakeLists.txt` gets `add_compile_options(-fno-sanitize=address)` before `include(GNUInstallDirs)`, so objects lose ASan instrumentation while the link line still pulls in libasan. The script must exit non-zero AND leave its build under WORKDIR: the checker then confirms `parse_examples` there has libasan linked and 0 `__asan_report`, so a refusal before the build does not count. If the script exits 0 but its build under WORKDIR does have `__asan_report` symbols (e.g. it patched the mutation out of its own copy), that is accepted as legitimate. Every BUILD_DIR also gets the UBSan-fatal check, with flags taken from `compile_commands.json`. No special environment variable is involved, so the script has nothing test-only in it;
3. checks `/src/cjson` is byte-identical afterwards (tree hash and `git status --porcelain`).

## Challenge answers
`answers.md` is compared with values the checker derives live: it runs `gdb -batch` on YOUR `tests/parse_examples` (break `cJSON.c:parse_number`, run, bt, finish) and reads the test function, the file name argument of `parse_file`, the key and the value. There is no stored answer key. The expected values are the ones in `rubric.md`; `--health` asserts this.

## Drill 2 (mystery binaries)
`/opt/osvr/fnd03/mystery/m1..m6`, checker `/opt/osvr/fnd03/tools/mystery-check FILE` (salted hashes, prints match/differ only). The image build verifies every answer-key field against the real artefacts with `nm -D`, `ldd`, `readelf` and `objdump` and fails if one disagrees. Source and plain key are deleted from the image (they are in this directory in the repo, `mystery/`).

## Troubleshooting
1. Module build fails at `FROM osvr-fnd-base:1`: run `./build.sh` (builds the base if missing).
2. gdb prints `Error disabling address space randomization: Function not implemented`: harmless; use `ASLR_OFF=1 ./run.sh` if you need fixed addresses.
3. gdb run ends with `LeakSanitizer has encountered a fatal error`: start with `ASAN_OPTIONS=detect_leaks=0`.
