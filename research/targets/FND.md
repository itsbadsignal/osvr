# Target shortlist: FND (vertical slice FND-01 to FND-04)

Researched: 2026-11-10   Mode: BUILD   Builds: rootless podman 6.1.4 on the maintainer's machine, image `debian:trixie` (Debian 13, gcc 14.2.0), pulled from docker.io 2026-11-10. Docker itself is not installed; the Dockerfiles are equivalent.

## Query plan (written before searching)
1. Which small, patched C memory-safety CVEs have a public advisory, a locatable fix commit, a public or derivable crashing input?
2. Which of them build and crash under ASan in a current Debian container, and how much code must the learner read?
3. Which have the shortest, most readable diffs (FND-02 reading material)?
4. Which small codebase has a test suite and builds with sanitizers (FND-03)?
5. Is there an honest D1 artefact for FND-01?

Method: CVE records fetched from the CVE Services API (`https://cveawg.mitre.org/api/cve/<id>`, the MITRE record), GitHub advisories and issues fetched, upstream repositories cloned and diffs read locally, builds and crashes run in podman. Search-engine snippets were used only as leads; every claim below was re-checked against a fetched primary source unless marked unverified.

## Summary ranking for FND-04

| Rank | Target | CVE | Class | Fix size | Trigger | Built + crashed 2026-11-10 |
|---|---|---|---|---|---|---|
| 1 | TinyDir 1.2.5 | CVE-2023-49287 | stack buffer overflow (CWE-120/121) | 1 line | one command-line argument, no harness | yes, ASan stack-buffer-overflow |
| 2 | libmodbus (parent of fix commit) | CVE-2022-0367 | OOB write via unchecked signed index (CWE-119; see note) | 1 line | 19-byte TCP request to the project's own test server | yes, ASan SEGV at modbus.c:980 |
| 3 | cJSON 1.7.17 | CVE-2023-53154 | heap OOB read (CWE-125) | 5 lines | 7-byte buffer to `cJSON_ParseWithLength` via a 6-line harness | yes, ASan heap-buffer-overflow |
| 4 | stb_image.h (pre 86b7570) | CVE-2021-28021 | global OOB read (JPEG) | 2 lines | crafted JPEG, PoC is a zip attachment | no (not built; PoC not fetched) |

Why TinyDir first: the learner runs `./sample $(long string)` and gets a textbook ASan stack report, the bug is a single `strcpy` into a buffer declared one `#define` too small, the diff is one token, and the whole library is one 838-line header at 1.2.5 (848 on master). Why not cJSON or libmodbus first: cJSON needs a harness the learner must write; libmodbus needs a server plus a client and the report is a SEGV rather than the labelled "buffer-overflow" report, which is a worse first read of an ASan report.

Cross-module allocation I recommend (the architect may reject): FND-01 = cJSON CVE-2023-53154 smoke test; FND-02 = reading diffs (iperf, libmodbus diff, cJSON diff); FND-03 = cJSON v1.7.17 build and debug; FND-04 = TinyDir (primary), libmodbus (variation or second CVE). This keeps the FND-04 bug unspoiled by earlier modules; the cost is that cJSON appears in three modules (familiarity benefit, spoiler risk for the CVE-2023-53154 diff, which FND-02 should therefore not use if cJSON is also the FND-01 smoke test; see FND-02).

---

## FND-04 candidates

### 1. TinyDir 1.2.5, CVE-2023-49287 (TOP PICK)
- Advisory: GitHub Security Advisory GHSA-jf5r-wgf4-qhxf, "Buffer overflow vulnerabilities in tinydir" (fetched 2026-11-10). Affected <= 1.2.5, patched 1.2.6, CVSS 7.7, credit @0xdea. The advisory contains its own reproduction recipe (compile `samples/file_open_sample.c` with ASan, pass a very long path). It lists three overflow sites in `tinydir_file_open()`: two Windows-only, one POSIX (`strcpy` of the path into `file_name_buf`, line 711 in 1.2.5). The learner reproduces the POSIX one only.
- MITRE record fetched 2026-11-10: CVE-2023-49287, published 2023-12-04, CWE-120 and CWE-121.
- Pinned vulnerable: git tag `1.2.5` = `4acafe7916720645bf65e19be8603acfe7acdba1` (repo `https://github.com/cxong/tinydir`).
- Fix commit: `8124807260735a837226fa151493536591f6715d` "Fix buffer overflow in tinydir_file_open with long path names", 2023-12-02, contained in tag 1.2.6 (`6ba79293a5e4ea015343e20453b4f4595c644515`). The advisory page itself does not name the commit; I identified it from the git history (`git log 1.2.5..1.2.6`) and its message and diff match the advisory. The whole functional change in `tinydir.h` is:
  `_tinydir_char_t file_name_buf[_TINYDIR_FILENAME_MAX];` becomes `... file_name_buf[_TINYDIR_PATH_MAX];` (256 to 4096 bytes). It also adds a regression test (`tests/file_open_test.c`).
