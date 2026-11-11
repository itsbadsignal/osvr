#!/bin/bash
# Fixture with a deliberately weak verify stage (checks only that a sanitizer runtime is linked). check.sh --health expects it to be rejected.
# Usage: ref-build-asan.sh [SRC] [WORKDIR]. Prints BUILD_DIR=<path> as its last line.
set -eu
SRC=${1:-/src/cjson}; WORK=${2:-$(mktemp -d)}
# pin
mkdir -p "$WORK"; rm -rf "$WORK/src"; cp -a "$SRC" "$WORK/src"; chmod -R u+w "$WORK/src"; rm -rf "$WORK/src/build-asan"
B=$WORK/src/build-asan
# configure
cmake -S "$WORK/src" -B "$B" -DCMAKE_BUILD_TYPE=Debug -DENABLE_CJSON_TEST=ON -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
  -DCMAKE_C_FLAGS="-g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined -fno-sanitize-recover=undefined" >/dev/null
# build
cmake --build "$B" -j4 >/dev/null
# verify: every ctest executable and libcjson, instrumentation (nm -D) and runtime (ldd)
bad=0
bins=$(cd "$B" && ctest --show-only=json-v1 | python3 -c 'import json,sys; [print(t["command"][0]) for t in json.load(sys.stdin)["tests"]]')
for f in $bins $(ls "$B"/libcjson.so.*.* 2>/dev/null | head -1); do
  case $f in /*) p=$f ;; *) p=$B/tests/$f ;; esac
  a=$(nm -D "$p" | grep -c __asan_report || true); u=$(nm -D "$p" | grep -c __ubsan_handle || true)
  r=$(ldd "$p" | grep -cE 'libasan|libubsan' || true)
  echo "$(basename "$p") asan_report=$a ubsan_handle=$u runtimes=$r"
  { [ "$r" -ge 1 ]; } || bad=1   # WEAK: only checks that a runtime is linked
done
[ "$bad" = 0 ] || { echo "VERIFY FAILED: missing instrumentation or runtime" >&2; exit 1; }
# test
(cd "$B" && ctest --output-on-failure | tail -3)
echo "BUILD_DIR=$B"
