# osvr-fnd-base:1 (shared FND base image)

lab_status: verified on rootless podman 6.1.4, 2026-11-11. Docker not installed on the maintainer's machine: Docker items below are marked UNTESTED.

Reused by FND-01 to FND-08. Debian 13 (trixie), gcc 14.2.0-19, gdb 16.3-1, GEF.

## Pins
| Item | Value |
|---|---|
| Base image | `docker.io/library/debian:trixie@sha256:bfc36aecdece0387418759dba474aa856c026ca8087da3606b41b90ab0509c99` (image index digest, resolved 2026-11-10) |
| Packages | Debian snapshot archive `20261104T212339Z` (the instant the pinned image was built; shown in the base image's own apt sources). Installed versions: `/etc/osvr-packages.txt` inside the image (205 lines) |
| gdb extension | GEF tag 2026.01, commit `18404074f469c70480aae071fbb77b75a2ed8507`, `gef.py` sha256 `04cdfe961f1e9151933d32cf6b548d9e6a76a1aef8b27c020c575b8d4264ed20` (checked at build), loaded by `/etc/gdb/gdbinit` |
| Digest record | `/etc/osvr-base-digest` |

Key versions: gcc `4:14.2.0-1`, gdb `16.3-1`, cmake `3.31.6-2`, git `1:2.47.3-0+deb13u1`, python3 `3.13.5-1`.
Tools: gcc g++ make cmake git gdb binutils file python3 python3-venv curl less nano vim-tiny procps, plus util-linux `setarch`. No pwntools (FND-08 adds a layer). No llvm-symbolizer: gcc 14 ASan reports are symbolised with file:line without it (verified).

Rebuild reproducibility (verified 2026-11-11): a `--no-cache` rebuild gave an identical package list. The image ID differs on every build (timestamps), so compare digest, package list and commits, not the image ID.

## Build
`./build.sh` here (`NO_CACHE=1 ./build.sh` for `--no-cache`; the log goes to `~/osvr-work/fnd01/build-logs/build-base-<UTC timestamp>.log` and its path is printed; an uncached podman log has no `Using cache` lines, Docker prints `CACHED` when cached, UNTESTED), or `podman|docker build -t osvr-fnd-base:1 -f Dockerfile .` in this directory. Needs the network (about 40 s, 679 MB). Downstream `FROM osvr-fnd-base:1` resolves to the local `localhost/osvr-fnd-base:1` under podman with no registry prompt (verified). Docker: a short local name resolves to the local image (UNTESTED here).

## User and bind mounts
The image runs as root. Verified under rootless podman 6.1.4:
- no flag: files in a bind mount are owned by you.
- `--userns=keep-id`: also works, owned by you; gcc and git work as your uid.
- `--user "$(id -u):$(id -g)"` WITHOUT keep-id: container uid 1000 is a subuid on the host, so the mount is not writable and files would not be yours. Do not use it under podman.
Docker (UNTESTED): root in the container is real root, so pass `--user "$(id -u):$(id -g)"`. The module `run.sh`/`check.sh` do this when ENGINE is docker. SELinux hosts may need `:Z` on the mount (UNTESTED).

## gdb in the container (for FND-03 onward)
Verified: `gdb -batch -ex run -ex bt ./crash` on a program that dereferences NULL works under rootless podman with default flags: no `--cap-add=SYS_PTRACE`, no seccomp change. It prints the SIGSEGV and a backtrace (`#0 ... in main () at crash.c:2`). GEF is loaded and prints a colour context pane even in batch mode. For plain gdb use `gdb -nx`.

What does not work by default: gdb prints `warning: Error disabling address space randomization: Function not implemented`, so gdb's own ASLR disabling fails (see below). Programs under gdb then run with ASLR on.

Docker (UNTESTED): Docker's seccomp documentation lists ptrace as blocked on kernels before 4.8 and says tracing arbitrary processes is blocked by dropping CAP_SYS_PTRACE; it does not state that gdb launching its own child works, so treat that as unverified. It lists personality as restricted (see `research/domain-maps/foundations.md`, FND-01 lab sources). If gdb fails to attach or run, add `--cap-add=SYS_PTRACE --security-opt seccomp=unconfined`.

## ASLR
- The ASLR setting is the HOST kernel's. See it: `cat /proc/sys/kernel/randomize_va_space` (2 = full on this host and in the container; the container cannot write it).
- Per process off: `setarch -R ./prog` (or `setarch x86_64 -R`). Verified: under default podman it fails with `setarch: failed to set personality to (null): Function not implemented` (seccomp blocks `personality`). With `--security-opt seccomp=unconfined` it works: two runs print identical stack (`0x7fffffffec28`) and PIE addresses (`0x555555555149`), and gdb run also gets fixed addresses (`0x55555555...`). Without it, addresses differ per run (verified).
- Re-enable: just stop using `setarch -R`; nothing persistent changed. Only use `seccomp=unconfined` for early FND-03 drills that need fixed addresses, never for FND-01.
- ptrace_scope on this host is 1 (Yama); gdb launching its own child is unaffected.

## Not in this image
No services, no EXPOSE. Network is only needed to build; run derived images with `--network=none`.
