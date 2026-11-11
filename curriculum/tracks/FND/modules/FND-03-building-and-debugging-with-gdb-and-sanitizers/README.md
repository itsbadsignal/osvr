# FND-03-building-and-debugging-with-gdb-and-sanitizers: Building real C projects and debugging them with gdb and sanitizers

Track: FND   Hours: 10   Prereqs: FND-02-c-pointers-and-memory   Status: drafting
Outcomes: find, rootcause

In FND-02 you compiled one file with one `gcc` line. Real targets are dozens of files driven by a build system you did not write, with its own idea of which flags matter. This module teaches you to take an unfamiliar C project at a pinned commit, get AddressSanitizer (ASan), UndefinedBehaviorSanitizer (UBSan) and debug symbols into **every** object it builds, prove that you did, run its test suite under the sanitizers, and then drive gdb through its code to answer questions about runtime state. The codebase is cJSON at tag `v1.7.17`, the same tree your FND-01 lab used for its smoke test. You do not root-cause that CVE here. You learn to build and walk the code around it.

Hour budget (pilot parameter): about 1 h prerequisite check and worked example reading, 1.5 h worked example hands-on, 1.25 h struggle challenge, 1.5 h theory, 2 h for the first rep of each drill, 3 h project. The later drill reps ("Owned when" in `drills.md`) are spread across later sessions and are not inside this budget.

Conventions from FND-01 and FND-02 carry over. Set these once per terminal, from the repo root:

```sh
M=curriculum/tracks/FND/modules/FND-03-building-and-debugging-with-gdb-and-sanitizers
ENGINE=$(command -v podman || command -v docker)
mkdir -p ~/osvr-work/fnd03
```

The lab image is `osvr-fnd03:1`, built `FROM osvr-fnd-base:1` (the shared FND base: Debian trixie, gcc 14.2.0-19, gdb 16.3, GEF). Build and enter it:

```sh
"$ENGINE" build -t osvr-fnd03:1 -f "$M/lab/Dockerfile" "$M/lab"   # needs osvr-fnd-base:1 (FND-01)
"$M/lab/run.sh"            # interactive shell, no network, ~/osvr-work/fnd03 mounted at /work/fnd03
ASLR_OFF=1 "$M/lab/run.sh" # same, plus --security-opt seccomp=unconfined so gdb can disable ASLR
```

The lab is verified on rootless podman 6.1.4 (`lab/README.md`). `run.sh` starts the container with `--network=none --cap-drop=ALL`, and gdb and ASan both work like that. Without `ASLR_OFF=1`, gdb prints its ASLR warning and runs with ASLR on.

> needs-lab-verification: Docker is untested: whether `--user`, `--cap-add=SYS_PTRACE` or a seccomp change are needed for gdb, and whether LeakSanitizer behaves the same. SELinux hosts may need `:Z` on the mount (also untested).

Inside the container, a full clone of cJSON sits at `/src/cjson`, checked out at commit `87d8f0961a01bf09bef98ff89bae9fdec42181ee` (tag `v1.7.17`, `research/targets/FND.md`). Treat `/src/cjson` as read-only. Copy it into `/work/fnd03` before you build, so your builds survive the container. `cp -a` keeps the read-only modes and the lab drops all capabilities, so make the copy writable straight after: `chmod -R u+w <copy>`.

Every output in this README was produced by the module-builder on 2026-11-11 inside images derived from `osvr-fnd-base:1` under rootless podman (gcc 14.2.0-19, gdb 16.3, cmake 3.31.6). Paths are rewritten to the lab layout. Addresses will differ on your machine; anything else that differs is worth writing down. The lab-engineer re-measured them in `osvr-fnd03:1` (`lab/SPEC.md`, Implementation notes). Where the two disagreed, this README uses the lab's measured values.

gdb note: the base image loads GEF for every gdb session. GEF's context pane is useful later (FND-06). For the transcripts in this module, start gdb as `gdb -nx` so you get plain gdb output that matches the text.

## Objectives
After this module you can:
1. Build an unfamiliar C project at a pinned commit, out of tree, with `-fsanitize=address,undefined`, `-g`, `-O0` and frame pointers, by injecting the flags through the project's own build system (Make or CMake), and show the exact compile command each object was built with.
2. Prove a build is really sanitized with three independent kinds of evidence (the recorded compile command, instrumentation calls in each artefact, the sanitizer runtime linked and alive), and diagnose a build that claims sanitizers but lacks them.
3. Run a project's test suite under ASan and UBSan, configured so that a UBSan finding fails the test instead of scrolling past.
4. Answer a question about a running program's state with gdb: set function, `FILE:FUNCTION` and multi-location breakpoints, then use `bt`, `frame`, `p`, `ptype`, `x`, `finish`, `watch` and ignore counts, and cite the transcript as evidence.
5. Stop gdb at the exact instruction a sanitizer flags, by breaking on the ASan report function or by making ASan abort, and work around LeakSanitizer's refusal to run under a debugger.
6. Explain, from the disassembly of an instrumented function, how ASan decides an access is bad: compute the shadow address of a given address and state the check performed on the shadow byte.

## Where this shows up in the wild
- **cJSON CVE-2023-53154** (MITRE record; `research/targets/FND.md`): the over-read your FND-01 lab reproduces exits 0 with an empty report when the harness is built without `-fsanitize=address` (FND-01 lab, verified). Without a working sanitizer build, the bug has no visible symptom.
- **cJSON issue 800**, the upstream report of that bug: the project's existing fuzz target hid it, because the harness rejected inputs that did not end in a NUL byte (`research/targets/FND.md`). The bug was in the library; whether anyone could see it depended on how the test was built and fed.
- **Mozilla Bugzilla 1545095** (2019): ASan builds in Mozilla's CI hit a LeakSanitizer fatal error that the patch attributed to ptrace restrictions in newer Docker; the fix disabled leak detection in those builds (`research/domain-maps/foundations.md`, FND-01 lab sources). The debugger and container environment change what a sanitizer build does.
- Practitioner reports filed in `research/FIELD-SYNTHESIS.md` (finding 5, anecdotes rather than measurements): environment setup can cost more than finding the bug. Building the target with the right instrumentation is that setup.

## Mitigation context
FND-03 bypasses nothing. You need to know what is switched on in your builds, because the sanitizer build you make for finding bugs is not the hardened build that ships.

