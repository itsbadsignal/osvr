#!/bin/bash
# Interactive FND-02 shell: no network, ~/osvr-work/fnd02 mounted at /work/fnd02, gdb can disable ASLR.
# Honours ENGINE, IMAGE (default osvr-fnd02:1), WORK (default ~/osvr-work/fnd02).
set -eu
ENGINE=${ENGINE:-$(command -v podman || command -v docker || true)}
[ -n "$ENGINE" ] || { echo "FAIL: no podman or docker on PATH" >&2; exit 1; }
IMAGE=${IMAGE:-osvr-fnd02:1}
WORK=${WORK:-$HOME/osvr-work/fnd02}
mkdir -p "$WORK"
# seccomp=unconfined: the default profile blocks personality(2), so gdb could not turn ASLR off.
# The container still has no network and no host files except the mount.
args=(--rm -it --network=none --cap-drop=ALL --security-opt seccomp=unconfined -v "$WORK:/work/fnd02")
case "$(basename "$ENGINE")" in
  docker) args+=(--user "$(id -u):$(id -g)" --cap-add=SYS_PTRACE) ;;   # rootless podman needs neither
esac
exec "$ENGINE" run "${args[@]}" "$IMAGE" "$@"
