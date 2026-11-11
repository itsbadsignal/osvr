#!/bin/bash
# Host-side checker for the FND-01 lab. Exit 0 only if every check passes.
#
#   ./check.sh            grade YOUR artefacts in $OUT (default ~/osvr-work/fnd01/out):
#                         first-asan-report.txt, env.txt, control.txt. Read-only: it never
#                         deletes, regenerates or modifies them. Needs no container engine.
#   ./check.sh --health   lab self-test: runs the image once into a temp dir (removed
#                         afterwards) and grades that run. Never touches $OUT.
#
# Honours OUT, ENGINE, IMAGE (default osvr-fnd01:1; --health only).
# Ambient CFLAGS is ignored. Artefacts built with a non-default LAB_CFLAGS are not graded.
ENGINE=${ENGINE:-$(command -v podman || command -v docker || true)}
IMAGE=${IMAGE:-osvr-fnd01:1}
OUT=${OUT:-$HOME/osvr-work/fnd01/out}
VULN=87d8f0961a01bf09bef98ff89bae9fdec42181ee
FIXED=3ef4e4e730e5efd381be612df41e1ff3f5bb3c32
DEFAULT_CFLAGS="-g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined"
fails=0
pass() { echo "PASS  $*"; }
fail() { echo "FAIL  $*"; fails=$((fails+1)); }

grade() {   # $1 = directory holding the artefacts. Read-only.
  local D=$1 R=$1/first-asan-report.txt E=$1/env.txt C=$1/control.txt f uid st cf
  local missing=0
  for f in "$R" "$E" "$C"; do
    if [ -s "$f" ]; then pass "file: $(basename "$f") present"
    else fail "file: $(basename "$f") missing or empty in $D (run ./run.sh first; was /out mounted? a --user run under rootless podman leaves it empty)"; missing=1; fi
  done
  [ $missing = 1 ] && return
  for f in "$R" "$E" "$C"; do
    uid=$(stat -c %u "$f")
    [ "$uid" = "$(id -u)" ] && pass "owner: $(basename "$f") owned by you" \
      || fail "owner: $(basename "$f") owned by uid $uid, you are $(id -u) (rootless podman: do not pass --user; Docker: do)"
  done
  kv() { grep -m1 "^$1=" "$E" | cut -d= -f2-; }
  cf=$(kv cflags)
  if [ "$cf" != "$DEFAULT_CFLAGS" ]; then
    echo "NOTICE  env.txt shows non-default compiler flags: '$cf'"
    fail "flags: graded only with default LAB_CFLAGS (expected '$DEFAULT_CFLAGS'). Re-run ./run.sh without LAB_CFLAGS"
    return
  fi
  pass "flags: default LAB_CFLAGS"
  [ "$(kv net_interfaces)" = "lo" ] && pass "network: only loopback inside the run" \
    || fail "network: interfaces were '$(kv net_interfaces)', expected only lo (run with --network=none)"
  [ "$(kv cjson_vuln_commit)" = "$VULN" ] && pass "commit: vulnerable tree is the pinned commit" \
    || fail "commit: vulnerable tree is '$(kv cjson_vuln_commit)'"
  [ "$(kv cjson_fixed_commit)" = "$FIXED" ] && pass "commit: fixed tree is the pinned commit" \
    || fail "commit: fixed tree is '$(kv cjson_fixed_commit)'"
  st=$(kv vuln_exit_status)
  { [ -n "$st" ] && [ "$st" != 0 ]; } && pass "vulnerable run: exit status $st (non-zero)" \
    || fail "vulnerable run: exit status '$st' (expected non-zero)"
  if grep -q AddressSanitizer "$C"; then fail "control: fixed build produced an ASan report"
  elif [ "$(tail -n1 "$C")" = "control exit status: 0" ]; then pass "control: fixed build exits 0, no ASan output"
  else fail "control: fixed build did not exit 0 ($(tail -n1 "$C"))"; fi
  grep -q 'ERROR: AddressSanitizer: heap-buffer-overflow' "$R" && pass "report: heap-buffer-overflow error line" \
    || fail "report: no 'ERROR: AddressSanitizer: heap-buffer-overflow' line"
  grep -Eq '#[0-9]+ .*parse_string.* cJSON\.c:786|SUMMARY:.*cJSON\.c:786 in parse_string' "$R" && pass "report: cJSON.c:786 in parse_string" \
    || fail "report: no cJSON.c:786 in parse_string (built without -g? wrong tree?)"
  grep -Eq 'located [0-9]+ bytes .*7-byte region' "$R" && pass "report: 7-byte region" \
    || fail "report: no 'located N bytes ... 7-byte region' line"
}

finish() {
  if [ $fails -eq 0 ]; then echo "SUMMARY: all checks passed"; return 0; fi
  echo "SUMMARY: $fails check(s) failed"; return 1
}

if [ "${1:-}" = "--health" ]; then
  if [ -z "$ENGINE" ] || ! command -v "$ENGINE" >/dev/null; then
    fail "engine: no podman or docker on PATH (set ENGINE=)"; finish; echo "LAB HEALTH FAILED"; exit 1
  fi
  pass "engine: $ENGINE"
  if ! "$ENGINE" image inspect "$IMAGE" >/dev/null 2>&1; then
    fail "image: $IMAGE not found. Run ./build.sh"; finish; echo "LAB HEALTH FAILED"; exit 1
  fi
  pass "image: $IMAGE present"
  T=$(mktemp -d) || { echo "FAIL  cannot create temp dir"; exit 1; }
  log=$T.log
  trap 'rm -rf "$T" "$log"' EXIT
  args=(--rm --network=none -v "$T:/out")
  case "$(basename "$ENGINE")" in docker) args+=(--user "$(id -u):$(id -g)") ;; esac
  if timeout 120 "$ENGINE" run "${args[@]}" "$IMAGE" >"$log" 2>&1; then pass "run: container finished"
  else fail "run: container failed. Last lines: $(tail -n 3 "$log" | tr '\n' ' ')"; fi
  grade "$T"
  if finish; then echo "LAB HEALTH OK (temp dir removed; your $OUT was not touched)"; exit 0; fi
  echo "LAB HEALTH FAILED"; exit 1
elif [ $# -gt 0 ]; then
  echo "usage: $0 [--health]" >&2; exit 2
fi

echo "Grading $OUT (read-only)"
grade "$OUT"
finish