| Mitigation / mechanism | On in this module? | What it does | How this module deals with it |
|---|---|---|---|
| AddressSanitizer (ASan) | Yes, in every build you make, if you get it right | Detection, not mitigation. Instrumentation before each memory access plus a replacement allocator; reports at the bad access (Clang ASan docs). Not for production; about 2x slowdown | Objective 2 is proving it is really there. Theory explains the shadow check from disassembly |
| UBSan | Yes, with ASan | Detection. Compile-time checks that call a runtime handler. Recovers (prints and continues) by default, except for the `unreachable` and `return` checks, which never recover (GCC Instrumentation Options; for ASan recovery is off by default) | You make it fatal with `-fno-sanitize-recover=undefined` so a finding fails the test |
| Stack protector (canary) | Not by default in the lab's bare gcc (derived: `gcc -Q --help=common` shows `-fstack-protector-strong [disabled]`; a plain build references no `__stack_chk_fail`). Projects often add it themselves | Detects contiguous stack overwrites at function return | You read the project's build files to see whether it adds the flag, and notice when your flag injection removes it |
| PIE + ASLR | PIE is on by default (derived: `gcc -v` shows `--enable-default-pie`). ASLR is the host kernel's | Randomises load addresses per run | gdb cannot disable ASLR under the lab's default seccomp profile (it warns `Error disabling address space randomization: Function not implemented`). Compare by symbol and offset. Use `ASLR_OFF=1 "$M/lab/run.sh"` only for drills that need fixed addresses |
| NX, partial RELRO | On by default (derived: `GNU_STACK RW`, `GNU_RELRO` present, no `BIND_NOW`) | Non-executable stack; read-only relocations after load | Not studied here. FND-07 |
| CET branch protection (`-fcf-protection`) | On by default in the lab's gcc (derived: `gcc -Q --help=common` shows `-fcf-protection=full`) | Marks valid indirect-branch targets (`endbr64`) and emits shadow-stack-compatible code; nothing is enforced without CPU, kernel and libc support | Not studied here. Named so you are not surprised by `endbr64` at function starts in disassembly. needs-lab-verification: which parts (shadow stack, indirect-branch tracking) the learner's kernel and glibc actually enforce for user programs; no source on this is filed |
| `_FORTIFY_SOURCE` | Off in all FND-03 builds | Adds bounds checks to some libc calls when sizes are known at compile time; needs `-O1` or higher | Incompatible with sanitizers (OpenSSF hardening guide). The compiler does not stop you: a `-O1 -fsanitize=address -D_FORTIFY_SOURCE=2` build compiles without error (derived). Leave it off |

## Prerequisite check
Closed-book, under 10 minutes. FND-02 told you to bring your `challenge.md` and project `rootcause.md`; have them open only for question 2.

1. Write the single `gcc` command that builds `t.c` into `t.asan` with ASan and UBSan, debug info, frame pointers and no optimisation.
2. From your FND-02 `upper.asan` report (no argument): what do `5-byte region` and `0 bytes after` each tell you, and why is the access `of size 1`?
3. A write to `r.buf[8]` where `struct { char buf[8]; int id; } r;`: which of ASan and UBSan reports it, and why does the other stay silent?
4. In gdb, which command stops execution at the moment a specific byte is written? Which command shows the chain of calls that led to the current line?
5. In one sentence each: what does the compiler do with `-g`, and what does `-O0` change compared with `-O2` when you debug?

<details><summary>Answer key (open after attempting)</summary>

1. `gcc -g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined t.c -o t.asan`
2. The block was 5 bytes (M, what was passed to `malloc`). The access starts exactly at the end (N = 0), the classic off-by-one. Size 1 because one `char` was written.
3. UBSan's `bounds` check reports it, because it knows `buf`'s declared size. ASan stays silent: the byte is still inside the object `r`, so no redzone is touched (intra-object overflow).
4. `watch -l <lvalue>` (for example `watch -l *(char *)&buf[16]`). `bt` (backtrace).
5. `-g` emits debug information (DWARF) that maps machine code back to files, lines, variables and types. At `-O0` every variable lives in memory and each line maps to its own instructions, so you can step and print anything; at `-O2` variables move to registers or vanish (`<optimized out>`) and lines are reordered or merged.

**Route.** All five correct **and** you have built a CMake or autotools project with sanitizers before **and** checked that the instrumentation was really present: go straight to the struggle challenge. Otherwise study the worked example first. That route is the default.
</details>

## Worked example
**Instance:** cJSON's **Makefile** build of its demo program `cJSON_test` (`test.c` plus `cJSON.c`, one `gcc` invocation, one executable), then, in Subgoal 8, a CMake build of the shared library alone with the tests switched off. The struggle challenge uses CMake on the whole test suite: a different set of binaries (19 registered tests: the 18 Unity test programs plus a CMake-built `cJSON_test`, and a shared library), a different function, and its own traps. Read every subgoal. Type every command yourself.

### Subgoal 1. Pin: start from a known commit
Goal: a private, writable copy of the source at the pinned commit, with proof.

```sh
cp -a /src/cjson /work/fnd03/we && chmod -R u+w /work/fnd03/we && cd /work/fnd03/we
git rev-parse HEAD          # 87d8f0961a01bf09bef98ff89bae9fdec42181ee
git status --short          # empty: no local changes
```

If `git` complains about "dubious ownership", run `git config --global --add safe.directory '*'` inside the container. The copy is owned by a different UID from the one git expects.

### Subgoal 2. Recon: find how this project builds, without building
Goal: know which build systems exist, which target you want, and the exact command `make` would run.

```sh
ls                                   # CMakeLists.txt AND Makefile: two build systems
grep -n 'CFLAGS' Makefile | head     # how compiler flags are assembled
make -n cJSON_test                   # -n: print the commands, run nothing
```

```text
gcc -std=c89 -fPIC -pedantic -Wall -Werror -Wstrict-prototypes ... -Wconversion -fstack-protector cJSON.c test.c  -o cJSON_test -lm -I.
```

Read it like a contract. One `gcc` call compiles both `.c` files and links them in one go, so any flag you add applies to compile and link alike. `-Werror` means any warning stops the build, which matters when new flags produce new warnings. The project adds a stack protector itself (`Makefile` lines 29 to 37). It chose the weaker `-fstack-protector` rather than `-strong` on this gcc. Drill 4's stretch asks you to find out why from line 32.

### Subgoal 3. Inject: put the sanitizer flags into the build
Goal: get your flags into the command without editing the project's files.

```sh
make cJSON_test CFLAGS="-g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined"
make -B -n cJSON_test CFLAGS="-g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined"
```

```text
gcc -std=c89 -fPIC -pedantic -Wall -Werror ... -Wconversion -g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined cJSON.c test.c  -o cJSON_test -lm -I.
```

Your flags are in. Something also left: `-fstack-protector` is gone. A variable set on `make`'s command line overrides the Makefile's own assignments to it, including its `CFLAGS += ...`. For a sanitizer build that loss is harmless (ASan sees stack overflows directly). For any other build it would silently weaken it. **Always reread the real command after injecting flags.**

### Subgoal 4. Verify: prove the sanitizers are in, three ways
Goal: evidence a sceptic would accept, not "I passed the flag".

