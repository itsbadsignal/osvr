#!/bin/sh
# Fixture test: session-pass.md must exit 0; every session-fail*.md and the unfilled
# template must exit exactly 1 (exit 2 = usage/IO error is also a test failure).
d=$(cd "$(dirname "$0")" && pwd); c="$d/../check_session.py"; rc=0
python3 -I "$c" "$d/session-pass.md" >/dev/null || { echo "FAIL: session-pass.md should pass"; rc=1; }
for f in "$d"/session-fail*.md "$d"/session-template-unfilled.md; do
  [ -f "$f" ] || { echo "FAIL: missing fixture $f"; rc=1; continue; }
  python3 -I "$c" "$f" >/dev/null; s=$?
  [ $s = 1 ] || { echo "FAIL: $(basename "$f") should exit 1, got $s"; rc=1; }
done
# Concrete next actions must still pass.
t=$(mktemp); sed 's/^Run: .*/Continue: fix the owner check in check.sh and rerun it/' "$d/session-pass.md" > "$t"
python3 -I "$c" "$t" >/dev/null || { echo "FAIL: concrete 'Continue: ... check.sh' should pass"; rc=1; }
rm -f "$t"
[ $rc = 0 ] && echo "check_session tests OK"; exit $rc
