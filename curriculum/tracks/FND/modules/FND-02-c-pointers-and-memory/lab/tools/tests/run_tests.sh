#!/bin/sh
# Fixture test for predict-check (run inside the image). Builds four programs with ASan and asserts,
# for each, the exit code and the number of matching / differing fields for a correct and a wrong prediction.
#   heap (upper.c), stack (scores.c), global (global.c), interceptor (memsetov.c: the access is inside memset)
d=$(cd "$(dirname "$0")" && pwd); t=$(mktemp -d); rc=0
pc="$d/../predict-check"
export ASAN_OPTIONS=detect_leaks=0
build() { gcc -g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined "$1" -o "$t/$2" || exit 1; }
build /opt/osvr/fnd02/src/upper.c upper
build /opt/osvr/fnd02/src/scores.c scores
build "$d/global.c" global
build "$d/memsetov.c" memsetov

# expect NAME PRED BIN MATCHES DIFFERS : predict-check must exit 0 and print exactly that many match / differ lines
expect() {
    out=$("$pc" "$d/$2" -- "$t/$3"); st=$?
    m=$(echo "$out" | grep -c ' match$'); df=$(echo "$out" | grep -c ' differ$')
    if [ "$st" = 0 ] && [ "$m" = "$4" ] && [ "$df" = "$5" ]; then echo "ok    $1 (exit $st, $m match, $df differ)"
    else echo "$out"; echo "FAIL  $1: exit $st, $m match, $df differ; wanted exit 0, $4 match, $5 differ"; rc=1; fi
}
expect "heap correct"        upper-correct.pred  upper    7 0
expect "heap wrong"          upper-wrong.pred    upper    4 3   # op, region, frame0
expect "stack correct"       scores-correct.pred scores   7 0
expect "stack wrong"         scores-wrong.pred   scores   4 3   # kind, region, alloc
expect "global correct"      global-correct.pred global   7 0
expect "global wrong"        global-wrong.pred   global   4 3   # op, offset, region
expect "interceptor correct" memset-correct.pred memsetov 7 0
expect "interceptor wrong"   memset-wrong.pred   memsetov 6 1   # frame0 named the interceptor

# exit codes other than 0
"$pc" "$d/upper-correct.pred" -- true >/dev/null; st=$?
[ "$st" = 1 ] && echo "ok    no report: exit 1" || { echo "FAIL  no ASan report should exit 1, got $st"; rc=1; }
"$pc" >/dev/null 2>&1; st=$?
[ "$st" = 2 ] && echo "ok    usage error: exit 2" || { echo "FAIL  usage error should exit 2, got $st"; rc=1; }
"$pc" --help | grep -q 'first frame that is not a sanitizer interceptor or libc frame'; st=$?
[ "$st" = 0 ] && echo "ok    --help states the frame0 rule" || { echo "FAIL  --help lacks the frame0 rule"; rc=1; }
rm -rf "$t"; [ $rc = 0 ] && echo "predict-check tests OK"; exit $rc