```sh
nm cJSON_test | grep -c __asan_report      # 8: calls to ASan's report functions exist in the code
nm cJSON_test | grep -c __ubsan_handle     # 6: calls to UBSan's handlers exist
ldd cJSON_test | grep -E 'asan|ubsan'      # libasan.so.8 and libubsan.so.1 are linked
ASAN_OPTIONS=help=1 ./cJSON_test 2>&1 | head -1   # "Available flags for AddressSanitizer:"
```

The three kinds of evidence answer different questions:

| Evidence | Question it answers | What fools it |
|---|---|---|
| The compile command (`make -n`, later `compile_commands.json`) | Was the flag on the command line of every object? | Nothing, if you read the command for each object, not just one |
| `nm` shows `__asan_report_*` / `__ubsan_handle_*` | Did the compiler actually insert checks into this code? | Nothing for ASan: these names appear only in instrumented code (see Theory) |
| `ldd` shows `libasan`, and `ASAN_OPTIONS=help=1` prints ASan's flag list | Is the runtime linked and starting? | Linking with `-fsanitize=address` but compiling without it: runtime present, no checks (derived; Theory) |

### Subgoal 5. Run: does the instrumented program behave?
Goal: a clean baseline before you debug.

```sh
./cJSON_test > /dev/null; echo "exit=$?"     # exit=0, no report
```

A clean run with sanitizers on is information: on this input, nothing that ASan or UBSan checks went wrong. It is not proof the code is safe (FND-02, *Sanitizer blind spots*).

### Subgoal 6. Debug: answer a runtime question with gdb
Goal: answer, with transcript evidence, *"the first time cJSON prints a number, which number is it, which key does it belong to, and what is already in the output buffer?"*

```sh
ASAN_OPTIONS=detect_leaks=0 gdb -nx ./cJSON_test
```

`detect_leaks=0` is not optional under gdb. At exit, LeakSanitizer refuses to run under ptrace and kills the program with exit code 1 (derived: `LeakSanitizer has encountered a fatal error. HINT: LeakSanitizer does not work under ptrace (strace, gdb, etc)`).

```text
(gdb) break print_number
Breakpoint 1 at 0x296af: file cJSON.c, line 552.
(gdb) run
warning: Error disabling address space randomization: Function not implemented
Breakpoint 1, print_number (item=0x5060000001a0, output_buffer=0x7fa279a00020) at cJSON.c:552
552	    unsigned char *output_pointer = NULL;
(gdb) bt
#0  print_number (item=..., output_buffer=...) at cJSON.c:552
#1  print_value (...) at cJSON.c:1411
#2  print_object (...) at cJSON.c:1784
#3  print_value (...) at cJSON.c:1438
#4  print_object (...) at cJSON.c:1784
#5  print_value (...) at cJSON.c:1438
#6  print (item=..., format=1, hooks=...) at cJSON.c:1211
#7  cJSON_Print (item=...) at cJSON.c:1259
#8  print_preallocated (root=...) at test.c:53
#9  create_objects () at test.c:178
#10 main () at test.c:265
(gdb) p *item
$1 = {next = 0x506000000200, prev = 0x506000000140, child = 0x0, type = 8, valuestring = 0x0,
      valueint = 1920, valuedouble = 1920, string = 0x502000000090 "width"}
(gdb) finish
Run till exit from #0  print_number (...) at cJSON.c:552
print_value (...) at cJSON.c:1411
Value returned is $2 = 1
(gdb) x/s output_buffer->buffer
0x511000000040:	"{\n\t\"name\":\t\"Jack (\\\"Bee\\\") Nimble\",\n\t\"format\":\t{\n\t\t\"type\":\t\"rect\",\n\t\t\"width\":\t1920"
```

Read the evidence:
- `bt` frames #1 to #5 alternate `print_value` and `print_object`: the printer recurses once per nesting level. Frame #2 and #4 are two levels of `{`. Frames #8 to #10 are the program's own code, the part you would set a breakpoint in next time.
- `p *item` prints the whole `cJSON` node. The key is `string = "width"`, the number is in both `valueint` and `valuedouble`. `ptype item` would show the struct definition (`cJSON.h`).
- `finish` runs to the end of the current function and prints its return value (`1`, success). Back in `print_value`, `output_buffer` is in scope again and `x/s` shows the text printed so far, ending in `1920`.

Before `finish`, `p *output_buffer` showed the rest of the buffer as `'\276' <repeats 122 times>`. That is byte 190 (0xbe): ASan fills newly allocated heap memory with it (derived: `ASAN_OPTIONS=help=1` lists `malloc_fill_byte ... (Current Value: 190)`). When you see 0xbe in an ASan build, you are looking at bytes nobody has written yet.

### Subgoal 7. Stop at a sanitizer report, not after it
Goal: when ASan fires, land in gdb at the bad access with the program still alive. cJSON's demo is clean, so use a three-line tripwire (`/opt/osvr/fnd03/src/tripwire.c` in the lab):

```c
#include <stdlib.h>
int main(void){char *p=malloc(8); p[8]=1; free(p); return 0;}
```

```sh
gcc -g -O0 -fno-omit-frame-pointer -fsanitize=address /opt/osvr/fnd03/src/tripwire.c -o tripwire
```

Three ways to run it under gdb, observed:

| How | What gdb shows |
|---|---|
| `gdb -nx -ex run ./tripwire` | ASan prints its report and exits: `[Inferior 1 ... exited with code 01]`. `bt` says `No stack.` Too late |
| `ASAN_OPTIONS=abort_on_error=1 gdb -nx -ex run ./tripwire` | `Program received signal SIGABRT`. `bt` shows ten frames: libc `abort`, then `__sanitizer::Die`, `__asan::ReportGenericError`, `__asan_report_store1`, then `#9 main () at tripwire.c:2`. `frame 9` puts you at the bad write |
| `gdb -nx -ex 'break __asan_report_store1' -ex run ./tripwire` | Stops **before** the report is printed. `#0 __asan_report_store1 (addr=...)`, `#1 main () at tripwire.c:2`. `up`, then `p p`, `p &p[8]`, `x/16xb p` |

The breakpoint name encodes the access: `store` for a write, `load` for a read, and the width in bytes (`store1`, `load4`, ...). `nm ./prog | grep __asan_report` lists exactly which ones your program can call. When you do not know the access type, use `abort_on_error=1`.

### Subgoal 8. The same loop through CMake, on the library alone
Goal: inject, record and verify through CMake, on a different target from the challenge: the shared library `libcjson.so` only, with the tests switched off. Whether CMake's own options can be trusted is the challenge's business; here you pass the flags yourself.

```sh
cd /work/fnd03/we
cmake -S . -B build-lib -DCMAKE_BUILD_TYPE=Debug -DENABLE_CJSON_TEST=OFF \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
      -DCMAKE_C_FLAGS="-g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined"
cmake --build build-lib --target cjson
```

