# Project: FND-01-linux-lab-and-learning-protocol

## Target
Real artefact: cJSON, CVE-2023-53154 (heap-based buffer over-read in `parse_string`, CWE-125). It is used here **only as the lab's smoke test**: you reproduce the published crash report under ASan and record it. Root-causing is deliberately left for later.
Version: cJSON tag `v1.7.17` = commit `87d8f0961a01bf09bef98ff89bae9fdec42181ee`, repo `https://github.com/DaveGamble/cJSON`.
Fix: commit `3ef4e4e730e5efd381be612df41e1ff3f5bb3c32` "Fix heap buffer overflow" (Fixes #800), shipped in 1.7.18. Sources: MITRE record `https://cveawg.mitre.org/api/cve/CVE-2023-53154` and upstream issue `https://github.com/DaveGamble/cJSON/issues/800`, both fetched 2026-11-10 (`research/targets/FND.md`).
Lab: `lab/` (see `lab/README.md` once the lab-engineer has built it; spec in `lab/SPEC.md`). Shared base: `labs/shared/fnd-base/`.
Mitigations on: host ASLR (not relied on); ASan + UBSan in the smoke-test build (detection only); container isolation, `--network=none` at runtime. Compiler hardening is not studied here (FND-02/03).

Do not read the fix diff or the discussion in issue 800 during this project. The links above are here because CVE claims must cite their source, not as reading. FND-03 has you work inside this codebase, and you will get more out of it if the root cause is still unknown to you.

## Goal
A lab you can destroy and rebuild in minutes that gives the same result every time. Plus a week of study sessions run by the protocol. Observable:
- After an uncached rebuild (`NO_CACHE=1 "$M/lab/build.sh"`) and a fresh run, `lab/check.sh` grades your outputs as passing (exit 0). That means the vulnerable build and the negative control (the fixed commit) both behave as expected.
- Three session logs in `learner/sessions/` pass `labs/shared/tools/check_session.py`.

## Constraints
- Runtime network off (`--network=none`). Only image builds may download.
- No root-causing. Your notes say *what* the report claims and *where*. If you catch yourself explaining *why* the parser over-reads, stop and write the question down as a parked item for FND-03.
- At least two of the three sessions on different days. Each must open with the previous session's next action.
- Podman is recommended. The lab is verified on rootless podman, and Docker is unverified (needs-lab-verification). Record which engine you used, with `"$ENGINE" --version`. If you use Docker and it fails, follow the reporting steps at the top of the README and switch to podman.

## Deliverables
FND-01 has no exploit and no root cause by design. The template's four deliverables are mapped to what this module trains. Put the files in `~/osvr-work/fnd01/submit/` and submit with `/submit`.

1. `lab-evidence.md` (stands in for the exploit; it is the thing that must "work"):
   - Engine and version. Host distro and `uname -r`.
   - Base image digest as recorded by the lab (`base_image_digest=` in `out/env.txt`; also `/etc/osvr-base-digest` in the image), and the gcc version (`gcc=` in `env.txt`, or the gcc line of `/etc/osvr-packages.txt`). Do not use image IDs as evidence: they change on every rebuild.
   - cJSON commit printed from inside the container, for both the vulnerable and the fixed tree.
   - Your first build's outputs in `~/osvr-work/fnd01/out`, graded by `"$M/lab/check.sh"` (full output).
   - An uncached rebuild: `NO_CACHE=1 "$M/lab/build.sh"`. `build.sh` prints `build log: <path>` at the start and at the end. Attach that log (`~/osvr-work/fnd01/build-logs/build-<timestamp>.log`). Under podman, `grep -c 'Using cache'` on an uncached log gives 0. Docker prints `CACHED` instead (untested).
   - A fresh run of the rebuilt image into its own directory, graded there:
     ```sh
     OUT=~/osvr-work/fnd01/out-rebuild "$M/lab/run.sh"
     OUT=~/osvr-work/fnd01/out-rebuild "$M/lab/check.sh"
     ```
     Include the full output.
   - `diff` of the two `env.txt` files and of the two `first-asan-report.txt` files, with a one-line explanation of each difference. Addresses and the date are expected to differ. Digest, gcc, commits, frames and lines are not.
   - Why uncached: a cached rebuild reuses last time's layers and re-runs nothing, so a match proves only that the cache exists.
2. `first-asan-report.txt` and `report-note.md` (stands in for `rootcause.md`):
   - The raw report, untouched.
   - The three fields copied out: error-kind line, first frame in cJSON code with file:line, allocation site.
   - One sentence on what the report claims happened. No cause.
   - One "parked question" for FND-03, phrased as a question.
3. `feynman.md`: under 400 words, for a smart non-specialist (a friend who is a nurse, an accountant, a carpenter). Explain:
   - what your lab is, and why it runs isolated and offline;
   - why "pinned" matters, using one concrete example of what would go wrong without it;
   - what the ASan report says happened, in plain words;
   - why the checker also runs the fixed version.
   Do not explain the bug's cause.
4. `repro-report.md` (stands in for `advisory.md`, the reproduction half of an advisory): written as if filing it to a maintainer who has never seen your lab.
   - Title; affected component and version (from the CVE record: cJSON before 1.7.18; you tested 1.7.17); CVE ID with its MITRE reference.
   - Environment (engine, base image digest, gcc version, flags).
   - Exact reproduction steps a stranger could paste: build, run, expected vs observed.
   - Negative control result at the fix commit.
   - No root-cause or fix section. Cite the upstream fix version from the CVE record and stop there.
5. Three session logs (copies from `learner/sessions/`), each passing `check_session.py`. At least one must include a classified distraction list (Drill 5). One must include your Drill 2 recall ratio.

## Variations (experimentation)
Each variation changes one thing. Predict the result in writing first, then run it, then record predicted vs observed in `variations.md`. The smoke script accepts a `LAB_CFLAGS` override (ambient `CFLAGS` is ignored). Give every variation its own output directory so your graded outputs stay intact, for example:

```sh
OUT=~/osvr-work/fnd01/out-nog LAB_CFLAGS="-O0 -fno-omit-frame-pointer -fsanitize=address,undefined" "$M/lab/run.sh"
```

`run.sh` warns `LAB_CFLAGS override in effect: ...`, and `check.sh` refuses to grade such outputs (`FAIL  flags: graded only with default LAB_CFLAGS ...`). That is expected for variations. Record your observations by hand.
- [ ] **Remove debug info**: rebuild the smoke test without `-g`. What disappears from the report, and what is left that still lets you find the place?
  <details><summary>Lab-verified result (open after recording your prediction)</summary>The frames keep their function names (`parse_string`, `parse_object`, ...) but show module+offset (`harness-vuln+0x...`) instead of `cJSON.c:NNN`.</details>
- [ ] **Remove the sanitizer**: build without `-fsanitize=address,undefined` and run the same input. Does anything visible happen? What does that tell you about finding bugs by "does it crash"?
  <details><summary>Lab-verified result (open after recording your prediction)</summary>The PoC does not crash. A `-g -O0` build exits 0 and the report file is empty. The bug is still there; nothing makes it visible.</details>
- [ ] **Swap the engine**: if you used podman, reproduce with Docker (in a VM if you do not want a root daemon on your host), or the reverse. Record every command you had to change.
- [ ] **Offline rebuild**: `"$ENGINE" save` both images to a tarball, delete them, `load` them back with the network disconnected, and pass `check.sh`. What does this give you that a Dockerfile alone does not?

## Overlearning stretch
Write your own lab from a blank file, without opening the provided Dockerfiles: a single Dockerfile `FROM` `debian:trixie` pinned by the digest you recorded. It installs what is needed, clones cJSON and checks out the pinned commit (verifying it with `git rev-parse HEAD`), builds the provided `harness.c` (copy it from the lab, since writing it is FND-03 material) with ASan, and runs it as the default command. Run your image with `--network=none` and a bind mount into its own directory, for example `~/osvr-work/fnd01/out-own`. Then grade that directory with `OUT=~/osvr-work/fnd01/out-own "$M/lab/check.sh"` and make it pass. Your image must therefore write the same three files and `env.txt` keys as the provided one. Then write down every place where your recipe differs from the provided one and why one of the two is better.

Submit with `/submit FND-01-linux-lab-and-learning-protocol`.
