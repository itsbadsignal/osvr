# FND-02-c-pointers-and-memory: C I: pointers, arrays, strings and where objects live

Track: FND   Hours: 18   Prereqs: FND-01-linux-lab-and-learning-protocol (and a pass on the programming diagnostic, or FND-00)   Status: drafting
Outcomes: rootcause

This module teaches C's memory model as a vulnerability researcher needs it. The question for every object is the same: where does it live, how big is it, and what sits right after it? You learn this on small programs you can hold in your head. Then you apply it to a real bug: the iperf3 off-by-one heap overflow CVE-2025-54349, which you root-cause from its fix commit, reproduce as a pattern in your own program under AddressSanitizer, and then trigger in iperf's real code with a short harness of your own.

Hour budget (pilot parameter): about 1 h prerequisite check and C syntax, 2 h worked example, 1 h struggle challenge, 3 h theory, 5 h drills, 6 h project.

Conventions from FND-01 carry over. Set these once per terminal, from the repo root:

```sh
M=curriculum/tracks/FND/modules/FND-02-c-pointers-and-memory
ENGINE=$(command -v podman || command -v docker)
mkdir -p ~/osvr-work/fnd02
```

The lab image is `osvr-fnd02:1`, built `FROM osvr-fnd-base:1` (the shared FND base image from FND-01). The image's toolchain is gcc 14.2.0 and glibc 2.41 (Debian 13). Every output quoted in this module was measured on that image. Build and enter it:

```sh
"$M/lab/build.sh"   # builds osvr-fnd-base:1 if it is missing, then osvr-fnd02:1
"$M/lab/run.sh"     # interactive shell, no network, ~/osvr-work/fnd02 mounted at /work/fnd02
```

A plain `build.sh` reuses cached layers. For a genuinely clean rebuild of the FND-02 images, run `NO_CACHE=1 "$M/lab/build.sh"`. That does not rebuild the shared base; add `BASE=1` for that too.

Inside the container, the exercise sources are in `/opt/osvr/fnd02/src/` (the same files as `$M/lab/src/`) and the iperf3 source is in `/src/iperf`. Work in `/work/fnd02`: files there survive the container.

**gdb in this module: always `gdb -q -nx`.** The base image loads the GEF extension into every gdb session. GEF switches gdb's number radix to 16 (so `p sizeof scores` prints `0x10` instead of `16`) and prints a large context pane at every stop. Both are useful later and FND-03 introduces GEF properly. Here they would make your output differ from every transcript in this module, so start gdb with `-nx` ("do not run any init file"). Every gdb transcript below was produced with exactly the command shown above it.

**gdb and the container.** Under rootless podman, gdb needs no extra capabilities. The engine's default seccomp profile, however, blocks the `personality` system call that gdb uses to turn off address randomisation. Without it, gdb prints `Error disabling address space randomization: Function not implemented` and your addresses change on every run. `run.sh` passes `--security-opt seccomp=unconfined` (and `--cap-drop=ALL`) for this reason. If you start the container by hand, add that flag yourself.

> needs-lab-verification: Docker. The lab was verified on rootless podman only. `run.sh` has a Docker code path (adds `--user` and `--cap-add=SYS_PTRACE`) that nobody has run yet. If you use Docker, report what happens to `/coach` so it can be logged.

## Objectives
After this module you can:
1. Classify any C object (global, `static`, local, heap block, string literal, the bytes behind `argv`) by storage region, and confirm each answer in gdb with `info symbol`, `info files` or `info proc mappings`.
2. Compute `sizeof`, element addresses and pointer differences for arrays and pointers, including array-to-pointer decay in function parameters, and check every number with gdb `p` and `x/`.
3. State the size invariant a C string buffer must keep (`size >= length + 1`) and find, in unfamiliar code, the line that breaks it.
4. Predict an ASan report for an out-of-bounds write before running it: error kind, READ or WRITE, access size, "N bytes after M-byte region", the access frame and the allocation frame.
5. Root-cause iperf3 CVE-2025-54349 from its fix commit (allocation line, write line, CWE, broken invariant, what the extra byte lands on), then trigger it in the real `decode_auth_setting` under ASan at the vulnerable commit and show it is gone at the fix.
6. Build one program both weak on purpose and with default flags, and report from `readelf` which of PIE, NX, RELRO, BIND_NOW and the stack canary each build has.

## Where this shows up in the wild
- **iperf3 CVE-2025-54349** (GHSA-8xx8-qrh3-q8mq; MITRE record, CWE-193 off-by-one): `decrypt_rsa_message` in `src/iperf_auth.c` allocates `keysize` bytes for the decrypted text, and the caller then writes `plaintext[plaintext_len] = '\0'` with `plaintext_len == keysize`. Fix commit `4e5313bab0b9b3fe03513ab54f722c8a3e4b7bdf`, "Fix off-by-one heap overflow in auth". This is your project.
- **sudo CVE-2021-3156 "Baron Samedit"**: a heap overflow in `set_cmnd()`. According to the Qualys advisory, the backslash-unescaping loop reads past an argument's terminating NUL into the bytes that follow. NVD classifies it CWE-193. The sudo alert lists 1.7.7 to 1.7.10p9, 1.8.2 to 1.8.31p2 and 1.9.0 to 1.9.5p1 as affected, and the Qualys advisory describes three exploits. A fencepost error in string handling is not a small bug.
- **The `poison_null_byte` technique** is still listed as working on the current glibc in how2heap (`research/domain-maps/glibc-userland-exploitation.md`). It turns a single overflowing NUL byte on the heap into overlapping allocations. You build it in the BX track. Here, just note that one byte past the end has been enough for real exploits.