The configure prints a `CMake Deprecation Warning` about `cmake_minimum_required`. It is harmless (Common failure points).

- **Configure vs build.** The first command only *configures*: it writes `build-lib/` and the cache `build-lib/CMakeCache.txt`, where your flags now sit (`grep '^CMAKE_C_FLAGS:' build-lib/CMakeCache.txt` gives `CMAKE_C_FLAGS:STRING=-g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined`). The second command runs the generated build, for the one target `cjson`.
- **Record.** `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` wrote `build-lib/compile_commands.json`, one entry per compiled file. With tests off there is exactly one, for `cJSON.c`:

```text
"command": "/usr/bin/cc -DCJSON_API_VISIBILITY -DCJSON_EXPORT_SYMBOLS -DENABLE_LOCALES -Dcjson_EXPORTS  -g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined -std=c89 -pedantic -Wall -Wextra -Werror ... -fstack-protector-strong ... -fvisibility=hidden  -g -fPIC -o CMakeFiles/cjson.dir/cJSON.c.o -c /work/fnd03/we/cJSON.c"
```

  Your flags come first, then the project's own (`-Werror`, `-fstack-protector-strong`, ...), then the build type's `-g` and `-fPIC`. Order matters when two flags conflict (Theory).
- **Verify.** A shared library's imports are dynamic symbols, so use `nm -D`:

```sh
nm -D build-lib/libcjson.so.1.7.17 | grep -c __asan_report    # 8
nm -D build-lib/libcjson.so.1.7.17 | grep -c __ubsan_handle   # 5
ldd build-lib/libcjson.so.1.7.17 | grep -E 'asan|ubsan'      # libasan.so.8, libubsan.so.1
```

(All measured in `osvr-fnd03:1`.) That is the triple again, through a different door. In the challenge you will need it for many binaries, not one.

## Struggle challenge
Attempt this closed-book before reading further. Timebox: 75 minutes (pilot parameter; log your actual time before first hint). Write down what you tried, even if you fail. Run it as one protocol session (FND-01).

Closed-book means: no Theory or Walkthrough below. You may use `--help`, `man`, gdb's own `help`, and anything inside `/src/cjson` (its `README.md`, `CMakeLists.txt`, test sources).

**Task.** Build cJSON `v1.7.17` with **CMake** and debug its test suite.

1. **Build.** Copy `/src/cjson` to `/work/fnd03/cjson`. Configure an out-of-tree build in `/work/fnd03/cjson/build-asan` with tests enabled, in which every test program and the cJSON code inside it is built with ASan, UBSan, `-g`, `-O0` and `-fno-omit-frame-pointer`, and in which any UBSan finding aborts the program. The build must also write `compile_commands.json`: the checker reads the flags your build actually used from it. cJSON's own `README.md` offers a way to turn sanitizers on. Use whatever route you like, but your evidence (step 2) has to prove the result.
2. **Prove it.** In `/work/fnd03/challenge/evidence.txt`, for the test program `tests/parse_examples` and for the object file built from `cJSON.c` for the shared library: the compile command, the `nm` counts for `__asan_report` and `__ubsan_handle`, and the `ldd` lines for the sanitizer runtimes. If at any point a build you made did *not* have ASan, record that too, with the evidence that showed it and the reason you found.
3. **Test.** Run the whole suite with `ctest` and record the summary line.
4. **Debug.** Run `tests/parse_examples` under gdb and stop the **first** time `parse_number` (in `cJSON.c`) is entered. Write `/work/fnd03/challenge/answers.md` with exactly these four lines, filled in from gdb output:
   ```text
   test_function: <name of the Unity test function on the stack>
   input_file: <path of the JSON file being parsed>
   json_key: <the key whose value is being parsed>
   parsed_value: <the number stored in the node after parse_number returns>
   ```
   Then, under those lines, paste the gdb transcript that proves each answer, and list every location your breakpoint resolved to, saying which binary or library each lives in and which one was actually hit.
5. Check: `"$M/lab/check.sh" challenge` (on the host). It mounts your files read-only and never changes them. It checks the build, the instrumentation of every registered test executable and `libcjson.so`, that UBSan findings are fatal (it rebuilds a small UBSan tripwire with the flags your build actually used, taken from `compile_commands.json`), that every test passes, and your four answers. `PASS  ubsan fatal: tripwire built with the flags your build used exits 1 with a runtime error line` It has no stored answer key: it runs gdb on *your* `parse_examples` and compares. It does not tell you what is wrong beyond which check failed.

Success: `check.sh challenge` exits 0, and `evidence.txt` plus the transcript in `answers.md` would convince a sceptic without them rerunning anything.

## Theory
### A build is four steps, and flags belong to some of them
`gcc x.c -o x` hides four stages: preprocess (`#include`, `#define`), compile to assembly, assemble to an object file (`.o`), and link objects plus libraries into an executable or shared library. A build system runs these stages for many files, usually compiling each `.c` to its own `.o` and linking at the end.

Sanitizer flags act at two stages, and you need both:
- **At compile time**, `-fsanitize=address` makes the compiler insert a check before every load and store it emits, and `-fsanitize=undefined` inserts checks before arithmetic, shifts, array indexing and so on. These checks call into a runtime (`__asan_report_store1`, `__ubsan_handle_add_overflow`, ...).
- **At link time**, the same flag links that runtime library (`libasan.so.8`, `libubsan.so.1` here) and makes it start before `main`.

Get one without the other and you get a build that looks right and is not. Derived in the lab:

| Built how | `ldd` shows libasan | `nm` finds `__asan_report` | Heap overflow in `tripwire.c` |
|---|---|---|---|
| compile **and** link with `-fsanitize=address` | yes | yes | reported |
| compile without, link with `-fsanitize=address` | yes | 0 | not reported, exit 0 |
| compile with, link without | link fails: `undefined reference to '__asan_init'` | n/a | n/a |
| `-fsanitize=undefined` only | no (`libubsan` only) | 0 | not reported, exit 0 |

The second row is the dangerous one. The runtime is loaded, `ASAN_OPTIONS=help=1` works, and nothing is checked. That is why "is `libasan` linked?" is not enough evidence on its own.

`-g` is a compile-time flag (debug info goes into each `.o`). `-O0` and `-fno-omit-frame-pointer` are compile-time too. The Clang ASan docs recommend at least `-O1` for speed and `-fno-omit-frame-pointer` for good stack traces, and use `-g` in their example; OSVR uses `-O0` for the first builds of a target because every variable stays inspectable in gdb, and switches to `-O1` when speed matters (fuzzing, VD track). An ASan executable cannot be linked fully statically: gcc refuses `-static` with `cannot specify -static with -fsanitize=address` (derived; the Clang ASan docs also say static linking is unsupported). gcc has a separate `-static-libasan`, which links only the ASan runtime statically into a dynamically linked program; this module does not use it (needs-lab-verification: its behaviour in the lab).

