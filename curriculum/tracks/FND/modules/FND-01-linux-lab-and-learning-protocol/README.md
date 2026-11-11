# FND-01-linux-lab-and-learning-protocol: Linux workstation, the OSVR lab and the session protocol

Track: FND   Hours: 8 (pilot parameter; breakdown below)   Prereqs: none (needs only "can use a terminal")   Status: drafting
Outcomes: rootcause

This module needs no programming. You will build the container lab every FND module reuses. You will prove it works by reproducing a real CVE crash report, and you will run every study session from now on with one fixed protocol. The protocol is the skill this module drills. The lab is the tool you practise it with.

Throughout, `M` is this module's directory and `ENGINE` is your container engine. Set both once per terminal, from the repo root:

```sh
M=curriculum/tracks/FND/modules/FND-01-linux-lab-and-learning-protocol
ENGINE=$(command -v podman || command -v docker)
echo "engine: ${ENGINE:-NONE FOUND}"
```

**Engine support: verified on rootless podman; Docker unverified.** Podman is recommended for all FND modules. The commands are written for both engines, and where they differ the text says so.

> needs-lab-verification: the Docker path (build, run, file ownership, `check.sh`) has not been run by the lab-engineer.

If you use Docker and something fails, record five things and report them through `/coach`, which files them in `maintenance/inbox.md`. Then switch to podman for this module rather than debugging Docker on your own:
1. `docker version` and `docker info` (shows rootful vs rootless).
2. The exact command you ran.
3. The full error text.
4. `ls -ln ~/osvr-work/fnd01/out`.
5. The output of `"$M/lab/check.sh"`.

**Hours (pilot parameter: no source gives hours for this, so log yours).** About 8 h of required work:

| Item | Hours |
|---|---|
| Prerequisite check | 0.2 |
| Worked example, including the first image pull | 1.0 |
| Struggle challenge (one 50-min session) plus consolidation | 1.1 |
| Theory and walkthrough | 0.75 |
| Project deliverables (uncached rebuild, report note, Feynman, repro report, lab evidence) | 2.5 |
| Session open/close overhead across 3 project sessions, Drill 5 analysis and Drill 2 scoring | 0.85 |
| Drills 1 and 4 to "owned", and card import and first review | 1.4 |

Installing podman or Docker is not counted, because it varies too much by machine. The 90-minute DR-0005 programming diagnostic (see Next) is also outside FND-01's hours.

## Objectives
After this module you can:
1. Build the OSVR FND lab images from their recipes, run the smoke test with no network so that its outputs land in `~/osvr-work/fnd01/out`, and get `lab/check.sh` to grade those outputs as passing (exit 0). The check covers: files present and owned by you, default flags, network was loopback only, pinned cJSON commits, non-zero vulnerable exit, clean control, and the expected report lines. Verified on rootless podman; Docker unverified (needs-lab-verification).
2. Rebuild the lab uncached (`NO_CACHE=1 "$M/lab/build.sh"`) and show it is the same lab. Compare the base-image digest, the package list or gcc version, the two cJSON commits and the report content across builds. Image IDs change on every rebuild and prove nothing.
3. Copy the three load-bearing fields of an ASan report into a note: error kind, first frame in project code with file:line, and allocation site. Then state in one sentence what the report claims happened, without guessing why.
4. Rewrite a vague study goal into one concrete goal with an observable done-check that fits a single timebox.
5. Run a full study session with the protocol (declared goal, timebox, distraction log, verification, 3-minute free recall, logged next step), and write a session log that passes `labs/shared/tools/check_session.py`.
6. Turn the gaps from your end-of-session recall into retrieval cards and review them with `scripts/srs.py`.

## Where this shows up in the wild
- cJSON before 1.7.18 has a heap-based buffer over-read in `parse_string`, triggered by the 7-byte input `{"1":1,` passed to `cJSON_ParseWithLength` (CVE-2023-53154, MITRE record). Your lab's smoke test reproduces this crash report. You will not root-cause it here.
- The same bug had not been caught by the project's existing fuzzing before it was reported (cJSON issue 800). Running a tool is not the same as running it in a setup that can see the bug.
- Anecdotes, not measurements: two practitioner reports filed in `research/FIELD-SYNTHESIS.md` (finding 5, from `research/benchmarks/expert-paths.md`). A Hyper-V harness took months to set up, and the bug came two hours after it was stable. A router researcher spent a year with bugs they could not trigger. They suggest that environment setup can cost more than finding the bug, which is why the lab comes first and must be reproducible.

