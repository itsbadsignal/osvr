#!/usr/bin/env python3
"""OSVR structural validator.

Checks the skill tree DAG and the structural parts of the module Definition of Done
(D2, D3, D4, D5, D7, D8). Judgement-based checks (D1, D6, D9, D10, accuracy) are the
curriculum-auditor's job.

Usage:
  python3 scripts/validate.py                    # whole repo
  python3 scripts/validate.py --tree-only        # DAG only
  python3 scripts/validate.py --module BX-07-tcache-poisoning
  python3 scripts/validate.py --track BX
  python3 scripts/validate.py --stale-days 90    # stricter freshness

Exit code: 0 no errors, 1 errors found, 2 could not run.
"""
import argparse
import datetime as dt
import re
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    sys.exit("PyYAML missing: pip install pyyaml  (Arch: pacman -S python-yaml)")

OUTCOMES = {"map", "find", "rootcause", "exploit", "disclose"}
STATUSES = {"planned", "drafting", "ready", "deprecated"}
ID_RE = re.compile(r"^([A-Z]{2,4})-(\d{2})-[a-z0-9]+(?:-[a-z0-9]+)*$")
MODULE_FILES = ["README.md", "drills.md", "project.md", "rubric.md", "cards.yaml", "resources.yaml"]
CARD_TYPES = {"fact", "concept", "procedure", "diagram", "code"}
PLACEHOLDER = re.compile(r"<(?:MODULE_ID|TRACK|Title|challenge|testable verb|name|ids|pinned|"
                         r"real bug[^>]*|the rds[^>]*|one task[^>]*|CVE / codebase / firmware)>")
VAGUE_VERBS =re.compile(r"\b(understand|learn about|be familiar with|know about|appreciate|be aware of)\b", re.I)


class Report:
    def __init__(self):
        self.errors, self.warnings = [], []

    def err(self, where, msg):
        self.errors.append(f"ERROR  {where}: {msg}")

    def warn(self, where, msg):
        self.warnings.append(f"WARN   {where}: {msg}")


def load_yaml(path, rep):
    try:
        with open(path, encoding="utf-8") as f:
            return yaml.safe_load(f) or {}
    except FileNotFoundError:
        rep.err(str(path), "file not found")
    except yaml.YAMLError as e:
        rep.err(str(path), f"invalid YAML: {e}")
    return None


def check_tree(tree, rep):
    tracks = tree.get("tracks") or {}
    nodes = tree.get("nodes") or []
    by_id = {}
    for i, n in enumerate(nodes):
        nid = n.get("id", f"<node #{i}>")
        if nid in by_id:
            rep.err(nid, "duplicate id")
        by_id[nid] = n
        m = ID_RE.match(nid)
        if not m:
            rep.err(nid, "id must match <TRACK>-<NN>-<slug> (lowercase slug)")
        elif m.group(1) != n.get("track"):
            rep.err(nid, f"id prefix {m.group(1)} != track {n.get('track')}")
        if n.get("track") not in tracks:
            rep.err(nid, f"track {n.get('track')} not declared under tracks:")
        if n.get("status") not in STATUSES:
            rep.err(nid, f"status must be one of {sorted(STATUSES)}")
        outs = set(n.get("outcomes") or [])
        if not outs:
            rep.err(nid, "no outcomes: node traces to no terminal outcome")
        elif outs - OUTCOMES:
            rep.err(nid, f"unknown outcomes {sorted(outs - OUTCOMES)}")
        h = n.get("hours")
        if not isinstance(h, (int, float)) or h <= 0:
            rep.err(nid, "hours must be a positive number")
        elif h > 60:
            rep.warn(nid, f"{h}h is large for one module; consider splitting")
        if not n.get("rds"):
            rep.err(nid, "missing rds (rate-determining step)")
        if n.get("status") in {"drafting", "ready"} and not n.get("direct_target"):
            rep.err(nid, "drafting/ready module needs direct_target (D1)")

    for nid, n in by_id.items():
        for p in n.get("prereqs") or []:
            if p not in by_id:
                rep.err(nid, f"prereq {p} does not exist (D8)")
            elif by_id[p].get("status") == "deprecated" and n.get("status") != "deprecated":
                rep.warn(nid, f"depends on deprecated {p}")

    # cycle detection (iterative DFS, colour marking)
    WHITE, GREY, BLACK = 0, 1, 2
    colour = {k: WHITE for k in by_id}
    for start in by_id:
        if colour[start] != WHITE:
            continue
        stack = [(start, iter(by_id[start].get("prereqs") or []))]
        path = [start]
        colour[start] = GREY
        while stack:
            node, it = stack[-1]
            nxt = next(it, None)
            if nxt is None:
                colour[node] = BLACK
                stack.pop()
                path.pop()
            elif nxt in colour:
                if colour[nxt] == GREY:
                    cyc = path[path.index(nxt):] + [nxt]
                    rep.err(nxt, "prerequisite cycle: " + " requires ".join(cyc))
                elif colour[nxt] == WHITE:
                    colour[nxt] = GREY
                    path.append(nxt)
                    stack.append((nxt, iter(by_id[nxt].get("prereqs") or [])))

    used_outcomes = set().union(*(set(n.get("outcomes") or []) for n in nodes)) if nodes else set()
    for o in sorted(OUTCOMES - used_outcomes):
        rep.warn("skill-tree", f"no node serves terminal outcome '{o}'")
    for t, meta in tracks.items():
        th = sum(n.get("hours") or 0 for n in nodes if n.get("track") == t and n.get("status") != "deprecated")
        if th == 0:
            rep.warn(t, "track declared but has no nodes")
    core_h = sum(n.get("hours") or 0 for n in nodes
                 if (tracks.get(n.get("track")) or {}).get("core") and n.get("status") != "deprecated")
    return by_id, core_h