### Make and CMake, as a researcher needs them
You need two things from any build system: where your flags enter, and how to see the command it really ran.

**Make** reads a `Makefile` of rules (`target: dependencies` then a recipe). Variables like `CFLAGS` are just text spliced into recipes. Two facts you saw in the worked example (derived from `make -n`):
- `make VAR=value` on the command line overrides every assignment to `VAR` inside the Makefile, including `+=`. Your flags go in, the project's additions to that variable go out.
- `make -n` prints commands without running them. `make -B` forces a rebuild even when files look up to date. Together, `make -B -n target` shows the full command for a target.

**CMake** is a generator. It runs in two phases:
1. **Configure** (`cmake -S <src> -B <builddir> -D...`): reads `CMakeLists.txt`, runs feature checks, and writes a build tree (Makefiles by default) plus a cache, `<builddir>/CMakeCache.txt`. `-DNAME=value` sets a cache variable. Options the project declares with `option(...)` are cache variables too.
2. **Build** (`cmake --build <builddir>`): runs the generated build. `cmake --build <builddir> -v` prints each real command.

Facts that cost beginners hours (all derived from cJSON's build in the lab):
- The cache persists. Re-running `cmake` with different `-D` values on an existing build directory keeps old cached results, including the results of feature checks. When you change compilers or sanitizer flags, use a **new build directory**.
- `CMAKE_C_FLAGS` is the standard way to add flags to every C compile and link in the project. The project may then append its own flags after yours, and for most gcc flags **the last one on the command line wins**. In cJSON, a `-Wno-error` you put in `CMAKE_C_FLAGS` is cancelled by the `-Werror` the project appends later.
- `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` writes `<builddir>/compile_commands.json`: one entry per compiled file with its exact command. This is the best single piece of evidence for "which flags did each object get".
- `CMAKE_BUILD_TYPE=Debug` adds `-g`. It does not add sanitizers and it does not set `-O0` explicitly (gcc's default is `-O0`).
- `ctest`, run inside the build directory, runs every test the project registered with `add_test`. Each test runs with its own working directory. Running a test binary by hand from somewhere else can fail for reasons that have nothing to do with the code.
- Feature checks are themselves small builds. With this lab's CMake (3.31.6) their logs go to `<builddir>/CMakeFiles/CMakeConfigureLog.yaml`. When a check fails, the log has the compiler's actual error.

> Sources (`resources.yaml`): the GNU make manual's *Overriding Variables* (command-line assignments win over the Makefile's, unless it uses `override`) and *Variables Used by Implicit Rules* (`CFLAGS`, `LDFLAGS`, `LDLIBS`); CMake's `CMAKE_<LANG>_FLAGS` (initialised from the `CFLAGS` environment variable), `CMAKE_EXPORT_COMPILE_COMMANDS` (Makefile and Ninja generators only), `cmake-configure-log(7)` (CMake 3.26 and later), `add_test` (tests run in `CMAKE_CURRENT_BINARY_DIR` unless `WORKING_DIRECTORY` is given) and `CheckCCompilerFlag`. One thing the docs do **not** say: `CheckCCompilerFlag` does not state whether the flag under test reaches the link step. That it does not, for cJSON's check with this CMake, is a lab observation from the configure log (Walkthrough, step 2).

### How ASan decides an access is bad: derive it from the code
FND-02 said ASan reports at the access by checking each access against marks around every object. Here is the mechanism, read straight from what the compiler emitted. Build the tripwire with ASan and disassemble `main` (`objdump -d -M intel --no-show-raw-insn tripwire`, or `disassemble` in gdb). The store `p[8] = 1` became (derived, gcc 14.2.0, `-O0`):

```text
lea    rcx,[rax+0x8]          ; rcx = address to write (p + 8)
mov    rax,rcx
mov    rdx,rax
shr    rdx,0x3                ; rdx = addr >> 3
add    rdx,0x7fff8000         ; rdx = (addr >> 3) + 0x7fff8000   <- shadow address
movzx  edx,BYTE PTR [rdx]     ; k = the shadow byte
test   dl,dl
setne  sil                    ; sil = (k != 0)
mov    rdi,rax
and    edi,0x7                ; addr & 7: position inside its 8-byte group
cmp    dil,dl
setge  dl                     ; (addr & 7) >= k
and    edx,esi
test   dl,dl
je     <do the store>         ; both false: access is fine
mov    rdi,rax
call   __asan_report_store1   ; otherwise: report and stop
mov    BYTE PTR [rcx],0x1     ; the original store
```

So, derived from this code:
- Every 8 bytes of application memory have **one shadow byte** at `(addr >> 3) + 0x7fff8000`. The report's legend says the same: "one shadow byte represents 8 application bytes". The constant is the shadow offset this gcc build uses on x86-64 Linux.
- Shadow `00` means all 8 bytes are addressable. A value `k` from 1 to 7 means only the first `k` bytes are ("Partially addressable: 01 02 ... 07" in the legend). Other values mark unaddressable memory, and the value says why: `fa` heap left redzone, `fd` freed heap region, `f1`/`f2`/`f3` stack redzones, `f9` global redzone (all from the report legend).
- For a 1-byte access, the check is "shadow non-zero **and** `(addr & 7) >= k`". For a 4-byte store the compiler emits the same sequence with an extra `add esi,0x3`: it tests the access's **last** byte, `(addr & 7) + 3 >= k` (derived from an `int` store). An access is bad if any byte it touches is beyond the addressable prefix.
- You can check the formula live. The rows of a report's shadow map are labelled with **application** addresses (`=>0x502000000000:`), not shadow addresses, so you compute the shadow address yourself. Measured in the lab at `break __asan_report_store1` on the tripwire: `addr` = `0x502000000018`, `p/x (addr >> 3) + 0x7fff8000` = `0xa047fff8003`, and `x/1xb 0xa047fff8003` reads `0xfa`. The shadow byte for the 8 valid bytes before it reads `0x00`.
- The allocator is ASan's own. It surrounds each heap block with redzones and marks them in shadow. `malloc(8)` gives shadow `00` then `fa`; `malloc(5)` gives `05` then `fa` (both derived; look for the `=>` line under "Shadow bytes around the buggy address" in your FND-02 report: `fa fa[05]fa`).

Now FND-02's blind spots follow from the mechanism instead of being a list to memorise. Intra-object overflow is invisible because the whole struct is one allocation with shadow `00`; there is no redzone between its members. A read of uninitialised heap memory is invisible because addressable-but-unwritten bytes have shadow `00` too (ASan only fills them with `0xbe`). And code compiled without `-fsanitize=address` has no check sequence at all, whatever runtime is linked.

> Sources (`resources.yaml`): the sanitizers project's *AddressSanitizerAlgorithm* page gives the same mapping for 64-bit, `Shadow = (Mem >> 3) + 0x7fff8000`, and describes the redzones. The lab disassembly and gdb above confirm that offset for this gcc build. The same page describes one more piece you will meet in use-after-free reports: on `free`, ASan poisons the block's shadow (`fd`, "Freed heap region") and holds the block in a **quarantine** queue for a while, so `malloc` does not hand the same memory out again at once and a later access to it is still caught.

### UBSan: checks at the operation, recovery by default
UBSan instruments operations whose behaviour C leaves undefined: signed overflow, out-of-range shifts, indexing past a declared array size, misaligned or null pointer use, and others (GCC Instrumentation Options lists the sub-checks). Each check calls a `__ubsan_handle_*` function when it fails. Two consequences:
- **It prints and keeps going by default.** GCC's docs say UBSan's checks recover by default, except `unreachable` and `return`, which never recover; for ASan recovery is off by default. Derived: a signed `INT_MAX + 1` built with `-fsanitize=undefined` prints `runtime error: signed integer overflow` and exits 0. With `-fno-sanitize-recover=undefined` (or the bare `-fno-sanitize-recover`) it exits 1. In a test suite, recovering means a finding scrolls past inside a passing test. Make it fatal.
- **It knows types, not allocations.** That is why it sees `r.buf[8]` (it knows `buf` is `char[8]`) and, in the `-O0` builds of this module, is silent about a heap block's end (there is no declared array type). ASan is the opposite. Use both. (GCC's `-fsanitize=object-size` check, part of `undefined`, can catch some overruns of objects whose size the compiler can work out, but only when optimising; needs-lab-verification: whether it fires on a heap off-by-one at `-O1` in the lab.)

