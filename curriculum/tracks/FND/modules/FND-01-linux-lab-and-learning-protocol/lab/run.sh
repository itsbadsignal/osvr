#!/bin/bash
# Run the smoke test with no network; results go to $OUT (default ~/osvr-work/fnd01/out).
# Honours ENGINE, IMAGE, OUT, LAB_CFLAGS (ambient CFLAGS is ignored).
set -eu
ENGINE=${ENGINE:-$(command -v podman || command -v docker || true)}
[ -n "$ENGINE" ] || { echo "FAIL: no podman or docker on PATH" >&2; exit 1; }
IMAGE=${IMAGE:-osvr-fnd01:1}
OUT=${OUT:-$HOME/osvr-work/fnd01/out}
mkdir -p "$OUT"
args=(--rm --network=none -v "$OUT:/out")
case "$(basename "$ENGINE")" in
  docker) args+=(--user "$(id -u):$(id -g)") ;;   # rootless podman needs no --user: root maps to you
esac
if [ -n "${LAB_CFLAGS:-}" ]; then
  echo "LAB_CFLAGS override in effect: $LAB_CFLAGS (check.sh will FAIL such outputs: graded only with default LAB_CFLAGS)" >&2
  args+=(-e "LAB_CFLAGS=$LAB_CFLAGS")
fi
exec "$ENGINE" run "${args[@]}" "$IMAGE"
