# Rubric: FND-01-linux-lab-and-learning-protocol

Automated checks:
- `lab/check.sh` (`SUMMARY: all checks passed`, exit 0 = outcome pass). It grades the learner's own outputs in `$OUT` (default `~/osvr-work/fnd01/out`) read-only, and needs no engine. A correct run gives 15 PASS lines:
  - the three files are present and owned by the learner;
  - default `LAB_CFLAGS`;
  - `net_interfaces=lo` only;
  - both pinned cJSON commits;
  - a non-zero `vuln_exit_status`;
  - a clean negative control at the fix commit;
  - the report contains `heap-buffer-overflow`, `cJSON.c:786 in parse_string` and a `located N bytes ... 7-byte region` line.

  `check.sh --health` (`LAB HEALTH OK`) is a lab self-test and is not grading evidence.
- `python3 labs/shared/tools/check_session.py FILE` (exit 0 = structural pass for a session log). Checks the required fields are present and non-trivial. It cannot judge goal quality; the grader does that with the three tests below.

**The three goal tests** (used in several rows). *Observable*: checkable from a file, output or exit code by someone else. *Bounded*: fits one timebox. *Single*: one done-condition.

Feedback type for each row: the automated checks give outcome feedback. The assessor's notes are informational (which criterion failed and where). Corrective feedback comes only after a resubmission still fails the same criterion.

| Deliverable | Not yet | Pass | Strong pass |
|---|---|---|---|
| `lab-evidence.md` | Any of: `check.sh` output missing or not exit 0; only one build shown; the rebuild was cached (its log has "Using cache" lines) or no build log attached; no base-image digest / cJSON commit recorded | All of: `check.sh` exit 0 on the first build's outputs and on the rebuild's outputs (graded in its own `OUT` dir); rebuild done with `NO_CACHE=1 ./build.sh`, with its log from `~/osvr-work/fnd01/build-logs/` (`build-<timestamp>.log`) attached and containing no "Using cache" lines (`grep -c 'Using cache'` gives 0); engine + version, base digest, gcc version and both cJSON commits recorded; `diff` of the two `env.txt` files and the two reports included. Only an uncached build log counts as rebuild evidence. Image IDs are not accepted. Docker users: Docker marks cached steps `CACHED` instead (untested, needs-lab-verification), so attach the log and the assessor judges it | Also explains each line of the `env.txt` diff (or states there is none and why that is expected), and records how long the rebuild took split into typing vs waiting |
| `first-asan-report.txt` + `report-note.md` | Report edited or truncated; any of the three fields wrong (e.g. an ASan interceptor or `main` given as the first cJSON frame); or the sentence asserts a cause ("because the length check is wrong") | Raw report intact; error-kind line, first cJSON frame with file:line, and allocation site copied correctly; one sentence that states what and where with no cause; one parked question | Sentence also names the access direction (read vs write) and the relation to the block (bytes past a block of N bytes) correctly; parked question is specific enough to start FND-03 with (names a function or line) |
| `feynman.md` | Over 400 words; or uses an undefined term a non-specialist would stop at (ASan, heap, container, commit, digest) on a step the explanation depends on; or explains the bug's cause | Under 400 words; covers all four required points (what the lab is and why isolated/offline, why pinning with one concrete failure example, what the report says, why the fixed version is run); every technical term either defined in passing or avoidable | A non-specialist reader (ask one) can restate why the negative control matters in their own words; this is recorded in the file |
| `repro-report.md` | A stranger could not reproduce from it (missing step, path only valid on your machine, missing engine/flags); or CVE/version claims not matching the MITRE record | Title, component and version, CVE with MITRE reference, environment, paste-able steps, expected vs observed, negative control; no speculation on cause | Steps tested by pasting them into a fresh terminal (stated in the file); both `podman` and `docker` command forms given where they differ |
| Session logs (3) | Any log fails `check_session.py`; or any goal fails one of the three goal tests; or fewer than two distinct days; or a session's first action does not match the previous next action | All three pass the checker; all goals pass the three tests; distraction log present in each; close-out recall written before notes were consulted (stated); each next action is a command, file:line or precise question; one classified distraction list (Drill 5) and one recall ratio (Drill 2) present | Gaps from recall turned into cards (card IDs listed under "New cards") in at least two logs; a cold-start time (Drill 3) recorded and under 5 minutes in at least one |
| Variations (optional for pass) | n/a | n/a | At least two done with written prediction before the run and predicted vs observed recorded |

Pass the module: every required deliverable (all rows except Variations) at Pass or above, and `check.sh` exit 0 reproduced by the assessor or coach from the learner's `repro-report.md` steps, or the learner's terminal output if no second machine is available (state which).