- Size: `tinydir.h` 838 lines at tag 1.2.5 (wc -l, identical at the fix commit and 1.2.6; the earlier 848 was the line count of master, 1.2.6-2-ga4a2db5, corrected 2026-11-11), header only, no dependencies beyond libc.
- build: VERIFIED 2026-11-10 in `debian:trixie` (gcc 14.2.0, `apt install gcc git`):
  ```
  git clone https://github.com/cxong/tinydir && cd tinydir && git checkout 1.2.5
  gcc -g -O0 -fsanitize=address,undefined -fno-omit-frame-pointer -I. samples/file_open_sample.c -o s_vuln
  ./s_vuln "$(python3 -c 'print("A"*600)')"
  ```
  Result: `AddressSanitizer: stack-buffer-overflow ... WRITE of size 601`, frame `#0 strcpy (ASan interceptor)`, `#1 tinydir_file_open tinydir.h:711`, `#2 main samples/file_open_sample.c:12`, "located in stack of thread T0 at offset 304 in frame ... tinydir_file_open tinydir.h:641". At the fix commit the same input returns "No such file or directory" with no ASan report.
- Trigger: any path argument of length 256 to 4095 (the function rejects >= `_TINYDIR_PATH_MAX` earlier, which is itself a good "why is it this range" exercise).
- CWE: CWE-121 (stack-based buffer overflow) under CWE-120; root cause is a size mismatch between a destination declared for a file name and a source that is a whole path.
- Beginner fit: excellent. Root cause visible from the frame line to the declaration 70 lines above. Rate-determining step (ASan frame to violated invariant) is exercised directly: the invariant is "strlen(path) < sizeof(file_name_buf)", broken because the guard at the top of the function compares against `_TINYDIR_PATH_MAX` while the destination was sized by `_TINYDIR_FILENAME_MAX`.
- Public writeup exists for feedback (the advisory and the credit to @0xdea; a Packet Storm entry "TinyDir-1.2.5 Buffer Overflow" is referenced from the CVE record, not fetched). Learner can reproduce without it.
- Legal and safe: local library, local sample program.
- Caveats: stack protector and FORTIFY are not what the learner is studying here; ASan detects the write before any canary matters. Without ASan the same input on a distro-default build would hit `__stack_chk_fail` or silently corrupt: a good "why do we need sanitizers" demonstration (D9: state that ASan is detection, not mitigation; needs-lab-verification for the exact no-ASan behaviour, I did not run it).
- Variation ideas for project.md: find the other two overflow sites by reading (Windows `#if` branches) and explain why they cannot be reproduced on Linux; write the regression test; find what path length is the minimum that crashes (256 plus alignment slack).

### 2. libmodbus, CVE-2022-0367
- Sources fetched 2026-11-10: MITRE record CVE-2022-0367 (published 2022-08-29, "heap-based buffer overflow flaw ... in function modbus_reply() in src/modbus.c", CWE-119, "Fixed in v3.1.7"); upstream issue `https://github.com/stephane/libmodbus/issues/614` (reporter AiDaiP, 2021-12-22, two base64 PoCs, ASan confirmation by JonasToth, closed 2022-01-08).
- Pinned vulnerable: `bd1c85f2d39cba13c031f019b005f564cf799f3e` (= `git describe` v3.1.6-21-gbd1c85f, the parent of the fix). Repo `https://github.com/stephane/libmodbus`.
- Fix commit: `b4ef4c17d618eba0adccc4c7d9e9a1ef809fc9b6` "modbus_reply: fix copy & paste error in sanity check (fixes #614)", Michael Heimpold, 2022-01-08. One line in `src/modbus.c` (function `modbus_reply`, FC 0x17 write-and-read-registers branch): the bounds check tested `mapping_address < 0` twice and never `mapping_address_write < 0`, so a write address below the mapping start gives a negative index and an out-of-bounds write. Commit message states it is a copy-and-paste error.
- Note on the CVE text: the MITRE record says heap-based buffer overflow; the ASan report I obtained is a SEGV on a WRITE at a wild address (`0x505ffffffec8`), because the index is negative and large. The upstream issue title was first `_modbus_receive_msg`, then corrected to `modbus_reply`. Tell the learner to resolve this discrepancy themselves (good root-cause practice), and the cve text is "overflow" while the mechanism is a negative index (underflow).
- Size: `src/modbus.c` 2368 lines, but the bug is in one function (~100 lines); autotools build.
- build: VERIFIED 2026-11-10 in `debian:trixie` with `apt install gcc make git autoconf automake libtool python3`:
  ```
  git clone https://github.com/stephane/libmodbus && cd libmodbus && git checkout bd1c85f2d39cba13c031f019b005f564cf799f3e
  ./autogen.sh && ./configure CFLAGS="-g -O0 -fsanitize=address -fno-omit-frame-pointer" LDFLAGS="-fsanitize=address" && make -j4
  cd tests && ./unit-test-server tcp &      # listens on 127.0.0.1:1502
  # send request (base64 from issue #614): A90AAAAN/xcBYgABAIQAAQLXEQ==
  ```
  Result at the vulnerable commit: server dies with `AddressSanitizer: SEGV ... WRITE ... #0 modbus_reply src/modbus.c:980 #1 main tests/unit-test-server.c:183`. At the fix commit the server answers with exception frame `03 DD 00 00 00 03 FF 97 02` and logs "Illegal data read address 0x163 or write address 0x84 write_and_read_registers". (Debian trixie has no `pkill` in the base image; kill the server another way. My unit-test-server was started from `tests/`, and the client was a 5-line Python socket script.)