### gdb, as a researcher uses it
gdb starts (or attaches to) a program under `ptrace`, the kernel interface that lets one process stop, inspect and modify another. Breakpoints, stepping and memory reads are all ptrace operations. The parts that matter in this module (behaviour observed in the lab; the gdb manual in `resources.yaml` is the reference):

- **A breakpoint is a set of locations.** `break NAME` resolves to every function called `NAME` in every loaded object. gdb shows `<MULTIPLE>` and numbers them `1.1`, `1.2`, ... Locations in a shared library appear only after it loads, so the count can grow after `run`. `break FILE:FUNCTION` restricts to functions defined in that source file. `info breakpoints` lists the locations and how many times the breakpoint was hit.
- **Ignore counts count without stopping.** `ignore 1 100000` then `run`: the program runs to the end, and `info breakpoints` reports `breakpoint already hit N times`. That is how you count calls.
- **Frames.** `bt` lists the call chain. `frame N` (or `up`/`down`) selects a frame so that `p`, `info locals` and `info args` show *that* function's variables.
- **Printing.** `p EXPR` evaluates C expressions (`p *item`, `p item->string`, `p input_buffer->content + input_buffer->offset`). `ptype` shows a type. `x/16c ADDR`, `x/s ADDR`, `x/8gx ADDR` dump memory as chars, a string or 8-byte hex words.
- **Leaving a function.** `finish` runs to the caller and prints the return value. `next` steps over calls, `step` steps into them.
- **Watchpoints.** `watch -l LVALUE` stops when that memory changes (FND-02 Drill 3).
- **ASLR in the lab.** gdb normally disables ASLR for programs it starts (`show disable-randomization`). That needs the `personality` system call, which the lab's default seccomp profile blocks, so gdb warns and runs with ASLR on (`labs/shared/fnd-base/README.md`, verified). Use `ASLR_OFF=1 "$M/lab/run.sh"` when you need the same addresses on every run.
- **LeakSanitizer and ptrace.** LSan runs at exit and refuses to work under a tracer; the process dies with exit code 1 even if everything passed. Under gdb, always set `ASAN_OPTIONS=detect_leaks=0`.

## Walkthrough (spoilers)
Reference solution for the struggle challenge, run in the lab on 2026-11-11.

**1. Try the documented route.** cJSON's `README.md` line 115 documents `-DENABLE_SANITIZERS=On`, "Compile cJSON with AddressSanitizer and UndefinedBehaviorSanitizer enabled (if possible)".

```sh
cp -a /src/cjson /work/fnd03/cjson && chmod -R u+w /work/fnd03/cjson && cd /work/fnd03/cjson
cmake -S . -B build-doc -DCMAKE_BUILD_TYPE=Debug -DENABLE_SANITIZERS=ON -DENABLE_CJSON_TEST=ON \
      -DCMAKE_C_FLAGS="-g -O0 -fno-omit-frame-pointer"
cmake --build build-doc -j4 && (cd build-doc && ctest | tail -3)
```

`100% tests passed, 0 tests failed out of 19`. This is exactly where research stopped (`research/targets/FND.md`: "Not verified: that ASan was actually active"). Now verify:

```sh
nm build-doc/tests/parse_examples | grep -c __asan_report     # 0
nm build-doc/tests/parse_examples | grep -c __ubsan_handle    # 11
ldd build-doc/tests/parse_examples | grep -E 'asan|ubsan'     # only libubsan.so.1
grep -o -- '-fsanitize[^ ]*\|-fno-sanitize-recover' build-doc/CMakeFiles/cjson.dir/flags.make
```

```text
-fsanitize=undefined
-fsanitize=float-cast-overflow
-fsanitize-address-use-after-scope
-fno-sanitize-recover
```

UBSan is in. ASan is not. The suite "passed with sanitizers" without AddressSanitizer.

**2. Find out why.** The flags come from `CMakeLists.txt` lines 64 to 76. Each one is tested before use (lines 98 to 106):

```cmake
foreach(compiler_flag ${custom_compiler_flags})
    string(REGEX REPLACE "[^a-zA-Z0-9]" "" current_variable ${compiler_flag})
    CHECK_C_COMPILER_FLAG(${compiler_flag} "FLAG_SUPPORTED_${current_variable}")
    if (FLAG_SUPPORTED_${current_variable})
        ...append to CMAKE_C_FLAGS...
```

The cache records the results:

```sh
grep -E 'FLAG_SUPPORTED_(fsanitize|01)' build-doc/CMakeCache.txt
```

```text
FLAG_SUPPORTED_01:INTERNAL=
FLAG_SUPPORTED_fsanitizeaddress:INTERNAL=
FLAG_SUPPORTED_fsanitizeaddressuseafterscope:INTERNAL=1
FLAG_SUPPORTED_fsanitizefloatcastoverflow:INTERNAL=1
FLAG_SUPPORTED_fsanitizeinteger:INTERNAL=
FLAG_SUPPORTED_fsanitizeundefined:INTERNAL=1
```

Empty means the check failed and the flag was dropped, silently. The configure log says why:

