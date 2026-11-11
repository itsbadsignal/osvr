# FND-02 lab: C pointers and memory

lab_status: verified on rootless podman 6.1.4 (Arch host, kernel 7.2.11), 2026-11-11. Docker: UNTESTED (not installed on the maintainer's machine; the Docker code paths in run.sh and check.sh are untested requirements).

Needs: 2 GB RAM; disk: osvr-fnd02:1 adds about 19 MB on the base (689 MB base+FND-01 layers are shared); the optional iperf image adds about 83 MB. Network only to build.

## Commands (from this directory; ENGINE defaults to podman, else docker)
```sh
./build.sh                   # builds osvr-fnd-base:1 if missing, then osvr-fnd02:1 (about 10 s)
IPERF=1 ./build.sh           # also builds osvr-fnd02-iperf:1 (ASan iperf at 4eab661d and 4e5313ba; network; about 30 s to 3 min). Needed for the real-bug step
NO_CACHE=1 ./build.sh        # osvr-fnd02:1 (and the iperf image with IPERF=1) with --no-cache; the base image is only built if missing (BASE=1 forces it)
./run.sh                     # interactive shell, --network=none, ~/osvr-work/fnd02 at /work/fnd02
./check.sh                   # grades ~/osvr-work/fnd02/project/repro/repro.c (REPRO= to override)
./check.sh realbug           # grades ~/osvr-work/fnd02/realbug/harness.c (read-only) against the iperf ASan builds; image osvr-fnd02-iperf:1
./check.sh hardening         # prints readelf facts for repro.c, default and weak builds (no PASS/FAIL)
./reset.sh                   # removes the images; your work dir is untouched
```
`check.sh` takes one of `repro`, `hardening`, `realbug`; anything else prints `usage: check.sh [repro|hardening|realbug]` and exits 2. Every build tees its log to `~/osvr-work/fnd02/build-logs/build-<UTC timestamp>.log` and prints the path.
Inside the image: `/opt/osvr/fnd02/src/` (scores.c, upper.c, intra.c, unchanged), `/opt/osvr/fnd02/tools/predict-check`, `/src/iperf` (full clone, history and tags, at the fix commit `4e5313ba`; cloned from `https://github.com/esnet/iperf`).

run.sh flags: `--network=none --cap-drop=ALL --security-opt seccomp=unconfined`. The seccomp flag is needed only so gdb can turn ASLR off (default seccomp blocks `personality(2)`). Docker adds `--user "$(id -u):$(id -g)" --cap-add=SYS_PTRACE`.

## predict-check
`predict-check PRED_FILE -- CMD...` runs CMD, parses the first ASan report and prints predicted vs actual for `kind op size offset region frame0 alloc`. Keys are `key: value` lines; `predict-check --help` prints the key list. `frame0` is the first frame that is not a sanitizer interceptor or libc frame (the first frame in your program's own source): an overflow inside `memset` or `snprintf` reports the caller in your code. Heap, stack and global-variable reports are parsed (for a global, `region` is the variable's size and `alloc` its name). Exit status: 0 report found (whatever matched), 1 no ASan report, 2 usage error. Fixture test (heap, stack, global, interceptor, each with a correct and a wrong prediction): `podman run --rm osvr-fnd02:1 /opt/osvr/fnd02/tools/tests/run_tests.sh`. Host-side fixtures for check.sh: `tests/run_tests.sh`.

## Real-bug harness (needs `IPERF=1 ./build.sh`)
Write `~/osvr-work/fnd02/realbug/harness.c` (it is `/work/fnd02/realbug/harness.c` inside `./run.sh`; run it in the `osvr-fnd02-iperf:1` image: `IMAGE=osvr-fnd02-iperf:1 ./run.sh`). Try it with `/opt/osvr/fnd02/tools/realbug.py vuln harness.c` and `... fixed harness.c`, which print the build line, the program output and the exit status. `./check.sh realbug` compiles your harness (only that one file, read-only) twice, against `/src/iperf-vuln/src/iperf_auth.o` (`4eab661d`) and `/src/iperf-fixed/src/iperf_auth.o` (`4e5313ba`), runs each from a directory holding `private.pem`, and passes only if the vulnerable build reports a heap-buffer-overflow WRITE of size 1 at `decode_auth_setting` `iperf_auth.c:390` and the fixed build gives no ASan report. Paths in `osvr-fnd02-iperf:1` (each tree has the ASan-built object, the source and the header; `git -C <tree> rev-parse --short=8 HEAD` gives the commit): vulnerable `4eab661d`: `/src/iperf-vuln/src/iperf_auth.o`, `/src/iperf-vuln/src/iperf_auth.c`, `/src/iperf-vuln/src/iperf_auth.h`; fixed `4e5313ba`: `/src/iperf-fixed/src/iperf_auth.o`, `/src/iperf-fixed/src/iperf_auth.c`, `/src/iperf-fixed/src/iperf_auth.h`. Keys: `private.pem`, `public.pem` in the same `src/` dirs. Build line: `gcc -g -O1 -fsanitize=address -fno-omit-frame-pointer -I<tree>/src harness.c <tree>/src/iperf_auth.o -lssl -lcrypto -o OUT`. Runs use `ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0`; without the second option the allocation stack ends inside libcrypto (`CRYPTO_malloc`) and never names the iperf function that allocated.

## Variation 2 program
`/opt/osvr/fnd02/src/freeorder.c`: `freeorder KEYSIZE [PAIRS]` allocates PAIRS pairs of KEYSIZE-byte blocks (default 10), writes one NUL at `p[i][KEYSIZE]` for every `p`, frees all `p`, then all `q`. Build it plain (`gcc -g -O0`), not with ASan.

## iperf ASan build
`IPERF=1 ./build.sh` (or `podman build -t osvr-fnd02-iperf:1 -f Dockerfile.iperf .`) builds iperf at `4eab661d` and `4e5313ba` with ASan in `/src/iperf-vuln` and `/src/iperf-fixed`. The shipped test `t_auth` does NOT reproduce CVE-2025-54349 (fails the same way on both commits); the hand-written harness does. See Implementation notes in SPEC.md.

## Troubleshooting
1. Build fails at `FROM osvr-fnd-base:1`: build the base first (`./build.sh` does).
2. gdb prints `Error disabling address space randomization: Function not implemented`: you started the container without `--security-opt seccomp=unconfined`. Use `./run.sh`.
3. `check.sh realbug` says `image: osvr-fnd02-iperf:1 not found`: run `IPERF=1 ./build.sh`. `harness.c: not found`: it looks in `~/osvr-work/fnd02/realbug/`; set `WORK=`.
4. `check.sh` says `repro.c: not found`: it looks in `~/osvr-work/fnd02/project/repro/`; set `REPRO=/path/to/repro.c`.