- Trigger bytes (decoded from the issue's PoC 1): `03 DD 00 00 00 0D FF 17 01 62 00 01 00 84 00 01 02 D7 11` (MBAP header, FC 0x17, read addr 0x0162 qty 1, write addr 0x0084 qty 1, byte count 2, data D7 11).
- Beginner fit: good but heavier: needs knowing that Modbus is a framed binary protocol, client/server setup, and a signed-index argument. Best as FND-04 second target or as the "vary the target" variation.
- Legal and safe: local server on loopback.

### 3. cJSON 1.7.17, CVE-2023-53154
- Sources fetched 2026-11-10: MITRE record (published 2025-05-23; "parse_string in cJSON before 1.7.18 has a heap-based buffer over-read via `{"1":1,` with no trailing newline if cJSON_ParseWithLength is called"; CWE-125; affected < 1.7.18); upstream issue `https://github.com/DaveGamble/cJSON/issues/800` (oliverchang, 2023-11-29; PoC input the 7 bytes `{"1":1,`; libFuzzer harness note: the existing fuzz target hid the bug by rejecting inputs not ending in NUL). The CVE was assigned in 2025 (a commenter says so; the MITRE record confirms).
- Pinned vulnerable: tag `v1.7.17` = `87d8f0961a01bf09bef98ff89bae9fdec42181ee` (ancestor of the fix; the parent of the fix commit is `826cd6f842ae7e46ee38bbc097f9a34f2947388d`, which already contains the failing regression test). Repo `https://github.com/DaveGamble/cJSON`.
- Fix commit: `3ef4e4e730e5efd381be612df41e1ff3f5bb3c32` "Fix heap buffer overflow" (Fixes #800), 2024-04-30, shipped in v1.7.18. Adds in `parse_object`: `if (cannot_access_at_index(input_buffer, 1)) { goto fail; }` before skipping the comma.
- Size: `cJSON.c` 3129 lines at v1.7.17 (87d8f09; the earlier 3206 figure was from master at v1.7.19-6-g6d9f244, corrected 2026-11-11); the bug lives in `parse_object`/`parse_string`.
- build: VERIFIED 2026-11-10 in `debian:trixie`; harness (6 lines, mine, `malloc(7)`, `memcpy`, `cJSON_ParseWithLength(buf, 7)`, `cJSON_Delete`, `free`):
  `gcc -g -O0 -fsanitize=address,undefined -fno-omit-frame-pointer -I. harness.c cJSON.c -lm`
  Result: `AddressSanitizer: heap-buffer-overflow ... cJSON.c:786 in parse_string`, allocation reported from `malloc` in the harness. At 3ef4e4e: clean exit.
- Beginner fit: good for reading an ASan heap report (the allocation stack and the "0 bytes after 7-byte region" line are the whole lesson). Requires learner to write the exact-size-heap harness, which is the instructive part (a NUL-terminated string literal hides the bug).
- Disadvantage: cJSON is the proposed FND-03 codebase; using it for FND-04 as well removes the "new codebase" shock that FND-04 is meant to give.
- Independent cJSON evidence: `https://joshua.hu/cjson-json-parser-cve-vulnerabilities` (Joshua Rogers, fetched 2026-11-10) lists 33 further, mostly unfixed issues in cJSON up to v1.7.19 with sanitizer PoCs and no CVE ids; usable as a `find` stretch ("variant analysis on a codebase you already know") but its claims are T3 (single researcher, no fix commits); treat as `needs-lab-verification`. Do not cite its issues as CVEs.

### 4. stb_image.h, CVE-2021-28021 (not recommended for first contact)
- MITRE record fetched: "Buffer overflow ... in function stbi__extend_receive in stb_image.h in stb 2.26 via a crafted JPEG file", published 2021-10-15, no CWE in the record. Upstream issue `https://github.com/nothings/stb/issues/1108` (fetched): ASan global-buffer-overflow 4-byte READ at `stb_image.h:2099` in `stbi__extend_receive`, reading before the global table `stbi__jbias`; PoC is a zip attachment `poc_hoob.zip` that I could not fetch; maintainer resolved it in July 2021.
- Fix commit: `86b7570cfba845e8209c6aec2d15e487bb1d8bb4` "stb_image: Fix bug on JPEGs with malformed DC deltas", 2021-07-02/04, 2 lines changed (verified in a local clone; the issue page also lists `a3f2897b85760d1e98fedbe31fcf2ddf089c169e` as the dev-branch commit, not checked). WARNING: Red Hat Bugzilla (via search snippet, not fetched) cites `5ba0baaa269b3fd681828e0e3b3ac0f1472eaf40` as the fix; my local check shows that commit is "Reject fractional JPEG component subsampling ratios" (issue #1178), a different bug. Do not use it.
- Why ranked last: the trigger is a crafted JPEG (learner must understand JPEG Huffman decoding to understand the bug, or rely on an attachment); 7988-line header; class is an OOB read from a table index, not the string/array overflow FND-02 teaches. build: unverified.

### Considered and rejected
- rxi microtar CVE-2026-55738 (`raw_to_header` strcpy into a stack buffer, CWE-121/170): MITRE record fetched (published 2026-06-17), small and readable, but the record lists 0.1.0 as affected with no fixed version and I found no fix commit. Unpatched, so it fails "public patch". Possible later as an unpatched-bug disclosure exercise, not for FND-04.
- lz4 CVE-2021-3520 (memmove with negative size): MITRE record fetched (CWE-190 to CWE-787; affected lz4 1.8.3). Fix commit `8301a21773ef61656225e264f4f06ae14462bca7` came from a search snippet and distro patch pages, not verified against upstream; Red Hat comment (via snippet) argues the bug is a caller-side cast. Triggering needs a hand-crafted compressed stream: too hard for first contact.
- yajl CVE-2017-16516 and ncurses/Wget2 CVE-2025-69195: leads only, not fetched in full, larger or older codebases.
- Classics (Heartbleed, sudo Baron Samedit, ImageMagick): excluded by the brief (exhausted tutorial examples or too large).

---

## FND-02: readable real bugs (pointers, arrays, strings, off-by-one)

All are reading exercises first ("find the line, state the invariant, predict what the write touches") and can double as the project's artefact (project = predict the ASan report from the diff, then confirm).

| Bug | What it teaches | Diff size | Source (fetched) | Reproducible by a beginner |
|---|---|---|---|---|
| iperf3 CVE-2025-54349, `decrypt_rsa_message` in `src/iperf_auth.c` | classic off-by-one: buffer of `keysize` bytes, then `plaintext[plaintext_len] = '\0'` with `plaintext_len == keysize` | fix adds `+1` to the `OPENSSL_malloc` plus a few hygiene changes | GHSA-8xx8-qrh3-q8mq (fetched), MITRE record (CWE-193, published 2025-08-03), commit `4e5313bab0b9b3fe03513ab54f722c8a3e4b7bdf` (Sarah Larsen, 2025-06-25, "Fix off-by-one heap overflow in auth", credit Han Lee), fixed in 3.19.1 (git: contained in tags 3.20, 3.21; 3.19.1 tag not checked); parent `4eab661da0bbaac04493fa40164e928c6df7934a` | not tested; needs RSA key and iperf3 auth setup. Reading only. build: unverified |
| libmodbus CVE-2022-0367 | copy-and-paste bounds check, signed index | 1 line | see FND-04 #2 | yes (see above) |
| TinyDir CVE-2023-49287 | `strcpy` into a smaller array, array-size constants | 1 token | see FND-04 #1 | yes |
| cJSON CVE-2023-53154 | cursor plus length discipline, "exact-size buffer vs NUL-terminated string" | 5 lines | see FND-04 #3 | yes |

Recommendation: because FND-04's primary target is TinyDir, FND-02 should use the iperf diff (reading, off-by-one NUL byte, the cleanest off-by-one found) and the cJSON diff (reading), and keep TinyDir and libmodbus unseen until FND-04. If FND-01 also uses cJSON CVE-2023-53154, swap the FND-02 reading to a different bug; I did not find a second verified off-by-one with a reproducible one-liner. For hands-on FND-02 drills the project artefact can be "predict, then run" on the iperf bug's logic re-implemented in a 20-line C file; mark that clearly as a stepping stone (D1 requires the real artefact in the same module: the iperf commit is that artefact).

Gap: I found only one real, verified off-by-one (iperf). Open item for a second pass: a smaller off-by-one in a standalone tool with a one-command trigger.

## FND-03: build and debug a real codebase

Recommended: cJSON at tag v1.7.17 (`87d8f0961a01bf09bef98ff89bae9fdec42181ee`), repo `https://github.com/DaveGamble/cJSON`.
- Small (cJSON.c 3129 lines at v1.7.17; 3206 on master as of 2026-11-11), CMake build with option `-DENABLE_SANITIZERS=ON`, 19 test programs run by `ctest` (Unity test framework in-tree), no external dependencies, API a beginner can read.
- build: VERIFIED 2026-11-10 in `debian:trixie` (`apt install gcc make cmake git gdb`):
  ```
  cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DENABLE_SANITIZERS=ON -DENABLE_CJSON_TEST=ON -DCMAKE_C_FLAGS="-g -O0 -fno-omit-frame-pointer"
  cmake --build build -j4 && (cd build && ctest)
  ```
  Result: "100% tests passed, 0 tests failed out of 19". Not verified: that ASan was actually active in this ctest build (CMakeLists lists `-fsanitize=address`, `undefined`, `float-cast-overflow`, `integer`; the last is a clang-only flag and I did not inspect which survived on gcc), so the module-builder or lab-engineer should confirm with `ldd`/`nm | grep asan` or prefer explicit `-DCMAKE_C_FLAGS=-fsanitize=address,undefined`. My manual `gcc -fsanitize=address,undefined` builds of `cJSON.c` did work (FND-04 #3).
- gdb: I started gdb in the container against `tests/parse_string` but my breakpoint (`cJSON_ParseWithLengthOpts`) never hit since that test does not call it; stepping a test under gdb is unverified in detail. The lab-engineer should pick a test that does (for instance `parse_examples` or `parse_with_opts`) and confirm.
- Why pinned at v1.7.17 and not the fix: the pre-fix tag lets FND-03 expose the learner to a codebase that still contains CVE-2023-53154 (see FND-01/FND-04 allocation question).
- Alternative with the same shape: TinyDir (header-only, has `tests/` and CMake, `cxong/tinydir`), but it is the FND-04 primary, so keep it for FND-04.
- Not evaluated (no time): inih, miniz, lua, zlib.

## FND-01: artefact for a lab-and-protocol module

D1 is a poor fit in the intrinsic sense: FND-01 teaches workstation setup and a session protocol, and no real artefact is the point of it. Options that satisfy D1 honestly:
1. (Recommended) Lab smoke test: the learner builds the lab image, then runs a pre-written script that clones cJSON `v1.7.17`, compiles the 6-line harness with ASan, and observes the CVE-2023-53154 report (verified to work, see FND-04 #3); output is the artefact: a session log entry ("first ASan report") plus one sentence describing what the report claims. No root-causing, which keeps FND-04's skill unspoiled; the PoC works as the lab's pass/fail self-check. Requires FND-02/04 spoiler management (see allocation note).
2. Same smoke test with TinyDir 1.2.5 and one `gcc` line (verified); cheaper but spoils FND-04's primary.
3. Declare the project's artefact to be the learner's own lab plus session log, and have the auditor treat D1 as "real CVE used only as lab validation". This is honest but needs an architect decision record because CLAUDE.md D1 wants a real artefact in `project.md`.

## Resource cards (candidate; not yet in any `resources.yaml`)

```yaml
- id: tinydir-ghsa-jf5r-wgf4-qhxf
  title: "Buffer overflow vulnerabilities in tinydir (GHSA-jf5r-wgf4-qhxf, CVE-2023-49287)"
  url: https://github.com/cxong/tinydir/security/advisories/GHSA-jf5r-wgf4-qhxf
  author: "cxong (repository maintainer, publisher); reporter credit 0xdea"
  kind: advisory
  tier: T1
  cost: free
  published: 2023-12-03
  targets: "tinydir <= 1.2.5, patched 1.2.6; CVSS 3.1 7.7 High (AV:L/AC:L/PR:N/UI:N/S:U/C:N/I:H/A:H); CWE-120, CWE-121; cites tinydir.h lines 675-680, 706, 711 and a PoC using samples/file_open_sample.c"
  covers: vendor advisory with ASan reproduction steps; affected <=1.2.5, fixed 1.2.6
  assumes: running gcc, reading a stack report
  scores: {directness: 5, currency: 5, depth: 3, activity: 4, cost: 5, accessibility: 5}
  verified: 2026-11-11
  status: ok
- id: tinydir-cve-2023-49287-mitre
  title: "CVE-2023-49287 (MITRE CVE Services record)"
  url: https://cveawg.mitre.org/api/cve/CVE-2023-49287
  author: "GitHub_M (CNA / assigner)"
  kind: advisory
  tier: T1
  cost: free
  published: 2023-12-04
  targets: "cxong tinydir, all versions < 1.2.6"
  covers: "Description: 'TinyDir is a lightweight C directory and file reader. Buffer overflows in the tinydir_file_open() function', patched in 1.2.6; CWE-120 and CWE-121; references: the GHSA, release 1.2.6, oss-security 2023/12/04/1, Packet Storm 176060, seclists fulldisclosure 2023/Dec/14 (the last three not fetched)"
  assumes: none
  scores: {directness: 3, currency: 5, depth: 1, activity: 1, cost: 5, accessibility: 4}
  verified: 2026-11-11
  status: ok
- id: tinydir-fix-commit-8124807
  title: "Fix buffer overflow in tinydir_file_open with long path names (cxong/tinydir commit 8124807)"
  url: https://github.com/cxong/tinydir/commit/8124807260735a837226fa151493536591f6715d
  author: "cxong (per commit page); git metadata in local clone: Cong <congusbongus@gmail.com>"
  kind: source
  tier: T1
  cost: free
  published: 2023-12-02    # NOT shown on the fetched page; from local clone git log (Sat Dec 2 23:13:38 2023 +1100)
  targets: "tinydir.h, 7 files +39/-2, parent 74acffdf66b5a1bc09278f0b8b0fcc892ab12183; contained in tag 1.2.6"
  covers: "Page diff hunk at line 643; changed line 646: file_name_buf[_TINYDIR_FILENAME_MAX] becomes file_name_buf[_TINYDIR_PATH_MAX]. Adds tests/file_open_test.c regression test. Local git confirms line 646 of tinydir.h at the fix is the new declaration."
  assumes: C arrays and macros
  scores: {directness: 5, currency: 5, depth: 3, activity: 3, cost: 5, accessibility: 4}
  verified: 2026-11-11
  status: ok
- id: libmodbus-issue-614
  title: "Heap-based Buffer Overflow in modbus_reply (libmodbus issue 614)"
  url: https://github.com/stephane/libmodbus/issues/614
  author: "AiDaiP (reporter); stephane (maintainer), mhei (fix), JonasToth (ASan reproduction)"
  kind: writeup
  tier: T1
  cost: free
  published: 2021-12-22      # title changed from "_modbus_receive_msg" to "modbus_reply" on 2022-01-04; closed 2022-01-08 via b4ef4c1
  targets: "libmodbus modbus_reply(), found by fuzzing unit-test-server; JonasToth's ASan run showed a SEGV write at modbus.c:980; a commenter notes an earlier report in issue #499"
  covers: "original report with PoC, second PoC (2022-01-04), ASan confirmation, fix verification, discussion of adding fuzzing to CI"
  assumes: "TCP framing, running a server and a client"
  scores: {directness: 5, currency: 5, depth: 4, activity: 3, cost: 5, accessibility: 3}
  verified: 2026-11-11
  status: ok
- id: libmodbus-fix-b4ef4c1
  title: "modbus_reply: fix copy & paste error in sanity check (fixes #614)  [libmodbus commit b4ef4c1]"
  url: https://github.com/stephane/libmodbus/commit/b4ef4c17d618eba0adccc4c7d9e9a1ef809fc9b6
  author: "Michael Heimpold <mhei@heimpold.de>"
  kind: source
  tier: T1
  cost: free
  published: 2022-01-08
  targets: "src/modbus.c modbus_reply(), MODBUS_FC_WRITE_AND_READ_REGISTERS; first contained in v3.1.7 (`git describe --contains b4ef4c1` = `v3.1.7~1`; `git tag --contains` lists v3.1.7 through v3.2.0; patch-id f4be7792bf2f17d3b0ad04ae0a1fe265d4772611 occurs only in b4ef4c1, no cherry-picks). Agrees with the CVE record. [Corrected 2026-11-11 by main thread from the FND-04 lab-engineer's in-image git check; the earlier 'v3.1.10' came from a truncated tag listing.]"
  covers: "One-line change: the duplicated `mapping_address < 0` in the bounds check becomes `mapping_address_write < 0`, so both the read and write address are range-checked."
  assumes: "C, signed index bounds checks"
  scores: {directness: 5, currency: 5, depth: 3, activity: 3, cost: 5, accessibility: 4}
  verified: 2026-11-11     # verified from git (local clone: git show b4ef4c1), not from the GitHub page; the GitHub page was not fetched. Date and author are from git.
  status: ok
- id: libmodbus-cve-2022-0367-mitre
  title: "CVE-2022-0367 (MITRE CVE Services record)"
  url: https://cveawg.mitre.org/api/cve/CVE-2022-0367
  author: "Red Hat (CNA / assigner)"
  kind: advisory
  tier: T1
  cost: free
  published: 2022-08-29
  targets: "libmodbus; version entry 'Fixed in v3.1.7'"
  covers: "'A heap-based buffer overflow flaw was found in libmodbus in function modbus_reply() in src/modbus.c.' CWE-119. References: issue 614, Red Hat Bugzilla 2045571, commit b4ef4c17, Debian LTS DLA 3098-1 and a 2025-03 Debian LTS announcement (references not fetched)."
  assumes: none
  scores: {directness: 3, currency: 4, depth: 1, activity: 1, cost: 5, accessibility: 4}
  verified: 2026-11-11
  status: ok
- id: cjson-cve-2023-53154-mitre
  title: "CVE-2023-53154 (MITRE CVE Services record)"
  url: https://cveawg.mitre.org/api/cve/CVE-2023-53154
  author: "MITRE (CNA / assigner)"
  kind: advisory
  tier: T1
  cost: free
  published: 2025-05-23
  targets: "cJSON before 1.7.18"
  covers: "'In cJSON before 1.7.18, the parse_string function has a heap-based buffer over-read', triggered by input like {\"1\":1, with no trailing newline via cJSON_ParseWithLength. CWE-125. References: compare v1.7.17...v1.7.18, issue 800, Debian LTS 2025/06/msg00014 (compare and LTS not fetched)."
  assumes: none
  scores: {directness: 3, currency: 4, depth: 1, activity: 1, cost: 5, accessibility: 4}
  verified: 2026-11-11
  status: ok
- id: cjson-issue-800
  title: "OOB access in `parse_string` (cJSON issue 800)"
  url: https://github.com/DaveGamble/cJSON/issues/800
  author: "oliverchang (reporter)"
  kind: writeup
  tier: T1
  cost: free
  published: 2023-11-29      # closed 2024-05-06 via PR #852
  targets: "cJSON parse_string reached through parse_object; the fuzz target calls cJSON_ParseWithLength with input lacking a trailing NUL, e.g. {\"1\":1,"
  covers: "ASan heap-buffer-overflow read in parse_string; explains that the existing fuzz target skipped non-NUL-terminated inputs (blind spot). A commenter (carnil, 2025-05-23) tentatively links CVE-2023-53154; the MITRE record of that CVE cites this issue, which confirms the link."
  assumes: "ASan report reading"
  scores: {directness: 5, currency: 5, depth: 3, activity: 3, cost: 5, accessibility: 4}
  verified: 2026-11-11
  status: ok
- id: tinydir-hns-2023-04-seclists
  title: "HNS-2023-04 - HN Security Advisory - Buffer overflow vulnerabilities with long path names in TinyDir"
  url: http://seclists.org/fulldisclosure/2023/Dec/14
  author: "Marco Ivaldi (HN Security), Full Disclosure post dated 2023-12-04"
  kind: advisory
  tier: T1
  cost: free
  published: 2023-12-04
  targets: "TinyDir <= 1.2.5; CVE-2023-49287; CVSS 3.1 7.7"
  covers: "Researcher's announcement linking the vendor GHSA and a full advisory copy; same text posted to oss-security (http://www.openwall.com/lists/oss-security/2023/12/04/1, also fetched 2026-11-11, same title and author)."
  assumes: none
  scores: {directness: 4, currency: 5, depth: 2, activity: 1, cost: 5, accessibility: 4}
  verified: 2026-11-11
  status: ok
- id: tinydir-packetstorm-176060
  title: "TinyDir-1.2.5 Buffer Overflow (Packet Storm 176060)"
  url: http://packetstormsecurity.com/files/176060/TinyDir-1.2.5-Buffer-Overflow.html
  tier: T3
  verified: null
  status: unverified     # 301 to packetstorm.news, which returned only a bot-check interstitial; not retried or bypassed
- id: iperf-ghsa-8xx8-qrh3-q8mq
  title: "CVE-2025-54349 (GHSA-8xx8-qrh3-q8mq)"   # page title as relayed by fetch; description: "iperf_auth.c has an off-by-one error and resultant heap-based buffer overflow"
  url: https://github.com/advisories/GHSA-8xx8-qrh3-q8mq
  author: "GitHub Advisory Database (Unreviewed; mirrors NVD)"
  kind: advisory
  tier: T1
  cost: free
  published: 2025-08-03      # last updated 2025-11-03
  targets: "iperf3 before 3.19.1. The page lists affected and patched versions as 'Unknown' but its references point to release 3.19.1. CVSS 3.1 6.5 Moderate, CWE-193. Credits: none on this page."
  covers: "Advisory stub with CVSS, CWE-193 and references to commit 4e5313b, release 3.19.1, NVD, Debian LTS announcement."
  assumes: "none"
  scores: {directness: 4, currency: 4, depth: 1, activity: 1, cost: 5, accessibility: 5}
  verified: 2026-11-11
  status: ok
- id: iperf-cve-2025-54349-mitre
  title: "CVE-2025-54349 (MITRE CVE Services record)"
  url: https://cveawg.mitre.org/api/cve/CVE-2025-54349
  author: "MITRE (CNA assigner)"
  kind: advisory
  tier: T1
  cost: free
  published: 2025-08-03
  targets: "iperf3 (vendor 'ES') before 3.19.1"
  covers: "Authoritative CVE record: one-line description, CWE-193, references to the fix commit, release 3.19.1 and Debian LTS announcement."
  assumes: "none"
  scores: {directness: 3, currency: 4, depth: 1, activity: 1, cost: 5, accessibility: 4}
  verified: 2026-11-11
  status: ok
- id: iperf-fix-commit-4e5313b
  title: "Fix off-by-one heap overflow in auth. (esnet/iperf commit 4e5313b)"
  url: https://github.com/esnet/iperf/commit/4e5313bab0b9b3fe03513ab54f722c8a3e4b7bdf
  author: "swlars (author); bmah888 (committer); reported by Han Lee (Apple Information Security)"
  kind: source
  tier: T1
  cost: free
  published: unknown      # commit date not shown on fetched page; my earlier clone read gave 2025-06-25 (local clone, not this page)
  targets: "esnet/iperf src/iperf_auth.c; parent 4eab661; one file, +13/-5"
  covers: "decrypt_rsa_message allocates keysize+1 instead of keysize (room for the NUL), error check plaintext_len <= 0, and decode_auth_setting frees plaintext on error paths."
  assumes: "C pointers, malloc, NUL-terminated strings; OpenSSL EVP API names"
  scores: {directness: 5, currency: 5, depth: 3, activity: 3, cost: 5, accessibility: 3}
  verified: 2026-11-11
  status: ok
# Canonical clone URL (fetched 2026-11-11 from https://github.com/esnet/iperf): https://github.com/esnet/iperf.git
# Repo description "iperf3: A TCP, UDP, and SCTP network bandwidth measurement tool"; three-clause BSD licence.
- id: sanitizers-asan-wiki
  title: AddressSanitizer example pages (google/sanitizers wiki)
  url: https://github.com/google/sanitizers/wiki/AddressSanitizerExampleHeapOutOfBounds
  tier: T1
  verified: null
  status: unverified   # appeared in search results only; not fetched
```

## Open questions
1. Does the architect want cJSON in FND-01, FND-03 and as an FND-04 variation (familiar codebase, spoiler risk) or a spread across codebases? The FND-04 shortlist works either way because TinyDir is independent.
2. `ENABLE_SANITIZERS=ON` on gcc: confirm which flags are applied (lab-engineer).
3. TinyDir without ASan: what the default Debian build does on the same input was not tested (`needs-lab-verification`).
4. Second verified off-by-one for FND-02 not found.
5. Windows branches of CVE-2023-49287 cannot be tested on Linux; the advisory says they are reproducible by long paths on Windows.
6. Fix-release for iperf: the advisory says 3.19.1; my clone shows the fix commit contained in tags 3.20 and 3.21 only (`git tag --contains` listing was truncated to the first two tags, so this does not contradict 3.19.1, but I did not check the 3.19.1 tag itself).

## Sources (all fetched 2026-11-10 unless stated)
- https://cveawg.mitre.org/api/cve/CVE-2022-0367, CVE-2023-53154, CVE-2021-28021, CVE-2021-3520, CVE-2026-55738, CVE-2023-49287, CVE-2025-69195, CVE-2025-54349 (MITRE CVE Services records)
- https://github.com/cxong/tinydir/security/advisories/GHSA-jf5r-wgf4-qhxf
- https://github.com/stephane/libmodbus/issues/614
- https://github.com/DaveGamble/cJSON/issues/800
- https://github.com/nothings/stb/issues/1108
- https://github.com/advisories/GHSA-8xx8-qrh3-q8mq
- https://joshua.hu/cjson-json-parser-cve-vulnerabilities (T3, see cJSON note)
- Local clones of cxong/tinydir, stephane/libmodbus, DaveGamble/cJSON, nothings/stb, esnet/iperf (git history and diffs read directly)
- Search-engine results used only as leads and not cited as sources: Debian tracker, Red Hat Bugzilla, distro patch pages, SentinelOne, others.

- 2026-11-11 additions: https://cveawg.mitre.org/api/cve/CVE-2025-54349 ; https://github.com/esnet/iperf/commit/4e5313bab0b9b3fe03513ab54f722c8a3e4b7bdf ; https://github.com/esnet/iperf (re-fetched)

- 2026-11-11 additions (TinyDir): https://cveawg.mitre.org/api/cve/CVE-2023-49287 ; https://github.com/cxong/tinydir/commit/8124807260735a837226fa151493536591f6715d ; GHSA page re-fetched
