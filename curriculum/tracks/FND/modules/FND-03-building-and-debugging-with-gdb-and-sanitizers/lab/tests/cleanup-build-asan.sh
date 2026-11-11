#!/bin/bash
# Fixture: correct build and verify, but deletes its work dir when verification fails.
# check.sh --health expects project mode to FAIL it (no build tree left under WORKDIR for the mutant run).
WORK=${2:-$(mktemp -d)}
bash "$(dirname "$0")/ref-build-asan.sh" "${1:-/src/cjson}" "$WORK"; rc=$?
[ $rc -eq 0 ] || rm -rf "$WORK"
exit $rc
