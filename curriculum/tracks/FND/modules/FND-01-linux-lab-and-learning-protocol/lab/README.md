# FND-01 lab: first ASan report (cJSON CVE-2023-53154)

lab_status: verified on rootless podman 6.1.4 (Arch host, kernel 7.2.11), 2026-11-11. Docker: UNTESTED (not installed on the maintainer's machine; code paths for Docker exist in run.sh/check.sh --health).

Needs: 2 GB RAM, about 1.4 GB disk (base 679 MB + module 688 MB, shared layers), network only to build. Runs with `--network=none`.

## Commands (from this directory; ENGINE defaults to podman, else docker)
```sh
./build.sh                  # builds osvr-fnd-base:1 then osvr-fnd01:1 (about 45 s first time)
NO_CACHE=1 ./build.sh       # same, both images with --no-cache (needs the network; a few minutes)
./run.sh                    # smoke test, results in ~/osvr-work/fnd01/out (override with OUT=)
./check.sh                  # grade YOUR artefacts in $OUT (default ~/osvr-work/fnd01/out); read-only
./check.sh --health         # lab self-test: runs the image into a temp dir, grades it, removes it
./reset.sh                  # remove outputs and the module image
FULL=1 ./reset.sh           # also remove the base image and prune dangling images
```
Teardown: `FULL=1 ./reset.sh`. Debugging belongs to FND-03; for gdb and ASLR notes see `labs/shared/fnd-base/README.md`.

Build logs: every build tees to `~/osvr-work/fnd01/build-logs/build-<UTC timestamp>.log` and prints `build log: <path>` at the start and end. A cached rebuild shows `Using cache` lines (podman; Docker prints `CACHED`, UNTESTED). An uncached log (`NO_CACHE=1`) contains none of them (verified: 0 on podman, 14 in the cached log). The base image alone: `labs/shared/fnd-base/build.sh` (log `build-base-<timestamp>.log`, same `NO_CACHE`).

`check.sh` never deletes, regenerates or modifies files in `$OUT` (verified by checksum and mtime). It needs no container engine. `--health` writes only to a `mktemp` directory that it removes, and always uses the default flags.

Variations: `LAB_CFLAGS="-O0 -fno-omit-frame-pointer -fsanitize=address,undefined" OUT=~/osvr-work/fnd01/out-nog ./run.sh` (no `-g`), `LAB_CFLAGS="-g -O0" OUT=... ./run.sh` (no sanitizer). `run.sh` and the smoke test print `LAB_CFLAGS override in effect: ...` when it is set. Ambient `CFLAGS` is ignored. `check.sh` fails such outputs with `graded only with default LAB_CFLAGS`; use a separate `OUT=` so your graded outputs stay intact.

## Expected check.sh output
`Grading <OUT> (read-only)`, then PASS lines (3 files present, 3 owners, default flags, loopback only, two commits, exit status non-zero, control, heap-buffer-overflow, cJSON.c:786 in parse_string, 7-byte region), then `SUMMARY: all checks passed`, exit 0. On failure: `SUMMARY: N check(s) failed`, exit 1. `--health` adds engine, image and run PASS lines and ends `LAB HEALTH OK (temp dir removed; your <OUT> was not touched)`, or `LAB HEALTH FAILED`.

## Expected report (verified; addresses vary)
First lines: `ERROR: AddressSanitizer: heap-buffer-overflow on address 0x... `, `READ of size 1`, frames `#0 parse_string cJSON.c:786`, `#1 parse_object cJSON.c:1665`, `#2 parse_value cJSON.c:1365`, `#3 cJSON_ParseWithLengthOpts cJSON.c:1125`, `#4 cJSON_ParseWithLength cJSON.c:1187`, `#5 main /opt/lab/harness.c:19`, then libc frames. `0x... is located 0 bytes after 7-byte region [...)`, allocated by `#0 malloc (asan_malloc_linux.cpp:69)`, `#1 main /opt/lab/harness.c:13`. `SUMMARY: ... cJSON.c:786 in parse_string`. Exit status 1.

## Troubleshooting
1. `SMOKE FAIL: /out is not a mounted directory` or check says `file: ... missing or empty`: missing `-v`. Use `run.sh`, or `-v "$HOME/osvr-work/fnd01/out:/out"`. If the dir is mounted but "not writable": wrong owner, usually `--user uid:gid` under rootless podman (drop it) or root-owned files under Docker (add it).
2. Module build fails at `FROM`: build the base first (`./build.sh` does both). Check `podman images | grep osvr`.
Also: `ReserveShadowMemoryRange failed ... ulimit -v` means a virtual-memory limit is set in your shell (verified with `ulimit -v 4000000`); run `ulimit -v unlimited`.