## Mitigation context
FND-01 bypasses nothing. The table lists what is active in your lab so that you do not later mistake a lab property for a property of the bug.

| Mitigation / mechanism | On in this module? | What it does | How this module deals with it |
|---|---|---|---|
| ASLR (`kernel.randomize_va_space`) | Yes. It is the host kernel's setting, and containers share the host kernel | Randomises where stack, heap and libraries load on each run | You do not depend on addresses. You compare reports by error kind, function and file:line, never by hex address. You read the value inside and outside the container to see that it is the same kernel |
| AddressSanitizer (ASan) + UBSan | Yes, in the smoke-test build only | Detection tools, not mitigations. ASan stops the program and prints a report at the first bad memory access. GCC's UBSan, by default, prints its report and keeps running: per the GCC instrumentation docs, only `address` defaults to no recovery. The Clang docs say ASan is not for production and costs about 2x slowdown | The lab builds the smoke test with `-fsanitize=address,undefined -g -fno-omit-frame-pointer`. FND-03 teaches the flags properly |
| Default compiler hardening (PIE, stack protector, FORTIFY_SOURCE, RELRO) | Whatever Debian's gcc does by default. Not studied here | Makes memory bugs harder to exploit | Out of scope. FND-02/03 compare a deliberately weak build with the default hardened build using `readelf`. The OpenSSF hardening guide notes that `_FORTIFY_SOURCE` is incompatible with sanitizers, so sanitizer builds in OSVR leave it off |
| Container isolation (namespaces, seccomp, capabilities, rootless user mapping) | Yes | Keeps lab processes away from your files and network. Can also block debugger features | The smoke test needs no extra privileges. gdb-in-container notes for FND-03 are in `labs/shared/fnd-base/README.md` (see the note below this table) |
| Network off at runtime (`--network=none`) | Yes | The lab cannot reach anything | Reproducibility and ethics (D10): the lab touches only what you own |

