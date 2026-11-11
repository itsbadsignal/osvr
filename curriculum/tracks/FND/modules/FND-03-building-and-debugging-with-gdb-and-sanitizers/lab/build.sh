#!/bin/bash
# Build the base image if missing, then the FND-03 image. Honours ENGINE.
# NO_CACHE=1 builds with --no-cache (base too if it must be built).
# The log is tee'd to ~/osvr-work/fnd03/build-logs/build-<UTC timestamp>.log and the path is printed.
# An uncached podman log has no "Using cache" lines (Docker prints CACHED; Docker UNTESTED).
set -eu
set -o pipefail
ENGINE=${ENGINE:-$(command -v podman || command -v docker || true)}
[ -n "$ENGINE" ] || { echo "FAIL: no podman or docker on PATH" >&2; exit 1; }
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/../../../../../.." && pwd)
LOGDIR=$HOME/osvr-work/fnd03/build-logs
mkdir -p "$LOGDIR"
LOG=$LOGDIR/build-$(date -u +%Y%m%dT%H%M%SZ).log
flags=()
if [ "${NO_CACHE:-0}" = 1 ]; then flags+=(--no-cache); echo "NO_CACHE=1: building without cache"; fi
echo "build log: $LOG"
{
  if ! "$ENGINE" image inspect osvr-fnd-base:1 >/dev/null 2>&1; then
    "$ENGINE" build "${flags[@]}" -t osvr-fnd-base:1 -f "$ROOT/labs/shared/fnd-base/Dockerfile" "$ROOT/labs/shared/fnd-base"
  fi
  "$ENGINE" build "${flags[@]}" -t osvr-fnd03:1 -f "$HERE/Dockerfile" "$HERE"
} 2>&1 | tee "$LOG"
echo "build log: $LOG"
