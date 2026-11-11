#!/bin/bash
# Build osvr-fnd-base:1. Honours ENGINE (default: podman, else docker).
# NO_CACHE=1 passes --no-cache. The log is tee'd to
# ~/osvr-work/fnd01/build-logs/build-base-<UTC timestamp>.log and the path is printed.
# An uncached podman log contains no "Using cache" lines (Docker: "CACHED", UNTESTED).
set -eu
set -o pipefail
ENGINE=${ENGINE:-$(command -v podman || command -v docker || true)}
[ -n "$ENGINE" ] || { echo "FAIL: no podman or docker on PATH" >&2; exit 1; }
cd "$(dirname "$0")"
LOGDIR=$HOME/osvr-work/fnd01/build-logs
mkdir -p "$LOGDIR"
LOG=$LOGDIR/build-base-$(date -u +%Y%m%dT%H%M%SZ).log
flags=()
[ "${NO_CACHE:-0}" = 1 ] && flags+=(--no-cache)
echo "build log: $LOG"
"$ENGINE" build "${flags[@]}" -t osvr-fnd-base:1 -f Dockerfile . 2>&1 | tee "$LOG"
echo "build log: $LOG"
