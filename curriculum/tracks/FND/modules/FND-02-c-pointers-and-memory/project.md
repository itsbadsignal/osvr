# Project: FND-02-c-pointers-and-memory

## Target
Real artefact: **iperf3 CVE-2025-54349**, off-by-one heap overflow in authentication (CWE-193, MITRE record; advisory GHSA-8xx8-qrh3-q8mq).
Repository: `https://github.com/esnet/iperf.git` (`research/targets/FND.md`).
Version: vulnerable at commit `4eab661da0bbaac04493fa40164e928c6df7934a`, the parent of the fix. Fix: commit `4e5313bab0b9b3fe03513ab54f722c8a3e4b7bdf`, "Fix off-by-one heap overflow in auth", by Sarah Larsen, reported by Han Lee (Apple Information Security) per the commit message (`research/targets/FND.md`).

**Do not be confused by the parent commit.** `4eab661d` is not an ordinary commit that happens to precede the fix. It is itself a security fix for a *different* CVE: its message names CVE-2025-54350, and it only removes `#include <assert.h>` and one `assert` in `Base64Decode` (lab notes, `lab/SPEC.md`). It still contains the CVE-2025-54349 off-by-one, which is why it is the pinned vulnerable version. If `git show 4eab661d` shows you an assert removal, you are looking at the right commit.

**Which releases are fixed.** The MITRE record describes the bug as affecting iperf3 "before 3.19.1". The GitHub advisory lists the affected and patched versions as "Unknown" but links release 3.19.1 (`research/targets/FND.md`). The lab's git evidence agrees. Tag `3.19.1` contains the fix as a cherry-pick, `42280d2292ed5f213bfcb33b2206ebcdb151ae66`, whose diff to `src/iperf_auth.c` is identical to `4e5313ba` (same `git patch-id`). In `3.19.1` the fixed allocation `OPENSSL_malloc(keysize + 1)` is at line 313. Tag `3.19` still has `OPENSSL_malloc(keysize)`. One trap: `git tag --contains 4e5313ba` lists 3.20, 3.21 and 3.22 but **not** 3.19.1, because a cherry-pick is a different commit. That is a false negative. Variation 4 has you reproduce this evidence yourself.

Lab: `lab/` (see `lab/README.md` and `lab/SPEC.md`). The image `osvr-fnd02:1` has a full iperf clone in `/src/iperf`, checked out at the fix, with both commits and all tags available. You read and diff iperf in `osvr-fnd02:1`. In step 6 you build and run iperf's auth code against your own harness, in `osvr-fnd02-iperf:1`.
Mitigations on: in your own reproduction, ASan + UBSan for the report; the lab gcc's defaults (PIE, NX, partial RELRO, **no** stack protector) versus a weak build for the `readelf` comparison. Nothing is exploited.

The project goes from model to real thing in three moves. First you root-cause the bug from the fix diff, to the line. Then your own small program reproduces the *same pattern* under ASan, so you know exactly what report to expect. Last, you trigger **the real bug in iperf's own code**. A short harness of your own calls the real `decode_auth_setting`, linked against iperf's `iperf_auth.c` built with ASan, at the vulnerable commit and at the fix. (iperf's shipped `t_auth` test does not reach the off-by-one on this lab's OpenSSL 3.5; see Overlearning stretch. Your harness takes a direct route.)

## Goal
Done when:
1. `rootcause.md` names, from the diff alone, the allocation line and the write line in the vulnerable commit, the CWE, the broken inequality, and what the extra byte lands on.
2. Your program `repro/repro.c` reproduces the pattern, and `"$M/lab/check.sh"` exits 0. That requires a `heap-buffer-overflow`, a `WRITE of size 1`, `0 bytes after` a block of your chosen key size, the write in a **different function from the allocation** (as in iperf), and a clean run with `-DFIXED`.
3. Your harness `realbug/harness.c` makes the real iperf code report the bug, and `"$M/lab/check.sh" realbug` exits 0. That requires a `heap-buffer-overflow`, `WRITE of size 1` at `decode_auth_setting iperf_auth.c:390` in the build at `4eab661d`, and no AddressSanitizer report with exit status 0 in the build at `4e5313ba`.
4. `hardening.md` reports the `readelf` facts for `repro` built with default flags and built weak on purpose.

