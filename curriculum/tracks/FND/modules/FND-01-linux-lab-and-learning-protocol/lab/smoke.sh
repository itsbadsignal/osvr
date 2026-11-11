#!/bin/bash
# FND-01 smoke test. Default command of the osvr-fnd01:1 image.
# Compiles harness.c against the vulnerable and the fixed cJSON, runs both,
# and writes first-asan-report.txt, env.txt and control.txt to /out.
# Environment: LAB_CFLAGS overrides the default compiler flags (ambient CFLAGS is ignored).
set -u

OUT=${OUT:-/out}
unset CFLAGS
DEFAULT_CFLAGS="-g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined"
CFLAGS=${LAB_CFLAGS:-$DEFAULT_CFLAGS}
if [ -n "${LAB_CFLAGS:-}" ]; then echo "LAB_CFLAGS override in effect: $LAB_CFLAGS (check.sh grades only the default)" >&2; fi
HARNESS=/opt/lab/harness.c
BUILD=$(mktemp -d)

die() { echo "SMOKE FAIL: $*" >&2; exit 3; }

# /out must be a host directory mounted with -v, and writable by this user.
if ! mountpoint -q "$OUT" 2>/dev/null; then
    die "$OUT is not a mounted directory. Start the container with -v HOST_DIR:$OUT (otherwise anything written here vanishes with the container)."
fi
if ! touch "$OUT/.w" 2>/dev/null; then
    die "$OUT is mounted but not writable by uid $(id -u). Check the host directory's owner; rootless podman: do not pass --user, or add --userns=keep-id; Docker: pass --user \"\$(id -u):\$(id -g)\"."
fi
rm -f "$OUT/.w"

# LeakSanitizer is switched off: it is not the subject of this module, and its
# behaviour under Docker is untested (it works under rootless podman). The ASan
# error report is unaffected.
export ASAN_OPTIONS=detect_leaks=0

build_and_run() {   # $1 = source tree, $2 = binary name, $3 = stderr file
    local cc=(gcc $CFLAGS -I"$1" "$HARNESS" "$1/cJSON.c" -o "$BUILD/$2" -lm)
    echo "+ ${cc[*]}" >&2
    "${cc[@]}" || die "compile failed for $1"
    "$BUILD/$2" 2> "$3"
    return $?
}

echo "== vulnerable build (/src/cjson-vuln) =="
build_and_run /src/cjson-vuln harness-vuln "$OUT/first-asan-report.txt"
vuln_status=$?
cat "$OUT/first-asan-report.txt"
echo "vulnerable run exit status: $vuln_status"

echo "== fixed build, negative control (/src/cjson-fixed) =="
build_and_run /src/cjson-fixed harness-fixed "$BUILD/control.err"
ctl_status=$?
{ cat "$BUILD/control.err"; echo "control exit status: $ctl_status"; } > "$OUT/control.txt"
cat "$OUT/control.txt"

# Network evidence: list interfaces; a --network=none container has only lo.
nics=$(ls /sys/class/net | tr '\n' ' ' | sed 's/ $//')

{
    echo "base_image_digest=$(cat /etc/osvr-base-digest)"
    echo "gcc=$(gcc --version | head -1)"
    echo "cflags=$CFLAGS"
    echo "cjson_vuln_commit=$(git -C /src/cjson-vuln rev-parse HEAD)"
    echo "cjson_fixed_commit=$(git -C /src/cjson-fixed rev-parse HEAD)"
    echo "kernel=$(uname -r)"
    echo "randomize_va_space=$(cat /proc/sys/kernel/randomize_va_space)"
    echo "date=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "net_interfaces=$nics"
    echo "vuln_exit_status=$vuln_status"
    echo "control_exit_status=$ctl_status"
} > "$OUT/env.txt"
echo "== wrote $OUT/first-asan-report.txt, $OUT/env.txt, $OUT/control.txt =="
exit 0
