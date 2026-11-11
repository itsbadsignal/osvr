# Session 2026-11-10

Module: FND-01-linux-lab-and-learning-protocol   Timebox: 50 min   Actual: 38 min
Goal: Done when ~/osvr-work/s0/gcc-version.txt exists on the host and its first line is the gcc version printed inside a debian:trixie container.

## Warm-up recall
None (first session).

## What happened
Pulled debian:trixie with podman, ran gcc --version inside with a bind mount. First attempt wrote to /tmp inside the container and the file vanished; fixed by writing to /out.
Distractions logged: 2 (podman registry prompt; whether to install Docker as well). Both parked.

## Hints used
Highest rung: 0   On: n/a   Struggle time before hint: n/a

## Close-out recall
Recalled pull/run/--rm/-v and same-kernel point. Missed: why the file owner is my UID under rootless podman.

## New cards
- me-s0-01

## Next action
Run: "$ENGINE" build --help | less  and find the flag that names the recipe file.