```sh
grep -n -A12 'FLAG_SUPPORTED_fsanitizeaddress"' build-doc/CMakeFiles/CMakeConfigureLog.yaml | grep -E 'fsanitize|undefined reference'
```

```text
/usr/bin/cc -DFLAG_SUPPORTED_fsanitizeaddress  -g -O0 -fno-omit-frame-pointer -std=c89 -pedantic ... -fno-omit-frame-pointer    -fsanitize=address -o CMakeFiles/cmTC_9c928.dir/src.c.o -c /work/fnd03/cjson/build-doc/CMakeFiles/CMakeScratch/TryCompile-2J66aZ/src.c
/usr/bin/cc -g -O0 -fno-omit-frame-pointer -std=c89 -pedantic ... -fno-omit-frame-pointer  -rdynamic CMakeFiles/cmTC_9c928.dir/src.c.o -o cmTC_9c928
.../src.c:1:(.text+0x10): undefined reference to `__asan_init'
/usr/bin/ld: .../src.c:1:(.text+0x15): undefined reference to `__asan_version_mismatch_check_v8'
collect2: error: ld returned 1 exit status
```

(`...` elides the long run of warning flags; the `cmTC_` and `TryCompile-` suffixes are random per configure.) Line 1 is the compile: `-fsanitize=address` is the last flag. Line 2 is the link: the same flags, **without** `-fsanitize=address`. The check compiled its test program **with** the flag and linked it **without**. That is row 3 of the table in Theory: an instrumented object linked without the runtime fails to link. CMake concluded that gcc does not support the flag. The other two failures are honest: `-01` is a typo for `-O1` (digit zero, not letter O; it was removed upstream before v1.7.18; from the pinned, detached checkout you need `git log --all -S'-01' -- CMakeLists.txt` to see the commits that added and removed it), and `-fsanitize=integer` is a Clang-only option (`research/targets/FND.md`).

**3. Build it properly.** Put the sanitizer flags in `CMAKE_C_FLAGS`, so they reach every compile **and** every link, including the feature checks. Use a new build directory: the old cache would keep its failed check results.

```sh
cmake -S . -B build-asan -DCMAKE_BUILD_TYPE=Debug -DENABLE_CJSON_TEST=ON -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
      -DCMAKE_C_FLAGS="-g -O0 -fno-omit-frame-pointer -fsanitize=address,undefined -fno-sanitize-recover=undefined"
cmake --build build-asan -j4
```

Leaving `ENABLE_SANITIZERS` off is deliberate: you no longer depend on the project's checks for the flags that matter.

**4. Prove it** (`evidence.txt`):

```sh
cd build-asan
grep -o '"command": "[^"]*parse_examples.c[^"]*"' compile_commands.json
grep -o '"command": "[^"]*cjson.dir/cJSON.c.o[^"]*"' compile_commands.json
nm tests/parse_examples | grep -c __asan_report                # 9
nm tests/parse_examples | grep -c __ubsan_handle               # 10
nm CMakeFiles/cjson.dir/cJSON.c.o | grep -c __asan_report      # 8
ldd tests/parse_examples | grep -E 'asan|ubsan|cjson'
```

```text
libasan.so.8 => /lib/x86_64-linux-gnu/libasan.so.8
libcjson.so.1 => /work/fnd03/cjson/build-asan/libcjson.so.1
libubsan.so.1 => /lib/x86_64-linux-gnu/libubsan.so.1
```

Plus the failed `build-doc` evidence from step 1 and the reason from step 2.

**5. Test.**

```sh
ctest | tail -3      # 100% tests passed, 0 tests failed out of 19
```

The suite is clean under real ASan and fatal UBSan at this commit. That does not mean the library is free of memory bugs: you already know of one the suite does not exercise.

**6. Debug.** Run from `build-asan/tests`, because that is the working directory `ctest` uses and the test opens `inputs/test1` and so on by relative path. From anywhere else, every file test fails (derived: from the build root, the run exits 1 with failing tests and a LeakSanitizer report).

```sh
cd /work/fnd03/cjson/build-asan/tests
ASAN_OPTIONS=detect_leaks=0 gdb -nx ./parse_examples
```

```text
(gdb) break cJSON.c:parse_number
Breakpoint 1 at 0x2d23f: file /work/fnd03/cjson/tests/../cJSON.c, line 306.
(gdb) run
Breakpoint 1.1, parse_number (item=0x506000000ec0, input_buffer=0x7f5943300240) at /work/fnd03/cjson/tests/../cJSON.c:306
(gdb) info symbol $pc
parse_number + 152 in section .text of /work/fnd03/cjson/build-asan/tests/parse_examples
(gdb) bt
#0  parse_number (...) at .../tests/../cJSON.c:306
#1  parse_value (...) at .../tests/../cJSON.c:1355
#2  parse_object (...) at .../tests/../cJSON.c:1683
   ... parse_value / parse_object, three levels of nesting ...
#8  cJSON_ParseWithLengthOpts (value=0x516000000980 "{\"widget\": {\n    \"debug\": \"on\",\n    \"window\": {\n ...", buffer_length=604, ...) at .../tests/../cJSON.c:1125
#9  cJSON_ParseWithOpts (...) at .../tests/../cJSON.c:1096
#10 cJSON_Parse (...) at .../tests/../cJSON.c:1182
#11 parse_file (filename=0x502000000590 "inputs/test3") at .../tests/parse_examples.c:36
#12 do_test (test_name=... "test3") at .../tests/parse_examples.c:76
#13 file_test3_should_be_parsed_and_printed () at .../tests/parse_examples.c:121
#14 UnityDefaultTestRun (...) at .../tests/unity/src/unity.c:1339
#15 main () at .../tests/parse_examples.c:258
(gdb) p item->string
$1 = 0x502000000690 "width"
(gdb) x/8c input_buffer->content + input_buffer->offset
0x516000000a0f:	53 '5'	48 '0'	48 '0'	44 ','	10 '\n'	32 ' '	32 ' '	32 ' '
(gdb) finish
Value returned is $2 = 1
(gdb) p item->valuedouble
$3 = 500
(gdb) info breakpoints
1       breakpoint     keep y   <MULTIPLE>
	breakpoint already hit 1 time
1.1                         y   0x000055a18915d23f in parse_number at /work/fnd03/cjson/tests/../cJSON.c:306
1.2                         y   0x00007f89aecfe262 in parse_number at /work/fnd03/cjson/cJSON.c:306
```

`answers.md`:

```text
test_function: file_test3_should_be_parsed_and_printed
input_file: inputs/test3
json_key: width
parsed_value: 500
```

Why not test1? `test1` and `test2` are parsed first, but they contain no JSON numbers; `test3`'s `"width": 500` is the first. Only the debugger tells you that quickly.

