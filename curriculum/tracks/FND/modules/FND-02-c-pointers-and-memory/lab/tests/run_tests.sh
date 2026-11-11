#!/bin/bash
# Host-side fixture test for check.sh.
#   repro:   good passes; same-function and empty-prediction fail.
#   modes:   an unknown mode prints a usage line and exits 2.
#   realbug: reference harness passes; a harness that never reaches the bug and one that reaches a different report fail.
#            Skipped (not failed) if osvr-fnd02-iperf:1 is absent (IPERF=1 ./build.sh).
d=$(cd "$(dirname "$0")" && pwd); rc=0
ENGINE=${ENGINE:-$(command -v podman || command -v docker || true)}
REPRO=$d/good/repro.c "$d/../check.sh" >/dev/null || { echo "FAIL: good fixture should pass"; rc=1; }
for f in samefn nopred; do REPRO=$d/$f/repro.c "$d/../check.sh" >/dev/null && { echo "FAIL: $f should fail"; rc=1; }; done
out=$("$d/../check.sh" reprro 2>&1); st=$?
{ [ "$st" = 2 ] && echo "$out" | grep -q '^usage: check.sh \[repro|hardening|realbug\]$'; } || { echo "FAIL: unknown mode should print usage and exit 2 (got $st: $out)"; rc=1; }
if "$ENGINE" image inspect osvr-fnd02-iperf:1 >/dev/null 2>&1; then
  WORK=$d/realbug/good "$d/../check.sh" realbug >/dev/null || { echo "FAIL: realbug good fixture should pass"; rc=1; }
  for f in noop other; do WORK=$d/realbug/$f "$d/../check.sh" realbug >/dev/null && { echo "FAIL: realbug $f should fail"; rc=1; }; done
  WORK=$d/realbug/missing "$d/../check.sh" realbug >/dev/null && { echo "FAIL: realbug without harness.c should fail"; rc=1; }
else
  echo "SKIP: osvr-fnd02-iperf:1 not built; realbug fixtures not run"
fi
[ $rc = 0 ] && echo "check.sh fixtures OK"; exit $rc
