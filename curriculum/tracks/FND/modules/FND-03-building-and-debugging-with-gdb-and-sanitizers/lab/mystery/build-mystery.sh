#!/bin/bash
# Build m1..m6 into $1 from mystery.c (run at image build time), then verify the facts
# the answer key relies on against the real artefacts. Writes $1/../.key (salted hashes).
set -eu
SRC=$(dirname "$0")/mystery.c; OUT=$1; mkdir -p "$OUT"; T=$(mktemp -d)
gcc -g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined "$SRC" -o "$OUT/m1"
gcc -g -O0 -c "$SRC" -o "$T/m2.o"; gcc -fsanitize=address "$T/m2.o" -o "$OUT/m2"
gcc -g -O0 -fsanitize=undefined "$SRC" -o "$OUT/m3"
gcc -O0 -fsanitize=address "$SRC" -o "$OUT/m4"
gcc -g -O0 "$SRC" -o "$OUT/m5"
gcc -g -O2 -fsanitize=address,undefined "$SRC" -o "$OUT/m6"; strip "$OUT/m6"
rm -rf "$T"
# key: name field value (the table in lab/SPEC.md)
key='m1 yes yes yes yes O0
m2 no yes no yes O0
m3 no no yes yes O0
m4 yes yes no no O0
m5 no no no yes O0
m6 yes yes yes no O2'
# sanity: measure each artefact and compare with the key
echo "$key" | while read -r n ac ar ub di op; do
  f=$OUT/$n
  m_ac=no; [ "$(nm -D "$f" | grep -c __asan_report)" -gt 0 ] && m_ac=yes
  m_ar=no; ldd "$f" | grep -q libasan && m_ar=yes
  m_ub=no; [ "$(nm -D "$f" | grep -c __ubsan_handle)" -gt 0 ] && m_ub=yes
  # .debug_info alone is not evidence: libasan's static preinit object carries its own DWARF.
  m_di=no; readelf --debug-dump=info "$f" 2>/dev/null | grep -q 'mystery\.c' && m_di=yes
  # main's address is the lea just before the call to __libc_start_main at the entry point
  e=$(readelf -h "$f" | awk '/Entry point/{print $4}')
  mt=$(objdump -d --no-show-raw-insn --start-address="$e" --stop-address=$((e+0x30)) "$f" | grep -m1 'lea.*(%rip)' | grep -o '# [0-9a-f]*' | cut -c3-)
  m_op=O2; objdump -d --no-show-raw-insn --start-address=0x"$mt" --stop-address=$((0x$mt+0x10)) "$f" | grep -q 'mov    %rsp,%rbp' && m_op=O0
  [ "$m_ac $m_ar $m_ub $m_di $m_op" = "$ac $ar $ub $di $op" ] || { echo "KEY MISMATCH $n: measured $m_ac $m_ar $m_ub $m_di $m_op, key $ac $ar $ub $di $op" >&2; exit 1; }
done
echo "$key" > "$OUT/../.key.plain"
