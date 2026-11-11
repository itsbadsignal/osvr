#!/bin/bash
# Build the base image, then the FND-02 image. Honours ENGINE.
# IPERF=1    also builds osvr-fnd02-iperf:1 (iperf with ASan at 4eab661d and 4e5313ba, libssl-dev; needs the network,
#            about 1 to 3 minutes) on top of the osvr-fnd02:1 just built. Needed for the real-bug harness step.
# NO_CACHE=1 builds osvr-fnd02:1 (and the iperf image, with IPERF=1) with --no-cache. The shared base image
#            osvr-fnd-base:1 is built only if missing (or with BASE=1, which rebuilds it with the same flags).
# The whole log is tee'd to ~/osvr-work/fnd02/build-logs/build-<UTC timestamp>.log and the path is printed.
# An uncached podman log has no "Using cache" lines (Docker prints "CACHED" for reused steps; Docker UNTESTED).
set -eu
set -o pipefail
ENGINE=${ENGINE:-$(command -v podman || command -v docker || true)}
[ -n "$ENGINE" ] || { echo "FAIL: no podman or docker on PATH" >&2; exit 1; }
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/../../../../../.." && pwd)
LOGDIR=$HOME/osvr-work/fnd02/build-logs
mkdir -p "$LOGDIR"
LOG=$LOGDIR/build-$(date -u +%Y%m%dT%H%M%SZ).log
flags=()
if [ "${NO_CACHE:-0}" = 1 ]; then flags+=(--no-cache); echo "NO_CACHE=1: building without cache"; fi
echo "build log: $LOG"
{
  if [ "${BASE:-0}" = 1 ] || ! "$ENGINE" image inspect osvr-fnd-base:1 >/dev/null 2>&1; then
    "$ENGINE" build "${flags[@]}" -t osvr-fnd-base:1 -f "$ROOT/labs/shared/fnd-base/Dockerfile" "$ROOT/labs/shared/fnd-base"
  fi
  "$ENGINE" build "${flags[@]}" -t osvr-fnd02:1 -f "$HERE/Dockerfile" "$HERE"
  if [ "${IPERF:-0}" = 1 ]; then
    "$ENGINE" build "${flags[@]}" -t osvr-fnd02-iperf:1 -f "$HERE/Dockerfile.iperf" "$HERE"
  fi
} 2>&1 | tee "$LOG"
echo "build log: $LOG"