## Mitigation context
FND-02 exploits nothing. You still need to know what is switched on, because it changes what an out-of-bounds write *does*, and because "default" means different things on different toolchains. The lab's gcc turns some protections on by default and leaves others off, and other distributions choose differently.

| Mitigation / mechanism | On in this module? | What it blocks | How this module deals with it |
|---|---|---|---|
| AddressSanitizer (ASan) | Yes, in every `-fsanitize=address` build | Nothing. It is a detection tool: it stops the program at the first bad heap, stack or global access it can see and prints a report (Clang ASan docs). It is not for production | You predict its report, then run it. You also learn its blind spots (intra-object overflow, accesses the run never makes) |
| UBSan (`-fsanitize=undefined`) | Yes, with ASan | Detection only. Its `bounds` check flags indexing past a known array size, including inside a struct, where ASan is silent (measured on the lab image with `intra.c`) | Theory, *Sanitizer blind spots*, and project variation 3 |
| Stack protector (canary) | Off by default in the lab (the image's gcc reports `-fstack-protector-strong [disabled]`). Enable it with `-fstack-protector-strong` | Detects a contiguous overwrite that reaches the canary when the function returns, then aborts (`__stack_chk_fail`). It does not stop overwrites of other locals that sit before the canary | Worked example Subgoal 3 builds a third variant with `-fstack-protector-strong` to show the canary in the frame and the abort. The default and weak builds have none |
| PIE + ASLR | PIE: yes, the lab's gcc is configured `--enable-default-pie`. ASLR is the host kernel's setting | Randomises where the program, heap, stack and libraries load | gdb turns randomisation off for programs it starts, if seccomp allows it (see above; check with `show disable-randomization`). Compare by offset and region, never by absolute address |
| NX (non-executable stack) | Yes, by default | Stops executing injected bytes on the stack | Read the `GNU_STACK` flags with `readelf -lW` |
| RELRO / BIND_NOW | Partial RELRO in the lab's default build (`GNU_RELRO` present, no `BIND_NOW`). None in the weak build | Makes relocation data read-only after load | Read with `readelf -lW` and `readelf -d`. Full detail in FND-07 |
| `_FORTIFY_SOURCE` | Off in all FND-02 builds (not a default of the lab's bare gcc; weak builds also say so explicitly) | Adds bounds checks to some libc calls when the size is known at compile time | Incompatible with sanitizers (OpenSSF hardening guide), and it needs `-O1` or higher. Weak builds pass `-D_FORTIFY_SOURCE=0` explicitly |
| glibc `malloc` size rounding and checks at `free` | Always, in non-ASan builds | Not a mitigation. `malloc` hands out more usable bytes than you asked for, so a one-byte heap overflow often lands in unused slack and nothing visible happens. When it does hit allocator metadata, glibc may abort at a later `free`, or may never notice | Why you need ASan to see these bugs. Project variation 2 measures both cases |
| Other gcc hardening (stack-clash protection, CET `-fcf-protection`) | Stack-clash protection: off in the lab's gcc. `-Q --help=common` shows `-fcf-protection=full` | Not relevant to an out-of-bounds data write | Listed so that you can recognise the flags. Not used further |

Defaults differ by distro and version, and this is a concrete trap. The lab's bare gcc (Debian 13) gives PIE, NX and partial RELRO, and no stack protector, no BIND_NOW and no stack-clash protection (`gcc -v` lists `--enable-default-pie` and no other `--enable-default-*` option; `lab/SPEC.md`, Implementation notes). Debian's `dpkg-buildflags` page documents the strong stack protector as a default for *package* builds. Packages built through that tooling get it, while the bare compiler you type `gcc` into does not. On Arch, by contrast, the bare `gcc` was observed to enable the strong stack protector by default (`research/domain-maps/foundations.md`, Mitigation landscape). A tutorial written on one machine can be wrong on yours. So you check your own binaries, and Subgoal 6 of the worked example shows how.

## Prerequisite check
**Gate first.** FND-02 assumes you can write and debug a small program in some language. If you have not done so yet, take the programming diagnostic: `curriculum/tracks/FND/modules/FND-00-programming-on-ramp/diagnostic.md` (90 minutes, any language; DR-0005). If that file is not there yet, run `/coach` and ask for the FND-00 diagnostic. Fail it and you do FND-00 first. Pass it in a language other than C and you read *C syntax for programmers of another language* at the top of the worked example before anything else.

Then, closed-book, under 10 minutes:

1. From the repo root, start the FND-01 lab image with no network and your `~/osvr-work/fnd02` directory mounted at `/work/fnd02`. Write one command.
2. Without running it, what does this print?
   ```c
   int a[5] = {3, 1, 4, 1, 5};
   int t = 0;
   for (int i = 1; i < 5; i += 2) t += a[i];
   printf("%d\n", t);
   ```
3. What is the difference between compiling with `-g` and without it, as far as a crash report is concerned?
4. In one sentence: what does `char *p` declare, and what does `*p` give you?
5. Which three fields of an ASan report do you copy before anything else (FND-01)?

<details><summary>Answer key (open after attempting)</summary>

1. `"$ENGINE" run --rm -it --network=none -v ~/osvr-work/fnd02:/work/fnd02 osvr-fnd-base:1` (`osvr-fnd01:1` also passes; `-it` only matters for an interactive shell).
2. `2`: `i` takes 1 and 3, and `a[1] + a[3]` is `1 + 1`.
3. `-g` adds debug information that maps machine addresses back to file:line and variable names. Without it a report shows only addresses and function names.
4. `p` holds the address of a `char`. `*p` is the `char` stored at that address.
5. The ERROR line (error kind), the first frame in project code with file:line, and the allocation (or free) site.

**Route.** All five correct **and** you have used C pointers before **and** you have read an ASan report for your own bug: go straight to the struggle challenge. Otherwise study the worked example first. That route is the default.
</details>

## Worked example
**Instance:** `scores.c`, an `int` array on the **stack** written one element too far by a `<=` loop. The struggle challenge uses a different program, a different region (the heap) and a different off-by-one shape. Read every subgoal and type every command yourself.

### C syntax for programmers of another language
Read this if you passed the diagnostic in Python, Java, JavaScript, Go or similar. It covers only what this module uses. C has few keywords. The traps are in what the language does *not* do for you.

| You know (Python / Java) | In C | What bites |
|---|---|---|
| `x = 5` (Python) | `int x = 5;` | Every variable has a declared type and a fixed size. Statements end in `;`. Blocks use `{ }`, and indentation means nothing |
| `def f(a, b): ...` | `int f(int a, int b) { ... }` | Return type first. `void` means "returns nothing". A function must be declared before use (or `#include` its header) |
| `import x` | `#include <stdio.h>` | Text inclusion by the preprocessor, not a module system |
| `list` / `ArrayList` | `int a[4];` | Fixed size, set at declaration. **No bounds checking.** `a[4]` compiles and runs and touches whatever is next in memory |
| `str` / `String` | `char s[8] = "hi";` | A string is bytes ending in a `'\0'` (NUL) byte. Its length is not stored anywhere. `strlen` walks to the NUL |
| references to objects | `int *p = &x;` | `&x` is the address of `x`. `*p` reads or writes what `p` points to. A pointer is just an address with a type. Nothing stops it from pointing at garbage |
| `len(a)` | `sizeof a / sizeof a[0]` | Works only where `a` is a real array. Inside a function that received `a` as a parameter, `a` is a pointer and `sizeof a` is 8 |
| garbage collection | `p = malloc(n); ... free(p);` | You allocate and free by hand. `malloc` returns uninitialised bytes, or `NULL` on failure |
| `print(f"{x}")` | `printf("%d %zu %s %p\n", i, sz, str, (void *)ptr);` | Format must match the type: `%d` int, `%zu` `size_t`, `%s` NUL-terminated string, `%p` pointer (cast to `void *`) |
| exceptions | return codes, `errno` | Errors are values you must check. A bad memory access may crash, or may silently corrupt something |
| `python3 x.py` | `gcc -Wall -Wextra -g x.c -o x && ./x` | Compile, then run. Read every warning: `-Wall -Wextra` catch many bugs for free |

`size_t` is the unsigned integer type for sizes and lengths (`strlen` returns it). `static` on a global or function means "visible only in this file". On a local variable it means "lives for the whole program, not just this call". `const char *p` means you may not write through `p`. Mixing signed and unsigned integers is the subject of FND-05. Here, just use `size_t` for lengths.

### Subgoal 1. Locate: which region holds each object?
Goal: before running anything, write down where every object in the program lives.

```c
#include <stdio.h>

int total_runs = 0;                 /* global, initialised      */

static int sum(const int *v, int n) /* v is a pointer, not an array */
{
    int s = 0;
    for (int i = 0; i < n; i++)
        s += v[i];
    return s;
}

int main(void)
{
    int scores[4];
    int bonus = 7;

    for (int i = 0; i <= 4; i++)    /* runs for i = 0, 1, 2, 3, 4 */
        scores[i] = 10 * i;

    total_runs++;
    printf("sum=%d bonus=%d runs=%d\n", sum(scores, 4), bonus, total_runs);
    return 0;
}
```

(`/opt/osvr/fnd02/src/scores.c` in the lab.) Written prediction:

| Object | Region | Why |
|---|---|---|
| `total_runs` | static storage, `.bss` | gcc places a global whose initial value is zero in `.bss`, the section elf(5) describes as zero-filled at program start. "Initialised" does not mean `.data` when the value is 0. Subgoal 2 checks it |
| `scores`, `bonus`, `i` | stack, `main`'s frame | Automatic (local) variables live in the current function's frame (N1570 6.2.4: lifetime from block entry to block exit) |
| `v`, `n`, `s` in `sum` | stack, `sum`'s frame (or registers) | Parameters are locals too. `v` holds the *address* of `scores`, not a copy of it |
| the code of `main` and `sum` | `.text` | Machine code, mapped read and execute |
| the format string `"sum=%d ..."` | `.rodata` | String literals are read-only static data |

The C standard defines storage *durations* (static, automatic, allocated). Which ELF *section* a given variable lands in is the compiler's choice, and elf(5) only defines what each section is. So the section column is a prediction you confirm with `info symbol`, never a rule you quote.

### Subgoal 2. Measure: sizes and addresses
Goal: turn the table into numbers you have checked. Build a debug binary *without* sanitizers first, so you see the real layout:

```sh
cd /work/fnd02 && cp /opt/osvr/fnd02/src/*.c .
gcc -g -O0 -Wall -Wextra scores.c -o scores
gdb -q -nx ./scores
```

```text
(gdb) break 21
(gdb) run
(gdb) p sizeof scores
$1 = 16
(gdb) p sizeof scores[0]
$2 = 4
(gdb) p &scores
$3 = (int (*)[4]) 0x7fffffffeb80
(gdb) p &scores[4]
$4 = (int *) 0x7fffffffeb90
(gdb) p &bonus
$5 = (int *) 0x7fffffffeb98
(gdb) p (char *)&bonus - (char *)scores
$6 = 24
(gdb) p (char *)$rbp - (char *)scores
$7 = 48
(gdb) info symbol &total_runs
total_runs in section .bss of /work/fnd02/scores
```

**Compare offsets, not addresses.** The absolute stack addresses depend on the environment variables and arguments the program starts with, so they shift between machines, shells and runs, even with ASLR off. A second run on the same image gave `&scores = 0x7fffffffeb90` and `$rbp = 0x7fffffffebc0`. The offsets did not change: `bonus` at `scores + 24`, `$rbp` at `scores + 48`. Write your notes as offsets from `scores`. This module does the same from here on, writing `S` for `&scores`.

Read the numbers. `&scores[4]` is `S + 16`: pointer arithmetic moves by `sizeof(int)` per step, so index 4 is 4 x 4 bytes in. That address is one past the end. The array owns bytes `S` to `S + 15`. `bonus` is at `S + 24`: **above** the array, 8 bytes past its end. The overflow is heading towards it.

### Subgoal 3. Predict: what does `scores[4] = 40` touch?
Goal: name the bytes the bad write lands on, before you look.

`scores[4]` is the 4 bytes at `S + 16` to `S + 19`. No variable you declared starts there, so look at the memory itself (same session):

```text
(gdb) x/8wx scores
0x7fffffffeb80:	0x00000000	0x0000000a	0x00000014	0x0000001e
0x7fffffffeb90:	0x00000028	0x00000000	0x00000007	0x00000005
```

Read it word by word. `0x28` is 40, the value `scores[4] = 10 * 4` wrote, sitting in an 8-byte gap that no variable uses (`S + 16` to `S + 23`). `7` at `S + 24` is `bonus`. `5` at `S + 28` is the loop variable `i`, left at 5 after the loop ended. Further up, at `$rbp` (`S + 48`), come the saved frame pointer and then the return address. There is **no canary** in this frame: the lab's gcc does not enable the stack protector by default (Subgoal 6 proves it from the binary).

So the prediction for each loop bound, without sanitizers:

| Loop bound | Last write | Lands on | Measured result in the lab |
|---|---|---|---|
| `i <= 4` | `scores[4]` | the gap | `sum=60 bonus=7 runs=1`, exit 0 |
| `i <= 5` | `scores[5]` | the gap | same, exit 0 |
| `i <= 6` | `scores[6]` | `bonus` | `sum=60 bonus=60 runs=1`, exit 0. Silent data corruption |
| `i <= 7` | `scores[7]` | the loop variable `i` (and `bonus` was already hit by `scores[6]`) | `bonus=60`, exit 0, no message. `scores[7] = 70` lands on `i`, but this is the last iteration anyway |
| `i <= 8` or more | `scores[7]` | the loop variable `i` | exit 0, no message. Writing 70 into `i` makes `i <= bound` false, so the loop ends early at index 7. Check it yourself with `watch i` |

Now build the same program with the stack protector switched on explicitly and look again:

```sh
gcc -g -O0 -fstack-protector-strong scores.c -o scores.ssp
gdb -q -nx ./scores.ssp      # break 21, run, then the same p and x/ commands
```

The layout changes. `bonus` moved **below** the array, to `S - 4`. At `S + 24` sits the **canary**, an 8-byte value that changes on every run (in the lab's runs its lowest byte was `00`). In this build the array sits right below the canary and the other local below the array, so a contiguous overflow from the array reaches the canary before anything else. That placement was observed once, for this program on this toolchain. Treat it as a measurement, not as a rule about what the stack protector always does. With this build, `i <= 4` and `i <= 5` still run clean (gap at `S + 16` to `S + 23`), and `i <= 6` writes over the canary: the program aborts on return with `*** stack smashing detected ***: terminated`, exit status 134.

The same bug, three outcomes: harmless, silent corruption of `bonus`, or a clean abort. The source did not change. The compiler's choices did.

### Subgoal 4. Observe: run it without a sanitizer
Goal: see why "it runs fine" proves nothing.

```sh
./scores
# sum=60 bonus=7 runs=1
```

No crash, correct output. The out-of-bounds write happened and nothing showed it. This is the normal case for small overflows in C, and it is why you run sanitizers.

Note what `-Wall` printed at `-O0`: nothing. Recompile with `gcc -O2 -Wall -g scores.c -o scores2` and gcc warns at compile time:

```text
warning: iteration 4 invokes undefined behavior [-Waggressive-loop-optimizations]
warning: array subscript 4 is above array bounds of 'int[4]' [-Warray-bounds=]
```

The analysis behind those warnings runs only when optimising. Compile once with `-O2 -Wall -Wextra` just to read the warnings.

### Subgoal 5. Confirm: run it under ASan and UBSan
Goal: write the report you expect, then run it and compare field by field.

Prediction, written first: *stack-buffer-overflow, WRITE of size 4, in `main` at `scores.c:19`, just past the end of `scores`.* ASan uses its own frame layout, with guard bytes around the array, so the offsets it prints are not the uninstrumented ones from Subgoal 2. Predict "just past the end of `scores`", then read the numbers off the report.

```sh
gcc -g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined scores.c -o scores.asan
./scores.asan; echo "exit $?"
```

```text
scores.c:19:15: runtime error: index 4 out of bounds for type 'int [4]'
scores.c:19:19: runtime error: store to address 0x... with insufficient space for an object of type 'int'
...
==...==ERROR: AddressSanitizer: stack-buffer-overflow on address 0x... at pc 0x... bp 0x... sp 0x...
WRITE of size 4 at 0x... thread T0
    #0 0x... in main /work/fnd02/scores.c:19
...
  This frame has 1 object(s):
    [32, 48) 'scores' (line 15) <== Memory access at offset 48 overflows this variable
...
exit 1
```

Two tools spoke. UBSan printed two `runtime error` lines and let the program continue: first the index check (`index 4 out of bounds`), then the store check (`insufficient space for an object of type 'int'`). ASan then stopped the program at the same write. The report matches the prediction field by field: kind, direction, size 4 (`sizeof(int)`), line 19, the variable named. In ASan's layout `scores` occupies frame offsets `[32, 48)`, so offset 48 is the first byte past it. Only `scores` is listed as a frame object. `bonus` did not get its own guarded slot in this build.

### Subgoal 6. Harden-check: weak build, default build, protector build
Goal: know what protections your binary has, from the binary, not from a blog post.

```sh
gcc -g -O0 scores.c -o scores.default
gcc -g -O0 -fno-stack-protector -no-pie -Wl,-z,norelro -D_FORTIFY_SOURCE=0 scores.c -o scores.weak
gcc -g -O0 -fstack-protector-strong scores.c -o scores.ssp

for b in scores.default scores.weak scores.ssp; do
  echo "== $b"
  readelf -h  "$b" | grep 'Type:'                      # DYN = PIE, EXEC = fixed address
  readelf -lW "$b" | grep -E 'GNU_STACK|GNU_RELRO'      # GNU_STACK RW (not RWE) = NX; GNU_RELRO line = RELRO
  readelf -d  "$b" | grep -E 'BIND_NOW|FLAGS'           # BIND_NOW or FLAGS_1 NOW = full RELRO
  readelf -sW "$b" | grep -c __stack_chk_fail           # >0 = canary code present
done
gcc -Q --help=common | grep -E 'stack-protector|stack-clash|cf-protection'   # what this gcc enables by default
```

Lab result (gcc 14.2.0, Debian 13):

| Property | `scores.default` | `scores.weak` | `scores.ssp` |
|---|---|---|---|
| PIE | yes (`DYN`, `FLAGS_1 PIE`) | no (`EXEC`) | yes |
| NX | yes (`GNU_STACK RW`) | yes (`-z execstack` would be needed to remove it) | yes |
| RELRO | partial (`GNU_RELRO` present, no `BIND_NOW`) | none (no `GNU_RELRO`) | partial |
| Canary | **no** (0 `__stack_chk_fail`) | no | yes (2 `__stack_chk_fail` symbols) |

`gcc -Q --help=common` confirms it: `-fstack-protector-strong [disabled]` and `-fstack-clash-protection [disabled]`, and it shows `-fcf-protection=full`.

On this toolchain the default and weak builds have **identical frame layouts**. The weak flags only remove PIE and RELRO, which do not affect where locals go. Only the protector build rearranged the frame. A learner on a distro whose gcc enables the protector by default (Arch, per research) would see the `scores.ssp` layout as their *default*. That is why the module never tells you what "the default" looks like without showing you how to check.

## Struggle challenge
Attempt this closed-book before reading further. Timebox: 50 minutes (pilot parameter; log your actual time before first hint). Write down what you tried, even if you fail. Run it as one protocol session (FND-01).

The program is `/opt/osvr/fnd02/src/upper.c` (also `$M/lab/src/upper.c`):

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static const char *greeting = "hello";   /* pointer: global; bytes: string literal */
static char last[16];                    /* global array, zero-initialised */

/* Return a heap copy of s in upper case. Caller frees. */
static char *dup_upper(const char *s)
{
    size_t n = strlen(s);
    char *out = malloc(n);
    if (out == NULL)
        return NULL;
    for (size_t i = 0; i <= n; i++) {
        char c = s[i];
        out[i] = (c >= 'a' && c <= 'z') ? (char)(c - 32) : c;
    }
    return out;
}

int main(int argc, char **argv)
{
    char word[32];
    const char *src = argc > 1 ? argv[1] : greeting;

    snprintf(word, sizeof word, "%s", src);
    char *u = dup_upper(word);
    if (u == NULL)
        return 1;
    snprintf(last, sizeof last, "%s", u);
    printf("%s -> %s\n", word, u);
    free(u);
    return 0;
}
```

Write your answers in `/work/fnd02/challenge.md` **before compiling anything**:

1. **Locate.** For each of these, name the region: the pointer `greeting`; the bytes `"hello"`; `last`; `word`; `src`; `n`; the pointer `out`; the bytes `out` points to; the bytes of `argv[1]`.
2. **Find.** Name the line that breaks a size invariant, and write the invariant it breaks as an inequality.
3. **Predict.** For `./upper.asan` with no argument, write the ASan report fields: error kind, READ or WRITE, access size, "N bytes after M-byte region", frame `#0` function and line, allocation function and line.
4. **Predict again.** Same, for an argument of 16 `a` characters, then for one of 40 `a` characters. Only some fields change. Which, and to what?
5. **Without ASan.** Built with plain `gcc -g -O0`, does the program visibly misbehave? Give the reason in one sentence.
6. **Fix and check.** Make the smallest fix. Then confirm, under ASan, that all three inputs from 3 and 4 run clean.

Only then compile (`gcc -g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined upper.c -o upper.asan`), run, and mark each prediction right or wrong. Mark it; do not edit it.

Success: every prediction written before the first run, all marked against real output, fix confirmed clean on three inputs.

## Theory
### Where objects live
A running Linux process has one virtual address space split into regions. `info proc mappings` in gdb, or `cat /proc/<pid>/maps`, lists them. The C standard gives every object a **storage duration**, which fixes its lifetime (N1570 6.2.4; cppreference "Storage-class specifiers"; a fourth duration, thread, is out of scope here). The compiler and linker then choose where to put it:

| Storage duration | Declared how | Lifetime (the standard) | Where gcc on Linux puts it (check with `info symbol`) |
|---|---|---|---|
| static | at file scope, or with `static` inside a function | the entire execution of the program, initialised once before startup | `.data` if initialised to non-zero, `.bss` if zero or uninitialised, `.rodata` for `const` data and string literals |
| automatic | ordinary local variables and parameters | from entry to the enclosing block until that block ends; a fresh instance for each recursive call | the stack, in the current function's frame (or only in registers if the address is never taken) |
| allocated | `malloc`, `calloc`, `realloc` | until `free` | the heap |

elf(5) defines the sections themselves: `.data` is initialised writable data, `.bss` is writable data the system zero-fills at program start and that takes no space in the file, `.rodata` is read-only data. It does not say which variables go where. The right-hand column is gcc's behaviour, which you confirmed in Subgoal 2 and confirm again in Drill 1.

Measured on the lab's gcc (audit run, `gdb -q -nx`, `info symbol &name`): `int g1;`, `int g2 = 0;` and `static char g5[64];` are in `.bss`. `int g3 = 5;`, the pointer `char *g6 = "abc";`, the array `char g7[] = "abc";` and a local `static int y = 1;` are in `.data`. `const int g4 = 5;` is in `.rodata`. For the literal `"abc"` itself, `info symbol g6` prints `No symbol matches`, because a string literal has no symbol. Use `p g6` and find the address in `info files` instead. Drill 1 has you repeat this sweep.

Three more places matter in practice. The program's code is in `.text`. The bytes behind `argv` and the environment are put at the top of the stack region by the kernel at program start. A string literal is an array in `.rodata`, which is mapped read-only. Writing to it is undefined behaviour, and on a read-only mapping the write faults (SIGSEGV).

Why a researcher cares: *the region decides what an out-of-bounds write hits.*
- **Stack**: other locals of the same frame, compiler padding, the canary, the saved frame pointer and the return address. The order is the compiler's choice and changes with flags. You saw the stack protector reorder `bonus`.
- **Heap**: the allocator's slack after your block, then the allocator's bookkeeping for the next block, then the next block's data. BX covers glibc's layout in detail.
- **Static data**: the next global in the same section.

### Pointers, arrays and decay
A pointer is an address plus a type. The type tells the compiler two things: how many bytes `*p` reads (`sizeof *p`), and how far `p + 1` moves (also `sizeof *p`). `p[i]` is defined as `*(p + i)`.

An array is a block of `N * sizeof(element)` contiguous bytes, and **nothing else**. No length is stored. In most expressions an array name converts ("decays") to a pointer to its first element. That is why you can pass `scores` to `sum(const int *v, ...)`. The exceptions are `sizeof a` and `&a`, where `a` stays an array:

```c
int a[4];         /* sizeof a == 16, &a has type int (*)[4]      */
int *p = a;       /* decay: p == &a[0], sizeof p == 8 on x86-64   */
void f(int b[4]); /* b is int *: the 4 is ignored, sizeof b == 8 */
```

You may form the address one past the end (`&a[4]`) and compare with it, which is how loops end. Dereferencing it is out of bounds, and so is forming any address further out.

### C strings and the size invariant
A C string is a run of bytes ended by a NUL (`'\0'`). Two numbers describe a string buffer and they are different:
- **length**: bytes before the NUL, what `strlen` returns;
- **size**: bytes the buffer owns, what you passed to `malloc` or wrote in `char buf[N]`.

The invariant every string buffer must keep is **`size >= length + 1`**, because the NUL needs a byte too. Every C string off-by-one is a violation of this one inequality. The common shapes:

| Shape | Example | Why it breaks the invariant |
|---|---|---|
| allocation forgets the terminator | `malloc(strlen(s))` then copy including the NUL | size = length, so the NUL is one byte past the end |
| terminator written at the full length | `buf[len] = '\0'` where `len` can equal the buffer size | the write index equals the size |
| `<=` loop bound | `for (i = 0; i <= n; i++) a[i] = ...` with `a` of size `n` | the last iteration writes `a[n]` |
| size passed as if it were length | `strncpy(dst, src, sizeof dst)` | when `src` is at least `sizeof dst` long, `strncpy` writes no NUL at all. The next `strlen` reads past the end |

CWE names the class CWE-193 (off-by-one error). The result is an out-of-bounds write (OOB write) or read of exactly one element. Many real bugs of this shape come from a size and a length that each look right in their own function, with the off-by-one appearing only where they meet. That is the iperf3 bug.

### What a one-byte overflow does on the heap
In a build without ASan, `malloc(n)` returns at least `n` usable bytes, often more. Measured with `malloc_usable_size` on the lab's glibc 2.41 (x86-64): requests of 1 to 24 bytes give 24 usable, 25 to 40 give 40, 128 gives 136, 256 gives 264, 384 gives 392, 512 gives 520. So:
- a one-byte overflow past `malloc(5)` or `malloc(256)` lands in slack nobody uses, and nothing can notice;
- a one-byte overflow past `malloc(24)` or `malloc(40)` lands on the first byte after the usable area. That byte belongs to the allocator's record of the next chunk: its size field. That is the situation `poison_null_byte` exploits.

Hitting metadata does not guarantee a visible failure either. In the lab, the struggle-challenge program with a 24-character input puts its stray NUL on the lowest byte of the size field of the *top chunk*, the unallocated remainder at the end of the heap. The audit run measured that field changing from `0x20d51` to `0x20d00`. That shrinks the recorded size and also clears its lowest bit, which glibc uses as a flag (PREV_INUSE, "the chunk before this one is in use"). Then `printf` runs, and stdio allocates its output buffer (`_IO_file_doallocate`) by carving it from the top chunk, which means reading that damaged size. The smaller value is accepted and the program exits 0 with no message.

> needs-lab-verification: *why* glibc accepts the damaged top size there. The module has no filed glibc source for the checks on this path, so it does not name one. BX covers the allocator.

In project variation 2, the same one-byte write onto a *neighbouring allocated* chunk makes glibc abort, but only when that chunk is later freed through a path that checks its size. So the outcome depends on two things: whether the byte is slack or metadata, and whether anything checks that metadata afterwards. An attacker may influence both. Without a sanitizer you cannot tell from "it ran fine".

### How ASan sees what plain execution hides
ASan combines compile-time instrumentation of every memory access with a replacement allocator, and reports the error *at the access* rather than at some later crash (Clang ASan docs; ASan paper abstract). Its report's legend shows the idea. Bytes around each heap block, stack array and global are marked unaddressable ("redzones" in the legend), and every instrumented access is checked against those marks. FND-03 covers the mechanism. For prediction you need the report's arithmetic:
- **WRITE/READ of size K**: the width of the access. 1 for a `char`, 4 for an `int`. For a libc call it is the range the interceptor checked, which can be longer.
- **"located N bytes after M-byte region"**: M is the size you asked for. N is how far past the end the access starts. A classic off-by-one gives `0 bytes after`.
- **access frame**: frame `#0` of the access stack is where the bad access happened, but it may be inside the sanitizer or libc. For example, a `memset` overflow has `#0` in ASan's `memset` interceptor. This module (and the lab's `predict-check`) therefore uses **frame0**, defined as *the first frame that is not a sanitizer interceptor or libc frame*, which means the first frame in your program's own source. For `out[i] = ...` frame0 is frame `#0`. For a `memset` overflow, frame0 is the function that called `memset`.
- **Allocation stack**: where the block was made (for globals, ASan names the variable instead). When the allocating function and frame0 differ, the bug usually lives in the contract between them.

### Sanitizer blind spots
ASan sees only what this run does, and only at the granularity of whole objects.
- **Intra-object overflow.** `lab/src/intra.c` writes `r.buf[8]` inside `struct rec { char buf[8]; int id; }`. The byte lands in `id`, which is still inside `r`, so ASan stays silent. Measured in the lab: the program printed `id=88` (the `'X'` byte, 0x58, changed `id` from 42) and exited 0. UBSan's `bounds` check did report `index 8 out of bounds for type 'char [8]'`, because it knows the array's declared size. Drill 3 asks you to check whether it still reports when the write goes through a `char *`.
- **Code paths the input never takes.** No report means "this input did not trigger it", not "the code is safe".
- **Uninitialised reads** are not ASan's job (the ASan docs page does not list them).
- **Unsigned wrap-around** is not undefined behaviour and UBSan does not report it under `-fsanitize=undefined` (GCC docs; FND-05).

## Walkthrough (spoilers)
Reference solution for the struggle challenge. The ASan fields and run results below were measured on the lab image (gcc 14.2.0, glibc 2.41). Your addresses will differ.

**1. Locate.**

| Object | Region |
|---|---|
| pointer `greeting` | `.data`: a static pointer initialised to a non-zero address (`info symbol &greeting` prints `greeting in section .data`) |
| bytes `"hello"` | `.rodata`. `p greeting` prints `0x555555556004 "hello"`, inside the `info files` line `0x0000555555556000 - 0x0000555555556017 is .rodata` |
| `last` | `.bss` (static, zero-initialised; `info symbol &last` names section `.bss`) |
| `word`, `src` | stack, `main`'s frame |
| `n`, pointer `out` | stack, `dup_upper`'s frame (at `-O0`; registers when optimised) |
| bytes `out` points to | heap (`p out` falls inside the `[heap]` line of `info proc mappings`) |
| bytes of `argv[1]` | top of the stack region, placed there by the kernel |

(Measured on the lab image with `gdb -q -nx ./upper`. `info files` is an alias of `info target` (GDB manual), and on this gdb it lists each section's address range. `info symbol` cannot name the literal, because a literal has no symbol.)

**2. Find.** Line 12, `char *out = malloc(n);`. The invariant is `size >= length + 1`, here `malloc size >= strlen(s) + 1`. The loop on line 15 runs `i <= n` on purpose: it copies the terminating NUL as well. So the loop is correct and the allocation is one byte short. If you blamed line 15, see Consolidation.

**3. Predict (no argument).** `word` holds `"hello"`, so `n = 5`, the block is 5 bytes, and the last iteration (`i = 5`) writes the NUL to `out[5]`:

```text
ERROR: AddressSanitizer: heap-buffer-overflow on address 0x... at pc 0x... bp 0x... sp 0x...
WRITE of size 1 at 0x... thread T0
    #0 0x... in dup_upper /work/fnd02/upper.c:17
    #1 0x... in main /work/fnd02/upper.c:28
0x... is located 0 bytes after 5-byte region [0x...,0x...)
allocated by thread T0 here:
    #0 0x... in malloc (...libasan...)
    #1 0x... in dup_upper /work/fnd02/upper.c:12
    #2 0x... in main /work/fnd02/upper.c:28
```

Size 1 because `out[i]` is a `char`. UBSan says nothing: a heap block has no declared array type for its `bounds` check to use.

**4. Predict again.** 16 `a`s: only the region size changes, to `16-byte region`. 40 `a`s: `snprintf(word, sizeof word, ...)` truncates to 31 characters plus NUL, so `n = 31` and the report says `31-byte region`. The `snprintf` into `word` is safe. It limits the copy to 32 bytes including the NUL. The truncation is the clue you were meant to catch.

**5. Without ASan.** No visible misbehaviour: `hello -> HELLO`, exit 0. `malloc(5)` returned a block with 24 usable bytes, so the stray NUL landed in slack. The lab also ran inputs of 8, 23, 24, 25, 31 and 40 characters: all exit 0 with no message. Two of these are worth a second look. At 31 (and at 40, which truncates to 31), `malloc(31)` has 40 usable bytes, so the NUL again lands in slack. At exactly 24, `malloc(24)` has exactly 24 usable bytes, so the NUL does land on allocator metadata: the lowest byte of the top chunk's size field, which goes from `0x20d51` to `0x20d00`. The next allocation, stdio's buffer inside `printf`, is carved from the top chunk and reads that smaller size without failing, so nothing visible happens (why it is accepted: needs-lab-verification, see Theory). "Hit metadata" and "visible failure" are different events (Theory, *What a one-byte overflow does on the heap*).

**6. Fix.** `char *out = malloc(n + 1);`. Rebuild under ASan and rerun all three inputs: each prints the upper-cased word and exits 0 with no report. That is your negative control.

## Consolidation
Put your `challenge.md` next to the walkthrough. For each subgoal (Locate, Find, Predict, Predict again, Without ASan, Fix), write three short lines: what you did, what the reference does, and the gap in one line. Typical gaps worth a card:
- Calling the `greeting` pointer and the `"hello"` bytes the same region. They are two objects: an 8-byte pointer in `.data` and a 6-byte array in `.rodata`.
- Saying `.data` for `last`. Zero-initialised statics go in `.bss`.
- Blaming the loop. "Fixing" it to `i < n` silences the write but leaves `out` without a NUL. ASan then reports a heap-buffer-overflow **READ of size 6**, `0 bytes after 5-byte region`, from inside the next `snprintf`: `#0 printf_common` (the sanitizer's format-string interceptor), `#1 vsnprintf`, `#2 snprintf`, `#3 main` at line 31 (measured in the lab). The read is 6 bytes because `%s` scanned `HELLO` and kept going to look for a terminator. The invariant tells you which line to change: the allocation is what owns the size.
- Predicting `WRITE of size 4` or `of size 5`. The access is one `char`.
- Missing the 31-byte truncation.
- "No ASan report means it is fixed", without rerunning the other inputs.

Add each gap with `python3 scripts/srs.py add ...`, and log time-to-first-hint (or "none") in your session log.

## Common failure points
| Symptom | Likely cause | How to see it (command) |
|---|---|---|
| gdb: `No symbol "scores" in current context` | Built without `-g`, or stopped in the wrong frame | `info frame`, `bt`, then `frame N`. Rebuild with `-g` |
| gdb prints `Error disabling address space randomization: Function not implemented`, and addresses change between runs | The container runs with the engine's default seccomp profile, which blocks the `personality` call gdb uses to turn ASLR off. Capabilities are not the cause: under rootless podman gdb needs none | Use `"$M/lab/run.sh"`, which passes `--security-opt seccomp=unconfined`. If you start the container by hand, add that flag. Docker: untested, see the note at the top |
| Addresses differ from the transcripts, or between runs | Outside gdb: ASLR. Inside gdb, with ASLR off: the stack base still moves with environment size and program arguments | `show disable-randomization` in gdb. Compare offsets from the object (`p (char *)&bonus - (char *)scores`), never absolute addresses |
| `p sizeof scores` prints `0x10`, and a large coloured pane appears at every stop | gdb loaded GEF from the base image's init file. GEF sets the output radix to 16 | Start gdb with `gdb -q -nx`. FND-03 introduces GEF |
| `p &scores[4] - &scores[0]` prints `4`, not `16` | Pointer subtraction counts elements, not bytes | Cast to `char *` first to count bytes |
| `sizeof` of an array parameter prints 8 | The parameter decayed to a pointer | `ptype v` in gdb shows `const int *` |
| `%p` warning, or garbage printed for a pointer | `%p` expects `void *` and `%zu` expects `size_t` | Compile with `-Wall -Wextra`. Read the `-Wformat` warning |
| No ASan report at all | Flag missing on the compile *or* link line, or the input does not take the buggy path | `nm ./prog \| grep -c __asan` should be non-zero. Check the input |
| ASan report has no file:line | Built without `-g` | Look at the compile command you actually ran (`history`) |
| UBSan line appears but ASan's does not (or the other way round) | Each checks different things: UBSan bounds needs a declared array type, ASan needs the access to leave the object | Compare with the *Sanitizer blind spots* section |
| `-O0` build gives no `-Warray-bounds` warning for an index past the end | That warning needs the optimiser's analysis | Recompile with `-O2 -Wall -Wextra` to read warnings. Some checks do fire at `-O0`: the Drill 2 `memset` case triggers `-Wstringop-overflow` |
| Weak build still shows NX | `-z execstack` was not passed. NX is on unless you remove it | `readelf -lW prog \| grep GNU_STACK` |

## Next
Drills: `drills.md`. Project: `project.md`. Cards: import with `python3 scripts/srs.py import FND-02-c-pointers-and-memory`.

FND-03 builds a whole real project with sanitizers and teaches how ASan's shadow memory works. Bring your `challenge.md` and project `rootcause.md`: FND-03 starts by asking you to explain your ASan reports from the mechanism.
