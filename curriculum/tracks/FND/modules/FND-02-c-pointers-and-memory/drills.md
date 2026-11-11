# Drills: FND-02-c-pointers-and-memory

## Rate-determining step
Predicting where a C object lives and what writing past its end touches.

Every later skill rests on this prediction. Reading an ASan report (FND-03/04), seeing why a length check fails (FND-05), drawing a stack frame (FND-06), grooming a heap (BX): each assumes you can look at a declaration and an index and say which bytes move. Learners usually know the rules ("locals are on the stack") but cannot produce the *numbers* (offset, size, neighbour) quickly and correctly, and they do not check their guess against the machine. The research behind this track found pointers and the memory model ranked among the hardest topics for novices. That evidence came from search summaries, not full papers (`research/domain-maps/foundations.md`, Rate-determining steps), so treat it as a pilot hypothesis. The drills therefore all follow **predict in writing, then verify in the machine**.

All drills run inside `"$M/lab/run.sh"`, working in `/work/fnd02/drills/`. Start gdb as `gdb -q -nx` every time, so that the base image's GEF extension does not switch the output to hex or add its context pane (README, "gdb in this module").

**Fresh inputs.** "Owned when" asks for clean reps on *fresh* inputs. Drills 1, 2 and 4 each give a generator rule, so you or `/coach` can make a new item set for every rep. Do not repeat a set you have already seen the answers to.

## Drill 1: Where does it live?
Type: cognitive-component
Goal: classify objects by region instantly and correctly, including the cases that trip people up.
Setup: write a file `where.c` that declares all of the following, uses each once (so the compiler keeps it), and stops in `main` under gdb:
1. `int g1;`  2. `int g2 = 0;`  3. `int g3 = 5;`  4. `const int g4 = 5;`  5. `static char g5[64];`
6. `char *g6 = "abc";` (the pointer)  7. the bytes `"abc"`  8. `char g7[] = "abc";`
9. a local `int x;`  10. a local `static int y = 1;`  11. a local `char buf[16];`
12. the block from `malloc(32)`  13. the pointer holding it  14. the bytes of `argv[0]`  15. the code of `main`
Before compiling, write a region for each (`.text`, `.rodata`, `.data`, `.bss`, stack, heap, top of stack/kernel-placed). Then verify every one in gdb:

```text
$ gdb -q -nx ./where          # commands to type, not a measured transcript
(gdb) break main
(gdb) run
(gdb) info symbol &g3          # names the section for statics
(gdb) p g6                     # an address; info symbol g6 prints "No symbol matches" (a literal has no symbol), so find it with: info files
(gdb) p &x                     # compare with the [stack] line of: info proc mappings
```

<details><summary>Answer key for this set (open after verifying)</summary>