def section(text, heading):
    """Return the body of '## heading' (prefix match) up to the next '## '."""
    m = re.search(rf"^##\s+{re.escape(heading)}[^\n]*\n(.*?)(?=^##\s|\Z)", text, re.M | re.S)
    return m.group(1) if m else None


def check_module(nid, node, root, stale_days, today, rep):
    mdir = root / "curriculum" / "tracks" / node["track"] / "modules" / nid
    if not mdir.is_dir():
        rep.err(nid, f"module directory missing: {mdir.relative_to(root)}")
        return
    for f in MODULE_FILES:
        p = mdir / f
        if not p.is_file():
            rep.err(nid, f"missing {f}")
        else:
            left = sorted(set(PLACEHOLDER.findall(p.read_text(encoding="utf-8"))))
            if left:
                rep.err(nid, f"{f} still has template placeholders: {', '.join(left)}")

    readme = (mdir / "README.md")
    if readme.is_file():
        text = readme.read_text(encoding="utf-8")
        obj = section(text, "Objectives")
        if obj is None:
            rep.err(nid, "README has no '## Objectives' (D2)")
        else:
            items = re.findall(r"^\s*(?:\d+\.|[-*])\s+(.+)$", obj, re.M)
            if not 3 <= len(items) <= 7:
                rep.err(nid, f"{len(items)} objectives; need 3 to 7 (D2)")
            for it in items:
                if VAGUE_VERBS.search(it):
                    rep.err(nid, f"untestable objective (D2): '{it.strip()[:70]}'")
        s_pos = text.find("## Struggle challenge")
        w_pos = text.find("## Walkthrough")
        if s_pos < 0:
            rep.err(nid, "README has no '## Struggle challenge' (D5)")
        elif 0 <= w_pos < s_pos:
            rep.err(nid, "walkthrough appears before the struggle challenge (D5)")
        p_pos = text.find("## Prerequisite check")
        e_pos = text.find("## Worked example")
        c_pos = text.find("## Consolidation")
        if p_pos < 0:
            rep.err(nid, "README has no '## Prerequisite check' (D5, DR-0004)")
        elif s_pos >= 0 and p_pos > s_pos:
            rep.err(nid, "prerequisite check must come before the struggle challenge (D5)")
        if e_pos < 0:
            rep.err(nid, "README has no '## Worked example' (D5, DR-0004)")
        elif s_pos >= 0 and e_pos > s_pos:
            rep.err(nid, "worked example must come before the struggle challenge (D5)")
        if c_pos < 0:
            rep.err(nid, "README has no '## Consolidation' (D5, DR-0004)")
        elif s_pos >= 0 and c_pos < s_pos:
            rep.err(nid, "consolidation must come after the struggle challenge (D5)")
        if section(text, "Mitigation context") is None:
            rep.err(nid, "README has no '## Mitigation context' (D9)")
        if "TODO(research)" in text:
            rep.warn(nid, "README contains TODO(research)")

    drills = mdir / "drills.md"
    if drills.is_file():
        dt_ = drills.read_text(encoding="utf-8")
        if section(dt_, "Rate-determining step") is None:
            rep.err(nid, "drills.md has no '## Rate-determining step' (D3)")
        n_drills = len(re.findall(r"^##\s+Drill\s+\d+", dt_, re.M))
        if n_drills < 3:
            rep.err(nid, f"{n_drills} drills; need at least 3 (D3)")

    cards_f = mdir / "cards.yaml"
    if cards_f.is_file():
        data = load_yaml(cards_f, rep)
        cards = (data or {}).get("cards") or []
        if len(cards) < 12:
            rep.err(nid, f"{len(cards)} cards; need at least 12 (D4)")
        types, ids = set(), set()
        for c in cards:
            cid = c.get("id", "?")
            if cid in ids:
                rep.err(nid, f"duplicate card id {cid}")
            ids.add(cid)
            if not str(cid).startswith(nid):
                rep.err(nid, f"card id {cid} should start with {nid}")
            if c.get("type") not in CARD_TYPES:
                rep.err(nid, f"card {cid} bad type {c.get('type')}")
            types.add(c.get("type"))
            p, a = str(c.get("prompt", "")), str(c.get("answer", ""))
            if not p or not a:
                rep.err(nid, f"card {cid} missing prompt or answer")
            elif len(a.split()) > 80:
                rep.warn(nid, f"card {cid} answer is {len(a.split())} words; split it")
            elif a.strip().lower() in p.lower():
                rep.err(nid, f"card {cid} answer is contained in its prompt (D4)")
        if cards and len(types) < 3:
            rep.warn(nid, f"cards use only {sorted(t for t in types if t)}; mix at least 3 types")

    res_f = mdir / "resources.yaml"
    if res_f.is_file():
        data = load_yaml(res_f, rep)
        res = (data or {}).get("resources") or []
        core = 0
        for r in res:
            title = r.get("title", r.get("url", "?"))[:50]
            if r.get("role") == "core":
                core += 1
            v = r.get("verified")
            if not r.get("url"):
                rep.err(nid, f"resource '{title}' has no url")
            if v in (None, "", "null") or r.get("status") == "unverified":
                rep.err(nid, f"resource '{title}' unverified (D7)")
                continue
            try:
                vd = v if isinstance(v, dt.date) else dt.date.fromisoformat(str(v))
                age = (today - vd).days
                if age > stale_days:
                    rep.err(nid, f"resource '{title}' verified {age} days ago (> {stale_days}) (D7)")
            except ValueError:
                rep.err(nid, f"resource '{title}' verified date not ISO: {v}")
            if r.get("status") in {"dead", "changed"}:
                rep.err(nid, f"resource '{title}' status {r.get('status')}")
        if core > 3:
            rep.err(nid, f"{core} core resources; max 3")
        if node.get("status") == "ready" and not res:
            rep.err(nid, "ready module with no resources")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--root", default=".", help="repo root (default: cwd)")
    ap.add_argument("--tree-only", action="store_true")
    ap.add_argument("--module")
    ap.add_argument("--track")
    ap.add_argument("--stale-days", type=int, default=180)
    a = ap.parse_args()

    root = Path(a.root).resolve()
    rep = Report()
    tree_path = root / "curriculum" / "skill-tree.yaml"
    tree = load_yaml(tree_path, rep)
    if tree is None:
        print("\n".join(rep.errors))
        sys.exit(2)

    by_id, core_h = check_tree(tree, rep)
    today = dt.date.today()

    if not a.tree_only:
        if a.module:
            if a.module not in by_id:
                rep.err(a.module, "not in skill-tree.yaml")
                scope = []
            else:
                scope = [a.module]
        else:
            scope = [k for k, n in by_id.items()
                     if n.get("status") in {"drafting", "ready"} and (not a.track or n.get("track") == a.track)]
        for nid in scope:
            check_module(nid, by_id[nid], root, a.stale_days, today, rep)

    counts = {s: sum(1 for n in by_id.values() if n.get("status") == s) for s in sorted(STATUSES)}
    for line in rep.errors + rep.warnings:
        print(line)
    print(f"\nnodes: {len(by_id)}  " + "  ".join(f"{k}: {v}" for k, v in counts.items()))
    print(f"core hours: {core_h}  (~{core_h / 10 / 4.33:.0f} months at 10 h/week)")
    print(f"errors: {len(rep.errors)}  warnings: {len(rep.warnings)}")
    sys.exit(1 if rep.errors else 0)


if __name__ == "__main__":
    main()