**Why the breakpoint has two locations.** `tests/common.h` line 26 is `#include "../cJSON.c"`, and every Unity test source includes `common.h` (all except `unity_setup.c`, derived with `grep -L`). So each test program compiles its **own copy** of the whole library, which lets it test `static` functions, and it also links `libcjson.so`. Location 1.1 is the copy inside `parse_examples`, 1.2 is the one in `libcjson.so.1`, and the stop happened at 1.1 (`info symbol $pc` names `.../tests/parse_examples`). The test code calls its own copy. Consequence for step 2: the evidence that matters for the tests is instrumentation **inside the test executable**. A sanitized `libcjson.so` alone would not have covered them.

If you wrote `break parse_number` without the file, `info breakpoints` at the first stop lists more locations in `sanitizer_common_interceptors_format.inc`: the sanitizer runtime has its own internal `parse_number`. On the reference `build-asan` the audit measured 8 locations in total: 1.1 in the executable, 1.2 in `libcjson.so.1`, 1.3 to 1.8 in the runtime. Do not memorise the count; it depends on the runtime build. With an ignore count, `break parse_number` counted 74 hits in a full run of `parse_examples` and `break cJSON.c:parse_number` counted 62 (derived). The 12 extra were not cJSON. Always scope a breakpoint when the name is common.

## Consolidation
Put your `evidence.txt` and `answers.md` next to the walkthrough. For each subgoal (Pin, Recon, Inject, Verify, Test, Debug), write three short lines: what you did, what the reference does, and the gap in one line. Typical gaps worth a card:
- Trusting "100% tests passed" from the `ENABLE_SANITIZERS` build without checking for ASan.
- Checking only `ldd` (runtime linked) and never `nm` (code instrumented).
- Reconfiguring the same build directory and keeping a stale cache.
- Running `parse_examples` from the wrong directory and debugging a "failure" that is a missing input file.
- `break parse_number` landing in the ASan runtime, or being confused by `<MULTIPLE>`.
- Leaving UBSan recoverable, so a finding cannot fail a test.
- gdb exiting with code 1 at the end because LeakSanitizer ran under ptrace.

Add each gap with `python3 scripts/srs.py add ...`, and log time-to-first-hint (or "none") in your session log.

## Common failure points
| Symptom | Likely cause | How to see it (command) |
|---|---|---|
| "Sanitizers on", tests pass, but `nm prog \| grep -c __asan_report` is 0 | The flag never reached the compile (dropped by a feature check, overridden, or added only at link) | `grep FLAG_SUPPORTED_ build/CMakeCache.txt`; read the command in `compile_commands.json` or `cmake --build build -v` |
| `ldd` shows `libasan` but a known overflow is not reported | Runtime linked, code not instrumented (compiled without `-fsanitize=address`) | `nm prog \| grep -c __asan_report` (0); check the object's own compile command |
| Link error `undefined reference to '__asan_init'` | Objects compiled with `-fsanitize=address`, final link without it | `cmake --build build -v` and read the link line. Put the flag in `CMAKE_C_FLAGS` (compile and link) |
| Every `cmake` configure of cJSON prints `CMake Deprecation Warning at CMakeLists.txt:2 (cmake_minimum_required):` followed by `Compatibility with CMake < 3.10 will be removed from a future version of ...` (measured) | cJSON declares an old minimum CMake version | Harmless here. It is a warning, not an error, and changes nothing in the build |
| `mkdir: cannot create directory '.../build': Permission denied` right after `cp -a /src/cjson ...`, or hundreds of `Permission denied` lines from `rm -rf` on an old copy | `/src/cjson` is made read-only in the image, `cp -a` preserves those modes, and `run.sh` drops all capabilities, so even root cannot write to a mode `r-x` directory | `chmod -R u+w <copy>` straight after every copy, and before removing an old copy |
| Changed `-D...` flags, nothing changed | Old cache in the build directory | Use a new `-B` directory, or delete it. `grep CMAKE_C_FLAGS: build/CMakeCache.txt` |
| Build fails with `-Werror=...` after adding flags (for example `null destination pointer [-Werror=format-overflow=]` at `-O2` with sanitizers, derived) | The project's `-Werror` turns a new warning into an error; your `-Wno-error` comes earlier on the command line and loses | Read the full command. Turn off the project's warning flags (cJSON: `-DENABLE_CUSTOM_COMPILER_FLAGS=OFF`) instead of fighting the order |
| A test binary fails when run by hand but passes in `ctest` | Wrong working directory (relative input paths) | `ctest -V -R parse_examples` shows the command and directory ctest uses |
| gdb run ends with `LeakSanitizer has encountered a fatal error ... does not work under ptrace`, exit code 1 | LSan at exit under a tracer | Start gdb with `ASAN_OPTIONS=detect_leaks=0` |
| ASan report printed under gdb, then `No stack.` | ASan exits after reporting | `ASAN_OPTIONS=abort_on_error=1`, or `break __asan_report_store1` (list candidates with `nm prog \| grep __asan_report`) |
| `warning: Error disabling address space randomization: Function not implemented` | The default seccomp profile blocks `personality` | Harmless. If you need fixed addresses: `ASLR_OFF=1 "$M/lab/run.sh"` |
| Breakpoint shows `<MULTIPLE>`, or stops somewhere unexpected | The name exists in several objects (test copy, shared library, sanitizer runtime) | `info breakpoints`, `info symbol $pc`; use `break FILE:FUNCTION` |
| `Function "parse_number" not defined in "cJSON.c".` at `-O2`; `break cJSON.c:306` gives `No compiled code for line 306` (measured) | The function was inlined into its callers, so there is no out-of-line copy to break on, and its first line has no code of its own | Break on a later line inside it (in the lab `break cJSON.c:308` works and shows `parse_number` as an inline frame), or rebuild at `-O0` for debugging |
| `nm` says `no symbols` | The binary is stripped | `nm -D` still lists the sanitizer imports (`__asan_report_*`, `__ubsan_handle_*` are dynamic symbols); `ldd` still shows the runtimes |
| `No symbol "item" in current context` | You are in the wrong frame | `bt`, then `frame N` |
| gdb prints a colour context pane and the transcript looks nothing like the text | GEF is loaded from `/etc/gdb/gdbinit` | `gdb -nx` |
| `git` says "dubious ownership" in `/work/fnd03` | Copy owned by a different UID than the one git runs as | `git config --global --add safe.directory '*'` inside the container |
| `ReserveShadowMemoryRange failed` at start | A virtual-memory ulimit (FND-01) | `ulimit -v` |

## Next
Drills: `drills.md`. Project: `project.md`. Cards: import with `python3 scripts/srs.py import FND-03-building-and-debugging-with-gdb-and-sanitizers`.

FND-04 hands you a codebase you have not seen, a published crash and nothing else. Everything in this module (pin, recon, inject, verify, test, debug) is its first hour.