## Constraints
- Closed reading first. Read only the diff and the two files at the two commits (`git show`, `git show <commit>:src/iperf_auth.c`) until `rootcause.md` has a first draft. Then read the advisory (`resources.yaml`) and correct the draft. Keep both versions.
- Do not modify iperf's source. You build only what `IPERF=1 "$M/lab/build.sh"` builds, and link your harness against it.
- `repro.c` must be your own code, under 60 lines, plain C, libc only (no OpenSSL). Simulate the decrypt step with a function that fills a caller-visible buffer and returns a length.
- All line numbers you cite must come from `git show <commit>:src/iperf_auth.c | cat -n` or `git blame` in the lab, not from this file or a web page.
- zsh users: write `git show "${C}:src/iperf_auth.c"` with braces. In zsh, `$C:s...` is read as a history modifier and mangles the path.

## Steps
1. **Read the diff.** `cd /src/iperf && git show 4e5313bab0b9b3fe03513ab54f722c8a3e4b7bdf -- src/iperf_auth.c`. List every hunk. For each, write one line: memory-safety fix, error-handling fix, or hygiene.
2. **Read the vulnerable code whole.** `git show 4eab661da0bbaac04493fa40164e928c6df7934a:src/iperf_auth.c | cat -n | less`. Find `decrypt_rsa_message` and `decode_auth_setting`. Answer in writing:
   - How many bytes does the block `*plaintext` own? Where is that number decided?
   - What value can `plaintext_len` have when `decrypt_rsa_message` returns? Look at both `#if OPENSSL_VERSION_MAJOR` branches, at what is assigned *before* the decrypt call, and at whether the decrypt call's return value is checked. Then read the OpenSSL `EVP_PKEY_decrypt` man page (`resources.yaml`) and answer from its contract:
     - What must `*outlen` hold before the call, and what does it hold after a *successful* call?
     - What does the page promise about `*outlen` after a *failed* call? (Nothing. So any use of `plaintext_len` after an unchecked failure relies on behaviour the API does not define.)
     - Does the call add a NUL terminator? (No: the output is raw bytes. That is why the caller writes one.)
     - Which padding does iperf pass? Read the `padding` lines at `4eab661d` yourself and say which value is used when `use_pkcs1_padding` is 0 and when it is 1. The man page notes that since OpenSSL 3.2.0, PKCS#1 v1.5 decryption in the default provider uses *implicit rejection*: on bad padding it returns a pseudo-random message instead of an error. Say what that changes about which inputs make `plaintext_len` large, for the padding iperf actually uses.
   - In which function, on which line, is the terminator written? With what index?
   - The comparison `plaintext_len < 0` is applied to a variable of type `size_t` inside `decrypt_rsa_message`. What can it ever evaluate to? (Do not chase this further. It is FND-05's topic. Note it.)
3. **Name the invariant.** Write the inequality the code needed and the value that breaks it.
4. **Locate the reach.** `git grep -n decode_auth_setting 4eab661da0bbaac04493fa40164e928c6df7934a -- src`. Which component calls it, and with data from where? State only what the code shows. Mark anything about who can send that data, and before what check, as your inference.
5. **Reproduce the pattern.** Write `~/osvr-work/fnd02/project/repro/repro.c`: one function allocates `KEYSIZE` bytes and returns a length that can equal `KEYSIZE`, and a *different* function (the caller) writes the terminator at that length. `-DFIXED` must apply the upstream-style fix. Before running it, write the expected ASan report in `repro/predicted.txt`. Then run `"$M/lab/check.sh"`.
6. **Trigger the real bug.** Build the iperf image with `IPERF=1 "$M/lab/build.sh"` (about 30 s to 3 min on top of `osvr-fnd02:1`, depending on your network). In `osvr-fnd02-iperf:1`, `/src/iperf-vuln/src` is iperf at `4eab661d` and `/src/iperf-fixed/src` is iperf at `4e5313ba`. Each tree has a prebuilt, ASan-instrumented `iperf_auth.o`. Then write `~/osvr-work/fnd02/realbug/harness.c`, about 15 lines, that (spoiler warning: `lab/tests/realbug/good/` holds the checker's reference harness; do not open it before you pass):
   - loads iperf's test key `private.pem` (read `src/t_auth.c` to see how iperf's own test loads its keys and builds a token);
   - builds an authentication token that **cannot** be decrypted: base64 of 256 bytes of `'A'`;
   - calls `decode_auth_setting(0, token, key, &user, &pass, &ts, 0)` and prints its return code.

   Before you run anything, write in `realbug/predicted.txt` what ASan will report at each commit, what return code your harness will print at the fix, and why the undecryptable token reaches line 390 with `plaintext_len == keysize` (step 2). To try your harness, run inside the iperf image:

   ```sh
   /opt/osvr/fnd02/tools/realbug.py vuln  harness.c     # builds against /src/iperf-vuln/src and runs it
   /opt/osvr/fnd02/tools/realbug.py fixed harness.c     # same against /src/iperf-fixed/src
   ```

   The helper uses exactly this build line and environment, which you can also run by hand (`TREE` is one of the two `src` directories):

   ```sh
   gcc -g -O1 -fsanitize=address -fno-omit-frame-pointer -I"$TREE" harness.c "$TREE/iperf_auth.o" -lssl -lcrypto -o harness
   ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 ./harness
   ```

   `fast_unwind_on_malloc=0` matters. Without it, the allocation stack in the report stops at OpenSSL's `CRYPTO_malloc` and you cannot see which iperf function allocated the block. `realbug.py` prints to the terminal only. Keep your own evidence by saving each run yourself, e.g. `/opt/osvr/fnd02/tools/realbug.py vuln harness.c > report-vuln.txt 2>&1` (and the same with `fixed` into `report-fixed.txt`). These files are not graded. What to expect, in outline: at the vulnerable commit ASan aborts the process (exit 1) before your harness prints its return code. At the fix, your harness prints the code and exits 0. Grading is `"$M/lab/check.sh" realbug` on the host: it compiles and runs your `harness.c` itself, read-only, with no network. If you get stuck, use the hint ladder (`/coach`). Do not look for a ready-made harness.
7. **Harden-check.** Build `repro.c` with defaults and with `-fno-stack-protector -no-pie -Wl,-z,norelro -D_FORTIFY_SOURCE=0`, and fill the table in `hardening.md` from `readelf` (README, worked example Subgoal 6). Check it against `"$M/lab/check.sh" hardening`, which prints the lab's own readings. Then run both *without* ASan and record what happens. Explain the result using `malloc_usable_size` (Variation 2 goes further). Expect a surprise if you learnt C hardening from a tutorial: on this toolchain neither build has a canary.
8. **Write** `feynman.md` and `advisory.md`.

## Deliverables
All in `~/osvr-work/fnd02/project/`, except item 3, which lives at `~/osvr-work/fnd02/realbug/` because that is where `check.sh realbug` looks. Submit with `/submit FND-02-c-pointers-and-memory`.
1. `repro/repro.c` and `repro/predicted.txt`: passes `lab/check.sh`. Commented by role: "allocates", "fills", "terminates".
2. `rootcause.md`: file, function and line for the allocation and for the write, both at `4eab661d`. CWE-193 and why that class (rather than plain CWE-787). The inequality and the breaking value. What the extra byte lands on in an ASan build versus a normal glibc build, with a typical RSA key size as the worked number. The reach from step 4, with inference marked. Draft and post-advisory versions.
3. `realbug/harness.c` and `realbug/predicted.txt`: `harness.c` passes `check.sh realbug`. Optionally keep `report-vuln.txt` and `report-fixed.txt`, saved yourself as ungraded evidence.
4. `hardening.md`: the four-property `readelf` table (PIE, NX, RELRO/BIND_NOW, canary) for both builds, each cell with the command output line that proves it, and the non-ASan run result with its explanation.
5. `feynman.md`: under 400 words (see below).
6. `advisory.md`: a mini-advisory written as if you were the reporter, with these headings: Summary, Affected component and versions (cite the advisory, mark unverified items), Impact (only what the code shows, inference marked), Root cause, Reproduction (your real-bug harness against the real code, with `repro.c` as the minimal model), Suggested fix, References.

## Feynman task
In `feynman.md`, under 400 words, explain to a smart non-specialist (a friend who runs servers but never wrote C):
- what a C string is and why it needs one byte more than its length;
- what iperf3 did with the decrypted text and where the extra byte went;
- why the program usually did not crash, and why that does not make it safe;
- what the one-token fix changes.
No jargon without a plain explanation in the same sentence. If you need the words "heap", "buffer" or "NUL", define them when you first use them.

## Variations (experimentation)
- [ ] **Different region (primitive).** Move the buffer in `repro.c` to the stack (`unsigned char pt[KEYSIZE]` in the allocating function's caller) and to a global. Predict, then compare, all ASan fields. Without ASan, use gdb to say what the stray byte overwrote in each case.
- [ ] **Remove the safety net.** Write a small harness without sanitizers. For each pair `i`, allocate a `KEYSIZE` block `p[i]` and then a neighbour `q[i]` of the same size, and write `p[i][KEYSIZE] = 0`. Then free **all the `p`s first, then all the `q`s**, in that order. Run it with 1 pair and with 10 pairs (10 is enough to fill the allocator's per-size cache, the tcache, so later frees take a different path). For `KEYSIZE` in {8, 24, 25, 40, 128, 256, 264, 384, 512}: first print `malloc_usable_size(p[0])` and predict, for each size, whether the NUL lands in slack or on the neighbour's size field. Then predict whether glibc will notice, run both versions, and record exactly what is printed and the exit status. Connect the results to the `poison_null_byte` note in the README. When you are done, compare your harness with the reference `/opt/osvr/fnd02/src/freeorder.c` (`gcc -g -O0 freeorder.c -o freeorder && ./freeorder KEYSIZE [PAIRS]`, 10 pairs by default, same free order).
  <details><summary>Lab results (open after your own run)</summary>

  Measured on the lab image (glibc 2.41) with `freeorder.c`, plain `gcc -g -O0`, all `p`s freed and then all `q`s:
  - 8, 25, 128, 256, 384, 512: no abort (prints `all freed, no abort`), exit 0. The usable size is larger than `KEYSIZE`, so the NUL lands in slack.
  - 24 and 40 (usable size equals `KEYSIZE`, so the NUL lands on the neighbour's size field): 1 pair gives `free(): invalid pointer` (the neighbour's size became 0). 10 pairs give `free(): invalid next size (fast)`. Both abort with exit 134.
  - 264 (usable size equals 264): 1 pair is silent. 10 pairs give `double free or corruption (!prev)`, exit 134.

  The rule: the outcome depends on whether the byte is slack or metadata, **and** on whether the damaged chunk is later freed through a path that checks it. Explaining each message is BX material. Write down your best guess now and revisit it there. Then modify the program (yours or a copy of `freeorder.c`, which has no such mode) to free alternately, `p[0], q[0], p[1], q[1], ...`, and predict before running. Measured in the lab: 24 and 40 give `free(): invalid pointer` at both 1 and 10 pairs, exit 134. 264 is silent at 1 pair and gives `double free or corruption (!prev)` at 10 pairs. All other sizes are silent. "Silent" means `freeorder` prints `all freed, no abort` and exits 0. So the order changes the message only for 24 and 40.
  </details>
- [ ] **Sanitizer blind spot.** Put the plaintext buffer inside a struct, `struct msg { unsigned char pt[KEYSIZE]; int authenticated; };`, and write the terminator at `pt[KEYSIZE]`. Which tool reports it, ASan or UBSan? Which field changes value? Then do it through an `unsigned char *` and say whether that changes the answer.
- [ ] **Verify a version claim yourself.** In `/src/iperf`, show that the 3.19.1 release contains the fix even though `git tag --contains 4e5313ba` says it does not. Use `git show 3.19.1:src/iperf_auth.c | grep -n 'OPENSSL_malloc(keysize'` (compare with tag `3.19`), `git log --oneline 3.19..3.19.1 -- src/iperf_auth.c`, and `git patch-id --stable` on both fix commits' diffs to prove that the patches are identical. Report the result in `advisory.md`, under References, with the commands, as evidence you verified yourself. Expected: the cherry-pick `42280d2…` (Target section). If your clone disagrees, report that instead.

## Overlearning stretch
**Variant analysis on the real codebase.** At commit `4eab661d`, audit every function in `src/iperf_auth.c` and the authentication call site in `src/iperf_api.c` for the same class: each allocation whose size is derived from a length, and each write or read indexed by a length. For each site, write the size, the maximum index, and safe/bug with the inequality. Pay attention to the `calloc(plaintext_len, ...)` buffers that `sscanf` writes into in `decode_auth_setting`. Are they always big enough for what `%s` can write? Argue it from the format string and `plaintext_len`.

**Harder: the shipped test.** The iperf image from step 6 (`osvr-fnd02-iperf:1`) also builds iperf's own test programs. The lab-engineer found that iperf's own `t_auth` test **does not reproduce CVE-2025-54349**. It fails the same way at both commits, with OpenSSL 3.5 reporting `output buffer too small`, followed by an ASan heap-buffer-overflow **READ** in `calcDecodeLength` (`iperf_auth.c:133`), a different bug in a different function. Pick one:
- **Diagnose the test failure.** Why does the shipped encrypt/decrypt round trip fail on OpenSSL 3.5? Then root-cause the `calcDecodeLength` read from its ASan report the way you root-caused the off-by-one: allocation, access, inequality. Before you call it a new bug, check whether it still exists at the newest commit in the clone, and whether it only happens on this failure path. If you believe you have found an unreported bug, stop and take it to `/coach`: disclosure is PRO-track work, and nothing goes upstream from this module.
- **Second route to the real bug.** Your step-6 token makes the decrypt *fail*. Find an input that makes the decrypt *succeed* with exactly `keysize` bytes of output, reaching the same line 390 by the honest path. Is that possible with the padding iperf uses by default, and with `use_pkcs1_padding = 1` under implicit rejection? Argue it from the man page first, then test it with your harness.

Submit with `/submit FND-02-c-pointers-and-memory`.
