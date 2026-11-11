#!/usr/bin/env python3
"""Structural check for an OSVR session log (format: templates/learner/session.md).

Usage: check_session.py FILE        Exit 0 if every check passes, 1 otherwise,
2 on usage/IO error. One message per failure, naming the field. Stdlib only.

Heuristics (they check structure, not quality; the grader judges goal quality):
  Module:     present, not the template placeholder (<ID>)
  Timebox:    "Timebox: N min", N an integer > 0
  Actual:     "Actual: N min", N an integer >= 0
  Goal:       non-empty, not a placeholder, and contains an observable-done phrase:
              "done when", "done if", "done-check", "success:", "exits 0",
              "exit status", "passes", "exists", or "prints"
  What happened: has a line starting "Distractions" (optionally "Distractions logged")
              followed by a colon and content: a count, "none", or a list. The label
              alone ("Distractions logged:") fails; write "none" if there were none
  Hints used: has "Highest rung: N"
  Close-out recall: non-empty, not the template placeholder
  Next action: non-empty; not just "continue" / "keep going" / "same" /
              "n/a" / "tbd"; and either >= 4 words or contains a backtick,
              a path (a "/" or "~"), "Run:" or a "?" (a precise question).
              Vague-phrase rule: if the text contains a vague phrase (continue,
              keep going, carry on, read more, work on it, more of the same,
              keep at it) it must ALSO name a concrete object: a backtick span, a
              path ("/" or "~"), "Run:", a file name with an extension (x.c, env.txt),
              or "step"/"subgoal"/"rung"/"card"/"line" followed by a number or id.
              "Continue with the lab" and "Read more about stuff" fail;
              "Continue: fix the owner check in check.sh" passes.
"""
import re
import sys

OBSERVABLE = re.compile(
    r"done when|done if|done-check|success:|exits? 0|exit status|passes|exists|prints",
    re.I)
VAGUE_PHRASE = re.compile(
    r"\bcontinue\b|\bkeep going\b|\bcarry on\b|\bread more\b|\bwork on (it|this|that)\b"
    r"|\bmore of the same\b|\bkeep at it\b", re.I)
CONCRETE = re.compile(
    r"`[^`]+`|[/~]|\bRun:|\b[\w-]+\.[a-z]{1,4}\b|\b(step|subgoal|rung|card|line)\s*#?\w*\d", re.I)
VAGUE_NEXT = {"continue", "keep going", "same", "n/a", "na", "tbd", "none",
              "continue where i left off", "continue the lab", "keep going."}


def sections(text):
    """Return {heading: body} for '## ' sections."""
    out, cur = {}, None
    for line in text.splitlines():
        m = re.match(r"##\s+(.+?)\s*$", line)
        if m:
            cur = m.group(1).strip().lower()
            out[cur] = []
        elif cur is not None:
            out[cur].append(line)
    return {k: "\n".join(v).strip() for k, v in out.items()}


def placeholder(s):
    return bool(re.fullmatch(r"<[^>]*>", s.strip())) or s.strip() == ""


def check(text):
    errs = []
    m = re.search(r"^Module:\s*(\S.*?)(?:\s{2,}|$)", text, re.M)
    if not m or placeholder(m.group(1)):
        errs.append("Module: missing or still the template placeholder")
    for label, minimum in (("Timebox", 1), ("Actual", 0)):
        m = re.search(rf"\b{label}:\s*(\d+)\s*min\b", text)
        if not m:
            errs.append(f"{label}: expected '{label}: N min' with a number")
        elif int(m.group(1)) < minimum:
            errs.append(f"{label}: must be at least {minimum} min")

    m = re.search(r"^Goal:[ \t]*(.*(?:\n(?![ \t]*\n|##|\w+:).*)*)", text, re.M)
    goal = m.group(1).strip() if m else ""
    if not goal or placeholder(goal):
        errs.append("Goal: missing, empty or placeholder")
    elif not OBSERVABLE.search(goal):
        errs.append("Goal: no observable done-check (write 'Done when <artefact or command result>')")

    sec = sections(text)

    def need(name):
        body = sec.get(name)
        if body is None:
            errs.append(f"## {name.title()}: section missing")
            return None
        return body

    wh = need("what happened")
    if wh is not None:
        dm = re.search(r"^\s*Distractions(?:\s+logged)?\s*:?[ \t]*([^\n]*)", wh, re.M | re.I)
        if not dm or not re.search(r"\w", dm.group(1)):
            errs.append("What happened: needs a line starting 'Distractions' with a count or list (or 'none')")
    hu = need("hints used")
    if hu is not None and not re.search(r"Highest rung:\s*\d", hu):
        errs.append("Hints used: needs 'Highest rung: N'")
    cr = need("close-out recall")
    if cr is not None and placeholder(cr):
        errs.append("Close-out recall: empty or placeholder")
    na = need("next action")
    if na is not None:
        t = na.strip()
        if placeholder(t) or t.lower().strip(" .") in VAGUE_NEXT:
            errs.append("Next action: empty or vague ('continue'); name a command, file or question")
        elif VAGUE_PHRASE.search(t) and not CONCRETE.search(t):
            errs.append("Next action: vague ('continue', 'read more', ...) with no concrete object; name a file, command or step")
        elif len(t.split()) < 4 and not re.search(r"[`/~?]|Run:", t):
            errs.append("Next action: too short; use at least 4 words or a command/path/question")
    return errs


def main(argv):
    if len(argv) != 2:
        print(__doc__.split("\n\n")[0], file=sys.stderr)
        return 2
    try:
        text = open(argv[1], encoding="utf-8").read()
    except OSError as e:
        print(f"cannot read {argv[1]}: {e}", file=sys.stderr)
        return 2
    errs = check(text)
    for e in errs:
        print(f"FAIL {e}")
    if errs:
        return 1
    print("PASS session log structure OK (goal quality is not checked)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
