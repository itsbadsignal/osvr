#!/bin/bash
# Remove lab outputs and images. Honours ENGINE, OUT. Use FULL=1 to also remove the base image
# and prune dangling images (podman image prune -f; Docker: docker image prune -f, UNTESTED;
# docker builder prune also frees build cache, UNTESTED, not run here).
set -u
ENGINE=${ENGINE:-$(command -v podman || command -v docker || true)}
OUT=${OUT:-$HOME/osvr-work/fnd01/out}
rm -f "$OUT/first-asan-report.txt" "$OUT/env.txt" "$OUT/control.txt"
[ -n "$ENGINE" ] || exit 0
"$ENGINE" rmi osvr-fnd01:1 2>/dev/null
msg="outputs removed from $OUT; image osvr-fnd01:1 removed"
if [ "${FULL:-0}" = 1 ]; then
  "$ENGINE" rmi osvr-fnd-base:1 2>/dev/null
  "$ENGINE" image prune -f >/dev/null 2>&1
  if "$ENGINE" image inspect osvr-fnd-base:1 >/dev/null 2>&1; then
    msg="$msg, base image NOT removed (another image, e.g. FND-02, still uses it), dangling images pruned"
  else
    msg="$msg, base image removed, dangling images pruned"
  fi
fi
echo "reset done ($msg)"
exit 0
