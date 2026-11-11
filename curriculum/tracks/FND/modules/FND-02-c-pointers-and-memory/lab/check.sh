#!/bin/bash
# Host-side checker for FND-02. Usage: check.sh [repro|hardening|realbug]   (default repro; anything else: usage, exit 2)
# Honours ENGINE, IMAGE, WORK (default ~/osvr-work/fnd02), REPRO (default $WORK/project/repro/repro.c; repro and hardening).
#   repro, hardening: IMAGE defaults to osvr-fnd02:1.
#   realbug: IMAGE defaults to osvr-fnd02-iperf:1 (IPERF=1 ./build.sh); grades $WORK/realbug/harness.c, mounted read-only.
MODE=${1:-repro}
case "$MODE" in repro|hardening|realbug) ;; *) echo "usage: check.sh [repro|hardening|realbug]" >&2; exit 2 ;; esac
ENGINE=${ENGINE:-$(command -v podman || command -v docker || true)}
WORK=${WORK:-$HOME/osvr-work/fnd02}
if [ "$MODE" = realbug ]; then IMAGE=${IMAGE:-osvr-fnd02-iperf:1}; else IMAGE=${IMAGE:-osvr-fnd02:1}; fi
if [ -z "$ENGINE" ] || ! command -v "$ENGINE" >/dev/null; then echo "FAIL  engine: no podman or docker on PATH (set ENGINE=)"; exit 1; fi
[ "$MODE" = hardening ] || echo "PASS  engine: $ENGINE"
if ! "$ENGINE" image inspect "$IMAGE" >/dev/null 2>&1; then
  if [ "$MODE" = realbug ]; then echo "FAIL  image: $IMAGE not found. Build it first: IPERF=1 ./build.sh"; else echo "FAIL  image: $IMAGE not found. Build it first"; fi
  exit 1
fi
[ "$MODE" = hardening ] || echo "PASS  image: $IMAGE present"
args=(--rm --network=none)
case "$(basename "$ENGINE")" in docker) args+=(--user "$(id -u):$(id -g)") ;; esac   # Docker branch UNTESTED
if [ "$MODE" = realbug ]; then
  H=$WORK/realbug
  [ -f "$H/harness.c" ] || { echo "FAIL  harness.c: not found at $H/harness.c (set WORK=)"; exit 1; }
  D=$(cd "$H" && pwd)
  exec timeout 120 "$ENGINE" run "${args[@]}" -v "$D:/realbug:ro" "$IMAGE" /opt/osvr/fnd02/tools/grade-repro realbug /realbug
fi
REPRO=${REPRO:-$WORK/project/repro/repro.c}
[ -f "$REPRO" ] || { echo "FAIL  repro.c: not found at $REPRO (set REPRO=)"; exit 1; }
D=$(cd "$(dirname "$REPRO")" && pwd)
[ "$(basename "$REPRO")" = repro.c ] || { echo "FAIL  repro: the file must be named repro.c"; exit 1; }
exec timeout 120 "$ENGINE" run "${args[@]}" -v "$D:/repro:ro" "$IMAGE" /opt/osvr/fnd02/tools/grade-repro "$MODE" /repro