Lab-verified on rootless podman 6.1.4 (2026-11-11, `lab/README.md`, `labs/shared/fnd-base/README.md`). Under default rootless podman, gdb and LeakSanitizer both work inside the container, and no `SYS_PTRACE` is needed. Per-process ASLR disabling (`setarch -R`, and gdb's own ASLR-disable) fails with "Function not implemented", because the default seccomp profile blocks the `personality` change that `setarch -R` needs. It needs `--security-opt seccomp=unconfined` (podman-run man page, `resources.yaml`). FND-01 never needs this.

> needs-lab-verification: Docker is untested. The lab sets `ASAN_OPTIONS=detect_leaks=0` so that LeakSanitizer cannot affect the result under either engine.

Forward note: the gdb and ASLR drills in FND-03 that need fixed addresses run with `--security-opt seccomp=unconfined`. Use it only there, never for FND-01.

## Prerequisite check
Closed-book, under 10 minutes, in a terminal. Then pick your route:
- All correct **and** you have built a container image from a Dockerfile before **and** you already keep timeboxed study sessions: skip the worked example and go straight to the struggle challenge.
- Otherwise: study the worked example first. That route is the default.

1. Create `~/osvr-work/check`, change into it, and create `notes.txt` with two lines, `gcc is a compiler` and `gdb is a debugger`. Do it without opening an editor.
2. Print only the line of `notes.txt` that contains `gdb`.
3. Run `ls /does-not-exist`, then print the exit status of that command.
4. Print the full path of your container engine, or a clear message if none is installed.
5. In one sentence each: what does `>` do to an existing file, and what does `>>` do?

<details><summary>Answer key (open after attempting)</summary>

1. `mkdir -p ~/osvr-work/check && cd ~/osvr-work/check && printf 'gcc is a compiler\ngdb is a debugger\n' > notes.txt` (a heredoc or two `echo` lines also work).
2. `grep gdb notes.txt`
3. `ls /does-not-exist; echo $?`. Non-zero means failure. `$?` holds the status of the last command only.
4. `command -v podman || command -v docker || echo "no engine"`
5. `>` truncates the file and writes from the start. `>>` appends to the end.

If you missed 1 to 3, do the first modules of the Linux Luminarium dojo (`resources.yaml`) before continuing. Shell fluency is assumed from here on.
If 4 found nothing, install `podman` (preferred: it runs rootless with no daemon). The "Podman Installation Instructions" page in `resources.yaml` gives the apt/dnf/pacman command for your distribution. Docker Engine's install pages for Debian, Ubuntu and Fedora are listed there too.
</details>

## Worked example
**Instance:** a throwaway session whose goal is to prove that a stock Debian container can run a compiler. It uses a pulled image with network on and no OSVR recipe, which is different from the struggle challenge. Read every subgoal. Type every command yourself.

### Subgoal 0. Prepare the logbook (once, ever)
Goal: have a place where session logs, cards and your error log persist. `learner/` is gitignored, so it stays private.

```sh
mkdir -p learner/sessions
cp -n templates/learner/progress.yaml templates/learner/error-log.md templates/learner/cards.yaml learner/
cp -n templates/learner/profile.yaml learner/   # fill it in by hand, or let /coach intake write it
ls learner/
```

### Subgoal 1. Declare
Goal: one sentence that names an observable artefact, so that "done" can be checked by anyone.

Bad: "Learn Docker." This has no artefact and no end.
Good: "Done when `~/osvr-work/s0/gcc-version.txt` exists on the host and its first line is the gcc version printed *inside* a `debian:trixie` container."

Write it into the log now, before working. Start from the template:

```sh
cp templates/learner/session.md learner/sessions/$(date +%F).md
```

The template does not yet have two lines that the session checker requires, so add them yourself:
- Replace the template's `Goal:` line with your goal, starting with "Done when", for example `Goal: Done when ~/osvr-work/s0/gcc-version.txt exists and ...`. The checker accepts other observable phrases too ("exits 0", "passes", "exists", "prints"), but "Done when" is the OSVR habit.
- Under `## What happened`, add a line `Distractions logged: ` followed by your list, or the word `none`. It must not be left empty.

The finished log at the end of this example shows both lines in place.

### Subgoal 2. Timebox
Goal: a hard stop you decided in advance. Default is 50 minutes of work and a 10-minute break. That number is a pilot parameter with no published source (`research/benchmarks/learning-science.md` section 11), so log your actual time.

```sh
date +%H:%M                                  # note the start time in the log
( sleep 50m; printf '\a\n*** TIMEBOX OVER ***\n' ) &   # terminal bell after 50 minutes
```

### Subgoal 3. Work, with a distraction log
Goal: do only the declared task. Any urge that is not the task goes into a file, not into a new browser tab.

```sh
mkdir -p ~/osvr-work/s0 && cd ~/osvr-work/s0
SESSION_DIR=~/osvr-work/sessions/$(date +%F-%H%M); mkdir -p "$SESSION_DIR"   # one dir per session
log() { printf '%s %s\n' "$(date +%H:%M)" "$*" >> "$SESSION_DIR/distractions.txt"; }
log "why does podman ask which registry to use?"   # example entry; then back to work

"$ENGINE" pull docker.io/library/debian:trixie
"$ENGINE" run --rm -v "$PWD:/out" docker.io/library/debian:trixie \
  sh -c 'apt-get update -qq && apt-get install -y -qq gcc >/dev/null && gcc --version > /out/gcc-version.txt'
```

What each piece does: `--rm` deletes the container when it exits. `-v "$PWD:/out"` makes your host directory visible at `/out` inside it. Anything the container writes anywhere else is gone when it exits. The fully qualified name `docker.io/library/debian:trixie` avoids podman's short-name prompt. Docker accepts it too.

### Subgoal 4. Verify (outcome feedback)
Goal: check the declared done-condition, literally.

```sh
head -1 ~/osvr-work/s0/gcc-version.txt     # research observed gcc 14.2.0 in debian:trixie on 2026-11-10
ls -ln ~/osvr-work/s0/gcc-version.txt      # who owns the file the container wrote?
uname -r; "$ENGINE" run --rm docker.io/library/debian:trixie uname -r   # same kernel inside and out
```

Note the owner. Under rootless podman it is your own UID (lab-verified 2026-11-11). Under a root Docker daemon it is often `0` (root). You will need this fact in the struggle challenge.

> needs-lab-verification: file ownership of bind-mount writes under rootful Docker.

### Subgoal 5. Free recall (3 minutes, closed notes)
Goal: retrieve, not reread. Close the terminal scrollback and the notes. Set a 3-minute timer and write, from memory, under "Close-out recall" in the log: the commands you ran, what `--rm` and `-v` do, and why the kernel version matched. Then open your notes and mark what you missed. Each miss becomes a card:

```sh
python3 scripts/srs.py add --id me-s0-01 --module FND-01-linux-lab-and-learning-protocol --type concept \
  --prompt "Where does a file written inside a --rm container go if it is not under a -v mount?" \
  --answer "Nowhere durable: it is deleted with the container's filesystem when the container exits."
```

### Subgoal 6. Log the next step
Goal: the first action of the next session is a single command or a single question, written down now. Do not write "continue".

The finished log for this example, with the distraction log kept under "What happened":

```markdown
# Session 2026-11-10

Module: FND-01-linux-lab-and-learning-protocol   Timebox: 50 min   Actual: 38 min
Goal: Done when ~/osvr-work/s0/gcc-version.txt exists on the host and its first line is the gcc version printed inside a debian:trixie container.

## Warm-up recall
None (first session).

## What happened
Pulled debian:trixie with podman, ran gcc --version inside with a bind mount. First attempt wrote to /tmp inside the container and the file vanished; fixed by writing to /out.
Distractions logged: 2 (podman registry prompt; whether to install Docker as well). Both parked.

## Hints used
Highest rung: 0   On: n/a   Struggle time before hint: n/a

## Close-out recall
Recalled pull/run/--rm/-v and same-kernel point. Missed: why the file owner is my UID under rootless podman.

## New cards
- me-s0-01

## Next action
Run: "$ENGINE" build --help | less  and find the flag that names the recipe file.
```

## Struggle challenge
Attempt this closed-book before reading further. Timebox: 50 minutes (pilot parameter; log your actual time before first hint). Write down what you tried, even if you fail.

**Run it as one protocol session.** Declare, timebox, distraction log, verify, recall, log. The session log is half of the result.

Task: bring up the OSVR FND lab and make its smoke test pass.

1. Build the shared base image from `labs/shared/fnd-base/`, then the module image from `$M/lab/`. Read the two `Dockerfile`s themselves to work out what they need. Do **not** open `$M/lab/README.md`, `build.sh` or `run.sh`. The point is to work it out from the recipe and `"$ENGINE" build --help` / `run --help`.
2. Run the module image **with no network**. The smoke test must write its outputs into `~/osvr-work/fnd01/out/` on your host, and the files must be owned by you.
3. Run `"$M/lab/check.sh"` (default mode) and make it exit 0. Print `echo $?` to prove it. `check.sh` does not run the lab for you. It grades the files your own run left in `~/osvr-work/fnd01/out/` and never deletes or regenerates them, so keep them.
4. In `~/osvr-work/fnd01/note.md`, copy from the report: the error-kind line, the first frame that is in cJSON code (with file:line), and the line that says where the memory was allocated. Then add one sentence: what does the report claim happened? Do not explain why it happened.
5. Write the session log, and run `python3 labs/shared/tools/check_session.py learner/sessions/YYYY-MM-DD.md` on it.

Success: all three of the following.
- `check.sh` exits 0 on **your** outputs. It checks:
  - the report, `env.txt` and `control.txt` are present and owned by you;
  - the build used the default `LAB_CFLAGS`;
  - `env.txt` shows the network was loopback only (`net_interfaces=lo`);
  - both cJSON commits are the pinned ones;
  - the vulnerable run exited non-zero and the control exited cleanly;
  - the report has the expected error, crash location and memory-region lines.
- `note.md` has three copied fields plus one sentence.
- The session log passes the checker.

## Theory
### The lab is a reproducibility machine
A lab result is worth something only if the same inputs give the same output on another machine and another day. Your FND lab pins four inputs:

| Input | How it is pinned | What breaks if it floats |
|---|---|---|
| Base OS and compiler | `debian:trixie` by image **digest** (a content hash). A tag like `trixie` is a movable label | A new tag push silently changes gcc. That can change which stack frames appear (inlining), or whether a bug is detected at all. Source line numbers come from the pinned source, so they do not normally move |
| Packages | installed from a dated Debian snapshot; versions recorded in `/etc/osvr-packages.txt` inside the image | `apt-get install` today and next month can give different versions |
| Target source | git **commit** checked out and verified with `git rev-parse HEAD`. The cJSON tag `v1.7.17` is commit `87d8f0961a01bf09bef98ff89bae9fdec42181ee` (`research/targets/FND.md`) | Tags can be moved. A branch moves by design |
| Build flags | fixed in the smoke-test script (`LAB_CFLAGS`; `check.sh` grades only the default) | Leave out `-g` and the report loses file:line. Leave out `-fsanitize=address` and the bug may produce no visible symptom at all |

The network is off at runtime, so nothing outside these four can leak in. To show two builds are the same lab, compare these inputs and the report: base digest, package list (or gcc version), the two cJSON commits (all in `env.txt` and `/etc/osvr-packages.txt`), and the report content. Do not compare image IDs. They change on every rebuild because they include build timestamps. Rebuild with `NO_CACHE=1 "$M/lab/build.sh"`. A cached rebuild reuses the layers from last time and re-runs nothing, so of course it matches; it proves only that the cache exists. An uncached build re-runs every download, clone and verification step against the pinned inputs, and only that tests the pins. Pinning cannot control the host kernel, so ASLR and kernel version are whatever your machine runs. That is why you compare reports by function and line, never by address.

### What a container is, mechanically
A container is an ordinary process on your host kernel, given its own view of the filesystem, process list, network and user IDs, and limited in which system calls and privileges it can use. It is not a VM: there is one kernel. You proved this in the worked example with `uname -r`, and you can see it again with `cat /proc/sys/kernel/randomize_va_space` inside and outside, which gives the same value because it is one kernel setting. Two consequences follow for VR work:
- Kernel-level behaviour (ASLR policy, `ptrace` restrictions, kernel bugs) comes from the host, not the image. Kernel labs in later tracks therefore run inside QEMU, not a container.
- The container's own filesystem is a throwaway layer on top of the image. Results survive only if they are written to a bind mount (`-v host:container`).

**Rootless vs rootful.** Rootless podman runs the container under your user. "root" inside is mapped to your UID outside, so a compromised lab process has your privileges, not root's. A classic Docker daemon runs as root, and files a container writes to a bind mount can come out owned by root. If `check.sh` reports that your outputs are not owned by you, this is the first thing to check (`ls -ln`).

Sources: namespaces(7) lists the namespace types a container is built from (mount, PID, network, user and others). user_namespaces(7) describes the `uid_map` that maps inside IDs to outside IDs. The podman-run and Docker bind-mount pages document `--userns=keep-id`, `-v` and the SELinux `:z`/`:Z` options. All are in `resources.yaml`. You can also verify the observations above yourself in the lab.

### What the smoke test actually checks
The smoke test compiles a tiny harness together with cJSON 1.7.17 under ASan and feeds it the 7-byte input from the CVE record. ASan works through compile-time instrumentation plus a replacement allocator, and reports the error **at the bad access** instead of at some later crash (Clang ASan docs; the ASan paper's abstract, `resources.yaml`). FND-03 covers how it knows. For now, the report's anatomy, top to bottom:
1. **Error kind**: one `ERROR: AddressSanitizer: ...` line naming the class of bad access.
2. **Access**: whether it was a READ or WRITE, and how many bytes.
3. **Access stack**: frames `#0`, `#1`, ... The first frame in project code (not an ASan interceptor or libc) is where the program was when it misbehaved. It is not necessarily where the bug is. Separating those two is FND-04's skill.
4. **Location**: how the bad address relates to a known memory block (for example, so many bytes after a region of a given size).
5. **Allocation stack**: where that block was created.
6. **Shadow bytes**: a hex map of the surrounding memory state. Ignore it until FND-03.

**Why the lab also builds the fixed version.** The smoke test builds the same harness against the cJSON commit that fixed the bug (`3ef4e4e730e5efd381be612df41e1ff3f5bb3c32`, shipped in 1.7.18) and records the result in `control.txt`. `check.sh` expects a clean exit there. This is a negative control. It shows the report comes from the vulnerable code and not from a broken toolchain, a bad flag or a harness mistake. Every reproduction you do from now on gets a negative control.

### Why the session protocol has these steps
Each step exists for a mechanism. The evidence behind each is not equally strong, and you should know which parts are tested and which are OSVR's bet.

| Step | Mechanism | Evidence status (`research/benchmarks/learning-science.md`) |
|---|---|---|
| Declared goal with done-check | Planning, the first part of self-regulated learning (SRL). A checkable goal turns "studying" into a task with outcome feedback | Moderate: short SRL instruction raised MOOC completion, and compliers planned more (section 11). MOOC volunteers, not VR learners |
| Timebox (50/10 default) | Bounds effort and makes the break non-negotiable | None found for 50/10. Pilot parameter |
| Distraction log | Parks off-task urges without acting on them | None found. Pilot parameter |
| Verify the done-check | Fast outcome feedback | Feedback helps when it is about the task (section 5) |
| 3-minute free recall | Retrieval practice. Recall beats both recognition and rereading for retention | Strong for facts and concepts (section 1); weaker for transfer to new problems |
| Logged next step | Removes the start-up cost of the next session | None found. Pilot parameter |
| Gaps to cards, reviewed on a schedule | Spacing | Strong for facts. Spread reviews out rather than cramming (section 2) |

### Three SRL habits the protocol makes concrete
- **Plan**: the declared goal and timebox, before touching a keyboard.
- **Monitor**: the distraction log and the timer during the session, then recall and verification at the end. Monitoring means noticing *during* the session that you are off-task or stuck.
- **Seek help, on a rule**: struggle for the struggle-rule time first (20 minutes is the current pilot value), and write down what you tried. Then take one hint rung at a time (rungs 0 to 5 in `docs/ULTRALEARNING.md`). Help-seeking that comes late and with a record of what you tried is a skill. Help-seeking that comes early and vaguely is the tutorial-hell failure mode.

## Walkthrough (spoilers)
Reference solution for the struggle challenge. File and image names follow the interface in `lab/SPEC.md`. If the lab-engineer's `lab/README.md` differs, it wins.

**Declare.** "Done when `$M/lab/check.sh` exits 0 and `~/osvr-work/fnd01/note.md` holds three copied report fields and one sentence." Timer started. Log file created from the template.

**Build.** The module Dockerfile starts `FROM` the base image, so the base must exist locally first. `-f` names the recipe, and the last argument is the build context:

```sh
"$ENGINE" build -t osvr-fnd-base:1 -f labs/shared/fnd-base/Dockerfile labs/shared/fnd-base
"$ENGINE" build -t osvr-fnd01:1    -f "$M/lab/Dockerfile"           "$M/lab"
"$ENGINE" images | grep osvr-fnd
```

The build is the only step that uses the network (package install and the pinned `git clone`). Watch for the line where the Dockerfile verifies the cJSON commit. `"$M/lab/build.sh"` runs both builds in the right order.

**Run with no network, report to the host.** The simplest form is the lab wrapper `"$M/lab/run.sh"`, which writes to `~/osvr-work/fnd01/out` and adds the right user flag for your engine. By hand:

```sh
mkdir -p ~/osvr-work/fnd01/out
"$ENGINE" run --rm --network=none -v ~/osvr-work/fnd01/out:/out osvr-fnd01:1
ls -ln ~/osvr-work/fnd01/out/
```

User flags differ by engine. The image runs as root.
- **Rootless podman:** pass no user flag. Root inside maps to you, so the report is yours (lab-verified). `--userns=keep-id` also works. Do **not** pass `--user "$(id -u):$(id -g)"`: that UID is a subordinate ID on the host, so `/out` becomes unwritable and the smoke test stops with "/out is mounted but not writable".
- **Rootful Docker (untested):** add `--user "$(id -u):$(id -g)"` so the report is yours. This is Docker-only.

The image's default command runs the smoke test. It writes three files to `/out`:
- `first-asan-report.txt`: the vulnerable run's stderr, unedited.
- `control.txt`: the negative control's stderr plus a final `control exit status: N` line.
- `env.txt`: `key=value` lines covering base image digest, gcc version, cflags, both cJSON commits, kernel, `randomize_va_space`, date, `net_interfaces`, `vuln_exit_status` and `control_exit_status`.

**Verify.**

```sh
"$M/lab/check.sh"; echo "check exit: $?"
```

In default mode, `check.sh` grades the files your run left in `~/osvr-work/fnd01/out` (override with `OUT=`). It is read-only: it never deletes, regenerates or changes them, and it needs no container engine. It prints `Grading <OUT> (read-only)`, then 15 `PASS` lines in this order:
- the three files are present (3 lines);
- the three files are owned by you (3 lines);
- the default flags were used;
- `net_interfaces=lo` only;
- the two pinned cJSON commits (2 lines);
- `vuln_exit_status` is non-zero;
- the control is clean;
- `heap-buffer-overflow` is in the report;
- `cJSON.c:786 in parse_string`;
- a `located N bytes ... 7-byte region` line.

It ends with `SUMMARY: all checks passed` and exit status 0 (lab-verified on podman). On failure it prints `SUMMARY: N check(s) failed` and exits 1.

If you ran with non-default flags, it prints `NOTICE  env.txt shows non-default compiler flags: '...'`, then `FAIL  flags: graded only with default LAB_CFLAGS (...)`, and stops grading. `"$M/lab/check.sh" --health` is a separate self-test of the lab. It runs the image once into a temporary directory and ends with `LAB HEALTH OK (temp dir removed; your <OUT> was not touched)` or `LAB HEALTH FAILED`. It does not grade you.

**Copy the three fields.** The verified report (lab run 2026-11-11, gcc 14.2.0-19, `-O0`; addresses elided). Your addresses will differ. Any other difference is worth writing down:

```text
ERROR: AddressSanitizer: heap-buffer-overflow on address 0x... at pc 0x... bp 0x... sp 0x...
READ of size 1 at 0x... thread T0
    #0 0x... in parse_string /src/cjson-vuln/cJSON.c:786
    #1 0x... in parse_object /src/cjson-vuln/cJSON.c:1665
    #2 0x... in parse_value /src/cjson-vuln/cJSON.c:1365
    #3 0x... in cJSON_ParseWithLengthOpts /src/cjson-vuln/cJSON.c:1125
    #4 0x... in cJSON_ParseWithLength /src/cjson-vuln/cJSON.c:1187
    #5 0x... in main /opt/lab/harness.c:19
    #6 ... (libc frames, then _start)

0x... is located 0 bytes after 7-byte region [0x...,0x...)
allocated by thread T0 here:
    #0 0x... in malloc ...
    #1 0x... in main /opt/lab/harness.c:13

SUMMARY: AddressSanitizer: heap-buffer-overflow /src/cjson-vuln/cJSON.c:786 in parse_string
```

The vulnerable run exits with status 1 (`vuln_exit_status=1` in `env.txt`). The three fields:
- **Error kind:** the `ERROR:` line, heap-buffer-overflow.
- **First project frame:** `#0 parse_string /src/cjson-vuln/cJSON.c:786`. `harness.c:19` (frame #5) is only where the harness called into cJSON.
- **Allocation site:** `malloc` called from `main /opt/lab/harness.c:13`.

A sentence that passes: *"The program read heap memory just past the end of a 7-byte block that the harness allocated with `malloc`, and the read happened in `parse_string` at `cJSON.c:786`."* It says what and where. It does not say why the parser read too far. That question is FND-03 and FND-04 territory, so leave it open.

**Recall and log.** Three minutes closed-book. Then write the log, with the distraction list under "What happened", and a next action such as: `Run: NO_CACHE=1 "$M/lab/build.sh", then OUT=~/osvr-work/fnd01/out-rebuild "$M/lab/run.sh", and diff its env.txt against out/env.txt`. Check it:

```sh
python3 labs/shared/tools/check_session.py learner/sessions/$(date +%F).md; echo $?
```

## Consolidation
Put your struggle-challenge attempt next to the walkthrough. For each subgoal (Declare, Timebox, Build, Run and capture, Verify, Copy fields, Recall, Log), write three short lines: what you did, what the reference does, and the gap in one line. Typical gaps worth a card: building the module image before the base, writing the report inside the container instead of into the mount, a done-check that is not observable ("understand the lab"), a sentence that guesses the root cause, a next action that says "continue". Add each gap with `python3 scripts/srs.py add ...`. Also note your time-to-first-hint (or "none") in the log. It is a pilot measurement.

## Common failure points
| Symptom | Likely cause | How to see it (command) |
|---|---|---|
| `command not found` for docker | You have podman (or nothing) | `command -v podman docker` |
| podman stops to ask which registry to use for `debian` | Short image name | Use `docker.io/library/debian:...`. Check the Dockerfile's `FROM` line |
| Module build fails at `FROM` with "image not found" / pull error | Base image not built yet, or built under another name | `"$ENGINE" images` (podman lists local images as `localhost/...`) |
| `SMOKE FAIL: /out is not a mounted directory. Start the container with -v HOST_DIR:/out ...`, or `check.sh` prints `FAIL  file: ... missing or empty in <dir> (run ./run.sh first; was /out mounted? ...)` | No `-v` flag, or a typo in the mount path, so the report went into the container's throwaway filesystem | Use `"$M/lab/run.sh"`, or check the `-v` part of your `run` command |
| `SMOKE FAIL: /out is mounted but not writable by uid ...` | Rootless podman run with `--user "$(id -u):$(id -g)"`. That UID is a subordinate ID on the host and cannot write your directory (lab-verified) | Drop `--user` (or use `--userns=keep-id`). `ls -ln ~/osvr-work/fnd01/out`, `id` |
| `FAIL  owner: <file> owned by uid 0, you are <uid> (...)` | Rootful Docker wrote as root (untested) | `ls -ln ~/osvr-work/fnd01/out`. Add `--user "$(id -u):$(id -g)"`, Docker only |
| `Permission denied` on the mount on Fedora/RHEL hosts | SELinux labels on the bind mount | `ls -Z ~/osvr-work/fnd01`. Try the `:Z` mount suffix (needs-lab-verification) |
| Empty report, vulnerable run exits 0 | `LAB_CFLAGS` overridden without `-fsanitize=address`. A `-g -O0` build exits 0 with an empty report (lab-verified). Less likely: the wrong cJSON commit | `grep -E '^(cflags\|cjson_.*_commit\|.*exit_status)=' ~/osvr-work/fnd01/out/env.txt`, and the compile line the smoke test prints |
| Report frames show `harness-vuln+0x...` instead of `cJSON.c:NNN` | Built without `-g`. Function names stay, file:line goes (lab-verified). The symbolizer is not the cause: the lab needs none | Look at the compile line the smoke test prints, or the `cflags=` line in `env.txt` |
| `FAIL  network: interfaces were 'lo ...', expected only lo (run with --network=none)` | The run had network access | Re-run with `--network=none`, or use `run.sh` |
| `ReserveShadowMemoryRange failed ... Perhaps you're using ulimit -v`, exit status 134 | A virtual-memory limit in your shell. The Clang ASan docs say ASan maps (but does not reserve) 16+ TB of shadow memory on 64-bit, and that `ulimit` may not behave as expected with it (lab-verified with `ulimit -v 4000000`) | `ulimit -v`. Fix with `ulimit -v unlimited` |
| `check.sh`: `FAIL  flags: graded only with default LAB_CFLAGS (...)` (after a `NOTICE` line). `run.sh` had warned `LAB_CFLAGS override in effect: ...` | Your outputs in `out/` come from a variation run with non-default flags | Re-run `"$M/lab/run.sh"` with no `LAB_CFLAGS` set. Give variation runs their own `OUT=` directory |
| LeakSanitizer error under Docker | Docker only, untested. The lab sets `ASAN_OPTIONS=detect_leaks=0`, so this should not appear | Read the check output and report it via the coach |
| `check_session.py` prints `FAIL ...` | One of the following. **Next action:** empty, too short, or vague (`continue`, `keep going`, `carry on`, `read more`, `work on it`) with no concrete object. A concrete object is a backtick command, a path, `Run:`, a file name, or "step 3" / "card c07". **Distractions:** the `Distractions logged:` line is missing or has nothing after the colon (write `none`). **Goal:** no observable done-check | Read the `FAIL` line. It names the field |

## Next
Drills: `drills.md`. Project: `project.md`. Cards: import with `python3 scripts/srs.py import FND-01-linux-lab-and-learning-protocol`.

**Before FND-02: take the programming diagnostic (DR-0005).** It is 90 minutes, closed-book, in any language you already use. Part 1: write a roughly 50-line program to a short spec that reads a file, processes records and prints a summary. Part 2: find and fix a seeded bug in a roughly 40-line program. Part 3: predict the output of a short program with a loop and a function call, then run it to check. The diagnostic lives in `curriculum/tracks/FND/modules/FND-00-programming-on-ramp/diagnostic.md`. If that file is not there yet, run `/coach` and ask for the FND-00 diagnostic.
- Pass all three within the timebox, without searching for solutions: go to FND-02.
- Fail any part: take FND-00 (programming on-ramp in C), then retake the diagnostic in C.
Log the result in `learner/progress.yaml` either way.
