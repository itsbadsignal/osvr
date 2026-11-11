#!/bin/bash
# Fixture: patches the mutation out of its own copy of SRC, so its build legitimately has ASan and it exits 0.
# check.sh --health expects project mode to PASS it (N8: accepting is right when the build is instrumented).
SRC=${1:-/src/cjson}; WORK=${2:-$(mktemp -d)}
mkdir -p "$WORK"; rm -rf "$WORK/pinned"; cp -a "$SRC" "$WORK/pinned"; chmod -R u+w "$WORK/pinned"
sed -i '/^add_compile_options(-fno-sanitize=address)$/d' "$WORK/pinned/CMakeLists.txt"
exec bash "$(dirname "$0")/ref-build-asan.sh" "$WORK/pinned" "$WORK"