Measured on the lab image for the statics (audit run): 1, 2, 5 `.bss`. 3, 6, 8, 10 `.data`. 4 `.rodata`. 7 `.rodata`, found through `info files`. The rest follow from storage duration and are yours to confirm: 9, 11, 13 stack (`main`'s frame); 12 heap; 14 top of the stack region; 15 `.text`.
</details>

**Generator rule for fresh sets** (for you or `/coach`): 15 items, of which at least 5 are statics covering all three of zero-initialised, non-zero-initialised and `const`; at least one string literal *and* the pointer that holds it; one `char name[] = "..."` array; one local `static`; at least 3 automatics, including one whose address is never taken (so at `-O2` it may live in a register); one heap block; one item from `argv` or `environ`; one function. Vary the types (`long`, `double`, `struct`, arrays of pointers) and the initial values (`0`, `0.0`, `NULL`, `{0}`: each of these zero forms usually goes to `.bss`; confirm it).
Time target: 8 minutes for the 15 predictions (verification time is not counted).
Success check: 15/15 match gdb. Items 2, 4, 7 and 8 are the usual misses. Write one sentence for each miss explaining the rule you got wrong, and make a card from it.
Make it harder: rebuild with `-O2` and repeat for the locals (some live only in registers: gdb prints `<optimized out>`). Or predict the *order* of `g1`, `g2`, `g5` inside `.bss` and check with `p &g1` etc. Is the order guaranteed? (It is not; say why that matters for an overflow.)

## Drill 2: Draw the bytes, then call the report
Type: cognitive-component
Goal: from a declaration and an index, produce the exact ASan report fields and, without ASan, the neighbour that gets hit.
Setup: generate cases with this template, varying the bracketed parts each rep:

```c
/* case.c: [TYPE] in [REGION], [COUNT] elements, write at index [IDX] */
#include <stdlib.h>
#include <string.h>
[GLOBAL_DECL]
int main(void) {
    [LOCAL_OR_HEAP_DECL]
    [WRITE_STATEMENT]          /* e.g. a[IDX] = 1;  or  memset(a, 0, BYTES); */
    return 0;
}
```

Do at least 8 cases, mixing: `char` / `int` / `long` / `struct { int a; char b[3]; }`, stack / heap / global, index `COUNT` (off-by-one), `COUNT + 2`, `-1`, and a `memset` with a byte count one too large. For each, write before running:
- `kind`: `stack-buffer-overflow`, `heap-buffer-overflow`, `global-buffer-overflow`, or "no ASan report";
- `op` and `size`: READ or WRITE, and the access size;
- `offset` and `region`: where the bad access starts relative to the object, written as in the report (`0 bytes after`, `4 bytes before`, `2 bytes inside`), and the object's size in bytes. For a heap block, region is the "M-byte region". For a stack object, region is the size of its frame-object range: `[32, 48) 'scores'` gives `region: 16`, and the access at offset 48 is `offset: 0 bytes after`. For a global, region is the variable's size;
- `frame0`: **the first frame that is not a sanitizer interceptor or libc frame**, i.e. the first frame in your own source, written `function:line` (for example `main:19`). For `a[IDX] = 1` that is frame `#0`. For the `memset` case, frame `#0` is ASan's `memset` interceptor and frame0 is `main`;
- `alloc`: for heap, the allocating function:line; for a stack object or a global, the variable's name;
- for the non-ASan `-O0` build: which named object or which kind of slot (padding, canary, allocator slack) the bytes land on, checked with gdb `p &` and `x/`.

Then build twice and compare:

```sh
gcc -g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined case.c -o case.asan && ./case.asan
gcc -g -O0 case.c -o case && gdb -q -nx -ex 'break main' -ex run ./case
```

Write the prediction as `key: value` lines using the keys above (`kind`, `op`, `size`, `offset`, `region`, `frame0`, `alloc`), then run `/opt/osvr/fnd02/tools/predict-check pred.txt -- ./case.asan`. It compares field by field using the same frame0 definition. Its exit status is 0 if it found an ASan report, 1 if the run produced none (correct when you predicted "no ASan report"), and 2 on a usage error. Use it once you have written your prediction, never before. Expect a `-Wstringop-overflow` compile warning on the `memset` case even at `-O0`, and write your prediction before you read it.

**Generator rule for fresh cases:** draw TYPE from {`char`, `short`, `int`, `long`, a struct with padding}, REGION from {stack, heap, global}, COUNT from 3 to 40, and IDX from {COUNT, COUNT + 1, COUNT + 2, -1}. Replace one case in every eight with a `memset`/`memcpy` whose byte count is `COUNT * sizeof(TYPE) + 1`. Reject a draw if it repeats a (TYPE, REGION, IDX - COUNT) triple you have already done.
Time target: 3 minutes per case for the written prediction.
Success check: all ASan fields right on 8 consecutive cases. For the non-ASan column, a match on at least 6 of 8 counts as a pass: layout is compiler-chosen, and a wrong guess that you then explain from gdb output also counts as learning.
Make it harder: index `-1` on the heap (what is *before* a block?), a struct whose padding swallows the overflow (what does ASan say then, and why?), or a `long` array at an odd byte offset via a `char *` cast.

## Drill 3: One byte, four places (magnifying glass)
Type: magnifying-glass
Goal: spend 10x normal time on the single event this module is about, a one-byte write past the end, until you can say what it touches in every region.
Setup: two 50-minute sessions (one timebox each, per the session protocol). Session A: the stack and global cases (1 and 3) for all three N, plus the `char *` question below. Session B: the heap and struct cases (2 and 4), plus the "make it harder" sizes if time allows. Write four programs that each perform exactly `p[N] = '\0'` where `p` is:
1. a stack `char buf[N]`;
2. a heap `malloc(N)`;
3. a global `char gbuf[N]`;
4. the `buf` member of `struct { char buf[N]; int id; }` on the stack (start from `/opt/osvr/fnd02/src/intra.c`).

For N in {5, 16, 24}, record in a table: ASan result, UBSan result, and without sanitizers the value of the byte's neighbour before and after the write. Make the debugger stop at the write itself.

One trap first. The GDB manual says a `watch` watchpoint stops when the watched value is written **and changes**. Your program writes `'\0'`, and the byte past the end is very often already 0, so `watch` would never fire. Use an access watchpoint instead, `awatch` (hardware-assisted: it stops on any read or write of that byte, changed or not). Alternatively, set the byte to a non-zero value first so that a plain `watch` sees a change.

```text
$ gdb -q -nx ./case1          # commands to type, not a measured transcript
(gdb) break main
(gdb) run
(gdb) p &buf[N]
(gdb) x/2gx &buf[N]                  # before
(gdb) awatch -l *(char *)&buf[N]     # access watchpoint on that one byte
(gdb) continue                       # stops at the access; then x/2gx again
```

Alternative with `watch`: `set var *(char *)&buf[N] = 0x41` first, then `watch -l *(char *)&buf[N]`.

Then change case 4 so the write goes through a `char *q = r.buf;` and `q[N]`. Does UBSan still report it? Write down why or why not.
Time target: two 50-minute sessions for the whole table. There is no speed goal; depth is the point.
Success check: the table is complete (4 places x 3 sizes x 3 tools), every non-ASan cell has a before/after value from gdb, and you can explain each "no report" cell in one sentence. Bring it to `/coach` for one informational-feedback pass.
Make it harder: add N = 32 and N = 40 for the heap case and compare with `malloc_usable_size`. Predict for which N the byte lands on allocator metadata instead of slack.

## Drill 4: Fencepost spotting
Type: time-sliced (only the "find" phase of root-causing, on reading alone)
Goal: see the off-by-one in code you did not write, fast, by checking the size invariant instead of reading for "feel".
Setup: for each snippet, write **safe** or **bug**. For bugs, name the line, the inequality broken, and the input that triggers it. Assume `s` is any NUL-terminated string and other names are what they look like.

```c
/* A */ char *d = malloc(strlen(s)); strcpy(d, s);
/* B */ char buf[16]; snprintf(buf, sizeof buf, "%s", s);
/* C */ int a[n]; for (int i = 0; i < n; i++) a[i] = 0;
/* D */ char buf[8]; strncpy(buf, s, sizeof buf); puts(buf);
/* E */ char buf[32]; size_t len = read_line(fd, buf, sizeof buf); buf[len] = '\0';  /* returns bytes read, at most its 3rd arg */
/* F */ char *p = malloc(len + 1); memcpy(p, src, len); p[len] = '\0';
/* G */ int last = a[n];            /* a has n elements */
/* H */ for (int i = 1; i <= n; i++) sum += a[i - 1];
/* I */ char name[10]; if (strlen(s) > 10) return -1; strcpy(name, s);
/* J */ int *b = malloc(n * sizeof *b); for (int *q = b; q < b + n; q++) *q = 0;
/* K */ char out[4]; sprintf(out, "%d", x);        /* x is any int from -999 to 999 */
/* L */ void cp(char *dst, const char *src) { memcpy(dst, src, sizeof src); }   /* callers pass 16-byte buffers */
```

Time target: 6 minutes for all twelve.
Success check:

<details><summary>Answer key (open after attempting)</summary>

A bug: size `strlen(s)`, needs `strlen(s) + 1`; any `s`. B safe: `snprintf` truncates and terminates within `sizeof buf`. C safe. D bug: if `strlen(s) >= 8`, `strncpy` writes no NUL, so `puts` reads past `buf`. E bug: if `read_line` returns 32, `buf[32]` is one past the end; invariant `len + 1 <= 32` (the iperf3 shape). F safe. G bug: OOB **read** of `a[n]`; valid indices are `0..n-1`. H safe. I bug: the check allows `strlen(s) == 10`, and the copy then writes 11 bytes into 10. The check must be `>= 10`. J safe. K bug: `-999` prints 4 characters plus NUL, 5 bytes into 4. Safe only for `x` from -99 to 999. L bug, of a different kind: `sizeof src` is the pointer's size (8), not the string's length. It copies 8 bytes whatever the string is: too many if the string is shorter, too few if it is longer.

</details>

Pass: 12/12 with correct reasons in the time. A right verdict with a wrong reason is a miss.

**Second set** (use for rep 2; same rules, `n = strlen(s)` unless stated, `N` is a constant):

```c
/* M */ char *t = malloc(n + 1); for (size_t i = 0; i <= n; i++) t[i] = s[i];
/* N */ char buf[64]; memcpy(buf, s, strlen(s)); buf[strlen(s)] = '\0';
/* O */ int a[10]; for (int i = 10; i > 0; i--) a[i] = 0;
/* P */ char out[3]; out[0] = x; out[1] = y; out[2] = '\0';
/* Q */ char *c = malloc(n); memcpy(c, s, n); printf("%s\n", c);
/* R */ char buf[16]; char *p = buf + sizeof buf; *p = '\0';
/* S */ char buf[32]; if (len >= sizeof buf) return -1; memcpy(buf, src, len); buf[len] = '\0';
/* T */ char out[n]; for (size_t i = 0; i < n - 1; i++) out[i] = in[i]; out[n] = '\0';   /* n >= 1 */
/* U */ char *e = s + n; while (e > s && e[-1] == ' ') *--e = '\0';
/* V */ char path[256]; snprintf(path, sizeof path, "%s/%s", dir, name);
/* W */ char hex[2 * N]; for (int i = 0; i < N; i++) sprintf(hex + 2 * i, "%02x", b[i]);
/* X */ char dst[32] = "id="; strncat(dst, src, sizeof dst - strlen(dst));
```

<details><summary>Answer key, second set</summary>

M safe. N bug: needs `strlen(s) + 1 <= 64`, broken for `strlen(s) >= 64`. O bug: first write is `a[10]`, one past the end (and `a[0]` is never written). P safe. Q bug: `c` owns `n` bytes and has no NUL, so `%s` reads past the end (a READ, like the struggle challenge's wrong fix). R bug: `buf + sizeof buf` is the one-past-the-end pointer. Forming it is fine, writing through it is not. S safe: `len <= 31` after the check. T bug: `out[n]` with size `n`. U safe: writes only at indices below `n`. V safe: may truncate, cannot overflow. W bug: the last `sprintf` writes 2 digits plus a NUL at `hex[2N]`, one byte past. Needs `2 * N + 1`. X bug: `strncat` appends up to its count *and then* a NUL, so the count must be `sizeof dst - strlen(dst) - 1`.
</details>

**Generator rule** for `/coach` or a study partner: take each row of the README's off-by-one shapes table (allocation forgets the terminator, terminator at full length, `<=` bound, size passed as length) plus "pointer `sizeof`" and "formatted output wider than its buffer". Write one buggy and one correct variant of each, in a different context each time (copy, trim, encode, join, parse). Shuffle the 12 lines and write the answer key before handing them over.

Make it harder: write twelve new snippets yourself, six safe and six buggy, and swap with another learner (or give them to `/coach`). Or take any 30 lines of `src/iperf_auth.c` at the vulnerable commit and do the same, line by line.

## Drill 5: Diff to invariant, from memory
Type: copycat
Goal: proceduralise "read a fix diff, name the bug".
Setup: inside the lab, `cd /src/iperf && git show 4e5313bab0b9b3fe03513ab54f722c8a3e4b7bdf -- src/iperf_auth.c`. Rep 1: follow the project's root-cause steps with notes open. Reps 2 and 3, on later days: with the diff on screen and no notes, write the five root-cause fields (allocation line, write line, CWE, broken inequality, what the extra byte touches) in under 10 minutes. Then extend it to every other hunk in the same diff: for each, say in one line whether it is part of the memory-safety fix or hygiene, and why.
Time target: 10 minutes per rep for the five fields.
Success check: rep 3 matches your graded `rootcause.md` on all five fields, from memory.
Make it harder: hide the commit message and the file name. Use `git show --format= -U1` so you see minimal context.

## Owned when
3 consecutive clean reps under the time target, on fresh inputs, for Drills 1, 2 and 4, plus one completed Drill 3 table.
