#!/bin/bash
# Host-side checker for FND-03. Needs a container engine (the grading runs inside osvr-fnd03:1).
#   ./check.sh challenge        grade ~/osvr-work/fnd03/cjson/build-asan and ~/osvr-work/fnd03/challenge
#   ./check.sh project          run ~/osvr-work/fnd03/project/build-asan.sh (twice, plus a mutant tree) and re-verify
#   ./check.sh --health         lab self-test with fixtures, in temp dirs inside a container; touches none of your files
# Honours ENGINE, IMAGE (default osvr-fnd03:1), WORK (default ~/osvr-work/fnd03), BUILD, CHALLENGE, SCRIPT
# (paths on the host under WORK; they are translated to /work/fnd03/...). Ambient CFLAGS is ignored.
# Your files are mounted READ-ONLY: nothing of yours is deleted, regenerated or modified.
MODE=${1:-}
ENGINE=${ENGINE:-$(command -v podman || command -v docker || true)}
IMAGE=${IMAGE:-osvr-fnd03:1}
WORK=${WORK:-$HOME/osvr-work/fnd03}
HERE=$(cd "$(dirname "$0")" && pwd)
case "$MODE" in challenge|project|--health) ;; *) echo "usage: $0 challenge|project|--health" >&2; exit 2;; esac
if [ -z "$ENGINE" ] || ! command -v "$ENGINE" >/dev/null; then echo "FAIL  engine: no podman or docker on PATH (set ENGINE=)"; exit 1; fi
if ! "$ENGINE" image inspect "$IMAGE" >/dev/null 2>&1; then echo "FAIL  image: $IMAGE not found. Run ./build.sh"; exit 1; fi
args=(--rm --network=none --cap-drop=ALL)
case "$(basename "$ENGINE")" in docker) args+=(--user "$(id -u):$(id -g)") ;; esac
tr_path() { case "$1" in "$WORK"/*) echo "/work/fnd03/${1#"$WORK"/}";; *) echo "$1";; esac; }
if [ "$MODE" = --health ]; then
  "$ENGINE" run "${args[@]}" -v "$HERE/tests:/lab-tests:ro" "$IMAGE" /opt/osvr/fnd03/tools/grade health /lab-tests
  rc=$?
  [ $rc = 0 ] && echo "LAB HEALTH OK (your files were not touched)" || echo "LAB HEALTH FAILED"
  exit $rc
fi
[ -d "$WORK" ] || { echo "FAIL  work dir: $WORK not found (run ./run.sh once)"; exit 1; }
args+=(-v "$WORK:/work/fnd03:ro")
if [ "$MODE" = challenge ]; then
  exec "$ENGINE" run "${args[@]}" "$IMAGE" /opt/osvr/fnd03/tools/grade challenge "$(tr_path "${BUILD:-$WORK/cjson/build-asan}")" "$(tr_path "${CHALLENGE:-$WORK/challenge}")"
else
  exec "$ENGINE" run "${args[@]}" "$IMAGE" /opt/osvr/fnd03/tools/grade project "$(tr_path "${SCRIPT:-$WORK/project/build-asan.sh}")"
fi
