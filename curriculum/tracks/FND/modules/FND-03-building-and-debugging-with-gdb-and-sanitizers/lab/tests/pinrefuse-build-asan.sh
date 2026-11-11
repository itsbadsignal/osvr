#!/bin/bash
# Fixture: a script that refuses a modified SRC in its pin stage (exits non-zero before building).
# check.sh --health expects check.sh project to FAIL it: the verify stage never ran on the mutant.
SRC=${1:-/src/cjson}
if grep -q 'fno-sanitize=address' "$SRC/CMakeLists.txt"; then
  echo "pin: SRC differs from the pinned tree, refusing" >&2; exit 1
fi
exec bash "$(dirname "$0")/ref-build-asan.sh" "$@"
