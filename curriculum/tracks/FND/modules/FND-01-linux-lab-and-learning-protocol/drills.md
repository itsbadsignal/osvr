# Drills: FND-01-linux-lab-and-learning-protocol

## Rate-determining step
Running a declared-goal, timeboxed session that ends with free recall and a logged next step.

This bottlenecks the whole curriculum, not just this module. Every later module assumes you can sit down, name one checkable thing, do it inside a timebox, and leave the next session an obvious first move. Learners who cannot do this drift into reading and video (the tutorial-hell failure mode) and lose days re-orienting between sessions. The hardest part is usually not the timer. It is writing a goal with an **observable done-check** that fits **one** timebox, and writing a next step concrete enough to start cold.

The lab bring-up (Drill 4) is drilled as well, because every FND module starts with it and it should cost minutes, not a session.

## Drill 1: Goal sharpening
Type: cognitive-component
Goal: turn vague intentions into session goals with an observable done-check that fit a single 50-minute timebox.
Setup: a text file and the ten intentions below. No lab needed.
1. "Learn Docker."
2. "Get better at gdb."
3. "Read about ASan."
4. "Start FND-02."
5. "Understand containers."
6. "Fix my lab."
7. "Study heap exploitation."
8. "Do some cards."
9. "Look at the cJSON code."
10. "Set up my environment properly."

For each, write one goal in the form *"Done when ARTEFACT shows CONDITION."* If an intention is too big for one timebox, write the first timebox's slice only and mark it `(slice)`.
Time target: 10 minutes for all ten.
Success check: run each goal through these three tests. Write each test's verdict down, not in your head.
- **Observable**: could someone else check it from a file, a command output or an exit code, without asking you?
- **Bounded**: could it plausibly be done in 50 minutes by you today?
- **Single**: is there exactly one done-condition (no "and also")?
All ten must pass all three. Example of a pass for 6: "Done when `"$M/lab/check.sh"` exits 0 on a rebuilt image." Example of a fail: "Done when I understand why the lab broke" (not observable).
Make it harder: use your own real backlog instead of this list, and do it in 5 minutes. Or swap lists with another learner and grade theirs against the three tests.

## Drill 2: Recall rep
Type: time-sliced (the session's close phase only)
Goal: make the 3-minute free recall productive, with high recall and an honest gap list, instead of a vague "I learned stuff".
Setup: after any 20 to 30 minutes of work or reading (any module, any source), close everything. Set a 3-minute timer.
1. Write from memory: every command, term and claim you met, as a bullet list.
2. Timer off. Open your notes or the source and tick each bullet as correct, wrong or missing.
3. Count: recalled-correct / (recalled-correct + missed). Each missed or wrong item becomes one card via `python3 scripts/srs.py add`.
Time target: 3 minutes of recall + 5 minutes of scoring.
Success check: a written ratio, and at least one new card or an explicit "0 gaps" with the source checked. Track the ratio across sessions in your logs. A ratio near 100% every time usually means the recall list is too shallow (names without meaning). Add "and what it does" to each bullet.
Make it harder: delay the recall to the start of the next day's session, before the warm-up. Or recall in the form of a command sequence you then actually run on a fresh terminal.

## Drill 3: Cold start
Type: time-sliced (the session's opening, measured)
Goal: write next-step notes that let you start working within minutes of sitting down.
Setup: at the end of any session, stop *before* a natural stopping point and write the Next action as one runnable command, one file:line to open, or one precise question. At the start of the next session, start a stopwatch when you sit down and stop it at your first keystroke of real work (not reading the log twice).
Time target: under 5 minutes from sitting down to first real keystroke. This is a pilot value; log yours.
Success check: the stopwatch value is in the session log under "What happened", and the logged action was executed as written, with no "what was I doing?" re-reading. If you had to reconstruct context, rewrite the previous next action as it should have been and keep both in the log.
Make it harder: leave 48 hours between sessions. Or hand your next action to someone else (or the coach) and see if they can run it without questions.

## Drill 4: Lab from zero
Type: copycat (reproduce the walkthrough, then from memory)
Goal: proceduralise lab bring-up so every later module starts in minutes.
Setup: each rep is a clean, uncached rebuild into a fresh output directory. `reset.sh` deletes the outputs in `~/osvr-work/fnd01/out` (as well as the image). So **before your first reset**, keep a reference copy of your first graded run: `cp -a ~/osvr-work/fnd01/out ~/osvr-work/fnd01/ref`.
- Rep 1 may use the walkthrough. Reps 2 and 3 are from memory.
- Rebuild uncached with `NO_CACHE=1 "$M/lab/build.sh"`. A cached rebuild re-runs nothing and proves nothing.
- For the reps from memory, the challenge is to type the two `"$ENGINE" build --no-cache ...` commands yourself (base first, then module).
- Then run with `--network=none` and a bind mount to `~/osvr-work/fnd01/out-repN`, and grade it with `OUT=~/osvr-work/fnd01/out-repN "$M/lab/check.sh"`.
- To start a rep from an empty state, use `"$M/lab/reset.sh"`. It removes `out/` and the module image, and ends `reset done (...)`. `FULL=1` also removes the base image and prunes dangling images. If another module (e.g. FND-02) still uses the base image, it says `base image NOT removed ...`.

Time target: 10 minutes of your typing and decisions. Exclude time spent waiting on downloads and builds, and record wait time separately.
Success check:
- `check.sh` exits 0 on `out-repN`.
- `diff ~/osvr-work/fnd01/ref/env.txt ~/osvr-work/fnd01/out-repN/env.txt` shows the same base digest, gcc version and cJSON commits. Only the date and similar fields differ.
- For reps that use `build.sh`, its log in `~/osvr-work/fnd01/build-logs/` has no "Using cache" lines (podman).
Make it harder: write the four commands as a shell function in your `~/.bashrc` / `~/.zshrc` from memory and use it on rep 3. Or do the whole rep with the other engine (podman vs docker) in a VM.

## Drill 5: One-session magnification
Type: magnifying-glass
Goal: look closely at where your sessions actually leak time.
Setup: one ordinary 50-minute session on any module. Log *every* off-task urge with a timestamp, and every time you switch window or tool. Use the worked example's helper, with a fresh directory for this session:

```sh
SESSION_DIR=~/osvr-work/sessions/$(date +%F-%H%M); mkdir -p "$SESSION_DIR"
log() { printf '%s %s\n' "$(date +%H:%M)" "$*" >> "$SESSION_DIR/distractions.txt"; }
```

After the session, spend 20 minutes classifying each entry: (a) a real blocker for the goal, (b) an interesting tangent, (c) avoidance, (d) environment friction (tool broke, slow download, wrong path).
Time target: one session + 20 minutes of analysis. Do it once per module for the first three modules.
Success check: a classified list in the session log, plus one concrete change for next session. For example, (d) items become a lab fix or a failure-point note in `maintenance/inbox.md` via the coach; (a) items become the next goal; (b) items go to a parked list.
Make it harder: run it on your hardest module so far, where avoidance is most likely.

## Owned when
3 consecutive sessions whose logs pass `labs/shared/tools/check_session.py` first time. Each must have a goal that passes the three tests of Drill 1, a recall ratio recorded, and a next action that started the following session within the Drill 3 target. In addition, Drill 4 done from memory under the time target twice.
