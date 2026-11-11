# Lab spec: FND-01-linux-lab-and-learning-protocol

Target: cJSON (smoke test only)   Version: tag `v1.7.17` = commit `87d8f0961a01bf09bef98ff89bae9fdec42181ee`; negative control at fix commit `3ef4e4e730e5efd381be612df41e1ff3f5bb3c32`   Source: `https://github.com/DaveGamble/cJSON` (all from `research/targets/FND.md`, fetched and built 2026-11-10)
Kind: docker (must work identically under `podman` and `docker`; the maintainer's machine has rootless podman only)
Bug: CVE-2023-53154, heap-based buffer over-read (CWE-125) in `parse_string`, `cJSON.c`   Fix reference: commit `3ef4e4e…` "Fix heap buffer overflow" (Fixes #800), shipped in 1.7.18; MITRE record `https://cveawg.mitre.org/api/cve/CVE-2023-53154`

This spec has **two deliverables**:
1. **A shared base image, `labs/shared/fnd-base/`, reused by every FND module** (FND-02 to FND-08). Design it for reuse, not just for this smoke test.
2. **The FND-01 module lab** in this directory, a thin layer `FROM` the base that runs the smoke test. It also ships a host-side session-log checker at `labs/shared/tools/check_session.py`.

The learner may not be able to program yet. Nothing here may require them to write or edit C.

## Interface contract (the module text depends on these names)
The README walkthrough, drills, project and rubric use these. If you must change one, update `lab/README.md` and tell the caller, so the module text can be edited to match.

| Item | Name / behaviour |
|---|---|
| Base recipe | `labs/shared/fnd-base/Dockerfile`, build context `labs/shared/fnd-base/` |
| Base image tag | `osvr-fnd-base:1` |
| Module recipe | `curriculum/tracks/FND/modules/FND-01-linux-lab-and-learning-protocol/lab/Dockerfile`, context = that `lab/` dir, first line `FROM osvr-fnd-base:1` (verify podman resolves this to the local `localhost/osvr-fnd-base:1` without a registry prompt; if not, use `FROM localhost/osvr-fnd-base:1` and confirm Docker accepts that name, or document a build arg) |
| Module image tag | `osvr-fnd01:1` |
| Default command | runs the smoke test (below), writes outputs to `/out` |
| Outputs in `/out` | `first-asan-report.txt` (stderr of the vulnerable run, unedited), `env.txt` (`key=value`; flags key is `cflags`), `control.txt` (stderr of the fixed run plus a final `control exit status: N` line) |
| Wrappers | `build.sh` (`NO_CACHE=1` for an uncached build; logs to `~/osvr-work/fnd01/build-logs/build-<UTC timestamp>.log`), `run.sh` (honours `OUT`, `LAB_CFLAGS`, `IMAGE`), `check.sh` (default mode grades the files in `$OUT` read-only and needs no engine; `--health` runs `IMAGE` into a temp dir), `reset.sh` (deletes `$OUT` and the module image; `FULL=1` also the base image and dangling images). `ENGINE` defaults to `podman` if on PATH, else `docker`. The overlearning stretch grades a learner-built image through `OUT=` only, not `IMAGE` |
| Host output dir | `run.sh` and `check.sh` default to `~/osvr-work/fnd01/out` (override with `OUT=`) |
| Flag override | smoke script honours `LAB_CFLAGS` env var (default below; ambient `CFLAGS` ignored) for the project variations, e.g. `-e LAB_CFLAGS="-O0 -fno-omit-frame-pointer -fsanitize=address,undefined"` (no `-g`) |
| Session checker | `labs/shared/tools/check_session.py FILE` (Python 3 stdlib only, runs on the host) |

The struggle challenge tells the learner **not** to open `README.md`, `build.sh` or `run.sh` and to work from the Dockerfiles. So the Dockerfiles must be readable on their own. Use comments stating what the image needs at run time: "mount a host dir at /out", "runs with --network=none", and the user the image runs as.

## Base image: `labs/shared/fnd-base/`
- `FROM docker.io/library/debian:trixie@sha256:...`, pinned by digest. Resolve the digest at build time and record it in `labs/shared/fnd-base/README.md` and inside the image (for example `/etc/osvr-base-digest`), because the learner's `env.txt` and `lab-evidence.md` must report it. Research used `debian:trixie` (Debian 13, gcc 14.2.0) on 2026-11-10.
- Packages (pin exact versions, or install from a dated Debian snapshot archive, and record installed versions in `/etc/osvr-packages.txt`): `gcc`, `g++`, `make`, `cmake`, `git`, `gdb`, `binutils` (readelf, objdump), `file`, `python3`, `python3-venv`, `ca-certificates`, `less`, `nano`, `vim-tiny` (or similar), `procps`. Leave out pwntools for now (FND-08 adds a layer). Optional but wanted for FND-03: GEF or pwndbg at a pinned commit. GEF is the single-file option with fewer dependencies (`research/domain-maps/foundations.md`); pwndbg needs GDB 12.1+ and Python 3.10+. Pick one and pin it.
- `llvm-symbolizer` is not required. Research got file:line from gcc's ASan in this image. Confirm the report is symbolised without it.
- User handling must give host-owned output files under **both** engines. Suggested: the image runs as root by default (safe under rootless podman because root maps to the host user). `run.sh` passes `--user "$(id -u):$(id -g)"` under Docker. Alternatively use a non-root image user plus `--userns=keep-id` under podman. Whatever you choose, state it in a Dockerfile comment and test both engines if you can (Docker is not installed on the maintainer machine; say so if untested).
- `WORKDIR /work`. No services. No `EXPOSE`.
- Document in `labs/shared/fnd-base/README.md`, for FND-03 onwards: what gdb needs inside the container under rootless podman and under Docker (e.g. `--cap-add=SYS_PTRACE`, `--security-opt seccomp=unconfined`), verified by actually doing `gdb -batch -ex run -ex bt` on a crashing program. Also how to see ASLR state (`cat /proc/sys/kernel/randomize_va_space`, the host value) and how to disable it per process for early drills (`setarch -R`), if seccomp allows it. Mark each item verified or not.

## FND-01 module lab
- `FROM osvr-fnd-base:1`.
- At **build** time (network allowed): clone cJSON, and create two worktrees or two clones: `/src/cjson-vuln` at `87d8f0961a01bf09bef98ff89bae9fdec42181ee` and `/src/cjson-fixed` at `3ef4e4e730e5efd381be612df41e1ff3f5bb3c32`. After each checkout, `test "$(git rev-parse HEAD)" = <expected>` must fail the build on mismatch. Alternatively, fetch release tarballs or GitHub archive tarballs for those commits with SHA-256 verification. Record the hashes.
- `harness.c` (lab-engineer writes it, per `research/targets/FND.md`): a buffer of exactly 7 bytes from `malloc(7)`, filled with `memcpy` with the 7 bytes `{"1":1,` (no NUL terminator, no newline), then `cJSON_ParseWithLength(buf, 7)`, `cJSON_Delete` on the result, and `free(buf)`. About 6 lines of logic. Comment it, since FND-03 learners will read it. Do **not** add explanation of why it crashes.
- `smoke.sh` (the default command):
  - Default `LAB_CFLAGS="-g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined"`. Research's verified line: `gcc -g -O0 -fsanitize=address,undefined -fno-omit-frame-pointer -I. harness.c cJSON.c -lm`.
  - Print the exact compile command before running it.
  - Compile against `/src/cjson-vuln`, run, and write stderr to `/out/first-asan-report.txt`. Also echo it to the terminal.
  - Write `/out/env.txt`: base image digest, `gcc --version | head -1`, the `LAB_CFLAGS` used, `git -C /src/cjson-vuln rev-parse HEAD`, `git -C /src/cjson-fixed rev-parse HEAD`, `uname -r` (host kernel), `cat /proc/sys/kernel/randomize_va_space`, date.
  - Fail loudly if `/out` is not a mount, or is not writable (common failure). The error message should name the `-v` flag.
- Runtime: `--network=none`. No extra capabilities. The smoke test needs no ptrace.

## Expected vulnerable behaviour
Verified by research on 2026-11-10 (rootless podman 6.1.4, `debian:trixie`, gcc 14.2.0):
- Vulnerable build: `AddressSanitizer: heap-buffer-overflow ... cJSON.c:786 in parse_string`, with the allocation reported from `malloc` in the harness. Process exits non-zero.
- Fixed build (`3ef4e4e`): clean exit, no ASan output.

Please confirm and record in Implementation notes: the full frame list, the READ size, the exact "located N bytes after M-byte region" line, and the exit status of the vulnerable run. The README's walkthrough marks these `needs-lab-verification` and will be updated from your notes.

**LeakSanitizer caution.** LSan runs at normal process exit (the negative control). Research's clean control ran under rootless podman only, and Docker is untested. Either verify LSan works under both engines, or run the control with `ASAN_OPTIONS=detect_leaks=0` and say why in a comment. Leaks are not the subject here. (Edited 2026-11-11: an earlier version of this paragraph claimed, from memory, that Docker's seccomp breaks LSan. No primary source supports that; see `research/domain-maps/foundations.md`, "FND-01 lab sources".)

## Mitigation build matrix
| Variant | Flags / config | Used by |
|---|---|---|
| smoke (default) | `-g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined`; distro gcc defaults otherwise; FORTIFY not added (incompatible with sanitizers per OpenSSF guide; at `-O0` it would not apply anyway) | struggle challenge, project, check.sh |
| no-debug-info | default minus `-g` via `LAB_CFLAGS` | project variation 1 |
| no-sanitizer | `-g -O0` only via `LAB_CFLAGS` | project variation 2 (check.sh must not be used to grade this; the learner records the observation) |
| weak-vs-hardened (`-fno-stack-protector -no-pie -z norelro -D_FORTIFY_SOURCE=0` vs default) | **not in FND-01.** Leave for FND-02/03 | n/a |

## Checker idea
Superseded by the implemented interface (fix round 1, 2026-11-11). The authoritative description is in the script headers and in **Implementation notes** below. Summary:

`check.sh` (host side, prints `PASS`/`FAIL` per line with a one-line informational reason; must not explain the bug):
- **Default mode (grading).** Grades the learner's own artefacts in `$OUT` read-only. It never deletes, regenerates or modifies them, and needs no container engine. It prints `Grading <OUT> (read-only)`, then 15 checks in order:
  1. the three files are present;
  2. the three files are owned by the invoking user;
  3. `cflags` equals the default `LAB_CFLAGS` (otherwise `NOTICE` + `FAIL  flags: graded only with default LAB_CFLAGS ...`, and grading stops);
  4. `net_interfaces=lo`;
  5. both pinned commits;
  6. non-zero `vuln_exit_status`;
  7. a clean control (`control exit status: 0`, no ASan output);
  8. `ERROR: AddressSanitizer: heap-buffer-overflow`;
  9. `cJSON.c:786 in parse_string`;
  10. a `located N bytes ... 7-byte region` line.

  It ends with `SUMMARY: all checks passed` (exit 0) or `SUMMARY: N check(s) failed` (exit 1).
- **`--health`.** Checks the engine and `IMAGE`, runs the image once with `--network=none` into a temp dir, grades it, and removes the dir. It ends with `LAB HEALTH OK (temp dir removed; your <OUT> was not touched)` or `LAB HEALTH FAILED`.
- **Any other argument.** Prints usage and exits 2.

`labs/shared/tools/check_session.py FILE` (stdlib only, exit 0 if all pass, one message per failure naming the field):
- Has `Module:`, `Timebox: N min`, `Actual: N min` (numbers), and a non-empty `Goal:` that contains "Done when" or an equivalent observable phrase (implemented list: done when/if, done-check, success:, exits 0, exit status, passes, exists, prints). Keep the heuristic simple and document it. It cannot judge quality, and the rubric says so.
- Sections `## What happened` (containing a line starting `Distractions` with a count or list), `## Hints used`, `## Close-out recall` (non-empty), `## Next action` (non-empty, not just "continue"/"keep going"/"same", and at least 4 words or containing a backtick/command/path). As implemented: an empty `Distractions logged:` fails (write `none`), and a Next action with a vague phrase (continue, keep going, carry on, read more, work on it/this/that, more of the same, keep at it) must also name a concrete object.
- Works on the session template in `templates/learner/session.md` filled in as in the README worked example. Include that example as a test fixture that passes, plus a fixture that fails.

## Limits
RAM: 2 GB is plenty (the Clang ASan docs say ASan maps, but does not reserve, 16+ TB of shadow memory on 64-bit and that `ulimit` may not behave as expected; this is virtual address space, not RSS; do not set `ulimit -v`)   Disk: measure and record, target under 1.5 GB for base + module   Network: build time only (apt, git clone). None at runtime (`--network=none`)

Ethics (D10): local container, archived vulnerable version, no listening ports, no network at runtime.

## Implementation notes (lab-engineer appends)

### Implementation notes (lab-engineer, 2026-11-11)
- Built and run end to end on rootless podman 6.1.4 only. Docker untested.
- Verified report (`-g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined`, gcc 14.2.0-19): `ERROR: AddressSanitizer: heap-buffer-overflow on address ...`, `READ of size 1`; frames #0 parse_string cJSON.c:786, #1 parse_object :1665, #2 parse_value :1365, #3 cJSON_ParseWithLengthOpts :1125, #4 cJSON_ParseWithLength :1187, #5 main harness.c:19, #6-#8 libc/_start; `located 0 bytes after 7-byte region`; allocation `malloc` then `main harness.c:13`; exit status 1; no llvm-symbolizer needed.
- LeakSanitizer works under default rootless podman (a deliberate leak was reported), but smoke.sh still sets `detect_leaks=0` because Docker is untested. Control exits 0, clean.
- `FROM osvr-fnd-base:1` resolves locally under podman. Run user is root in both images (deviation from nothing; as suggested in spec). `--userns=keep-id` also works.
- Control output is stderr plus a final `control exit status: N` line. env.txt is `key=value` and additionally holds `net_interfaces`, `vuln_exit_status`, `control_exit_status`.
- Harness line numbers are tied to harness.c; do not edit it without updating the notes.

### Implementation notes (lab-engineer, 2026-11-11, audit revision)
- `check.sh` default mode grades the learner's `$OUT` read-only (no engine needed); `--health` is the old self-run into a `mktemp` dir. Extra checks: all three files present and owned by the invoker, `cflags` in env.txt equals the default or the run FAILS with `graded only with default LAB_CFLAGS`, 7-byte region, `cJSON.c:786` in `parse_string`.
- Flags variable is `LAB_CFLAGS` (run.sh, smoke.sh, check.sh); ambient `CFLAGS` is unset in smoke.sh. Override prints `LAB_CFLAGS override in effect: ...`.
- build.sh (module and base): `NO_CACHE=1`, log tee to `~/osvr-work/fnd01/build-logs/`. reset.sh `FULL=1` prunes dangling images and reports truthfully whether the base was removed (podman refuses while another image, such as FND-02's, uses it).
- Verified on rootless podman 6.1.4: learner run passes; run without `--network=none` fails on `net_interfaces` (`lo wlp9s0`); `--user 1000:1000` fails in the container with the "not writable" message and check.sh reports the three files missing; `$OUT` checksums and mtimes unchanged after check.sh; `--health` OK; uncached log has 0 `Using cache`; ambient `CFLAGS=-O2` ignored (default cflags recorded). Docker paths UNTESTED.
- `labs/shared/tools/tests/run_tests.sh` now requires fail fixtures to exit exactly 1 (it previously accepted exit 2).
