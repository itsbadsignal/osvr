#!/usr/bin/env python3
"""OSVR spaced repetition (SM-2 variant) over learner/cards.yaml.

Commands:
  import <MODULE_ID> [...]    copy a module's seed deck into the learner deck (skips existing ids)
  add --id ID --module M --type T --prompt P --answer A [--source S]
  due [--limit N] [--count]   list due cards (prompt only), most overdue first
  show <card_id>              print prompt and answer (for grading)
  grade <card_id> <0-5>       record a free-recall grade
  reset <card_id>             reset scheduling (after rewriting a leech)
  stats                       deck summary

Grades: 0 blank, 1 wrong, 2 wrong but recognised, 3 correct with effort, 4 correct, 5 instant.
A card with lapses >= 4 is a leech: rewrite or split it instead of drilling harder.
"""
import argparse
import datetime as dt
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    sys.exit("PyYAML missing: pip install pyyaml  (Arch: pacman -S python-yaml)")

LEECH = 4
SCHED = {"ease": 2.5, "interval": 0, "reps": 0, "lapses": 0}


def today():
    return dt.date.today()


def deck_path(root):
    return root / "learner" / "cards.yaml"


def load(root):
    p = deck_path(root)
    if not p.exists():
        return {"cards": []}
    with open(p, encoding="utf-8") as f:
        d = yaml.safe_load(f) or {}
    d.setdefault("cards", [])
    return d


def save(root, d):
    p = deck_path(root)
    p.parent.mkdir(parents=True, exist_ok=True)
    tmp = p.with_suffix(".yaml.tmp")
    with open(tmp, "w", encoding="utf-8") as f:
        yaml.safe_dump(d, f, sort_keys=False, allow_unicode=True, width=100)
    tmp.replace(p)


def as_date(v):
    if isinstance(v, dt.date):
        return v
    return dt.date.fromisoformat(str(v)) if v else today()


def find(d, cid):
    for c in d["cards"]:
        if c.get("id") == cid:
            return c
    sys.exit(f"no card with id {cid}")


def ensure_sched(c):
    for k, v in SCHED.items():
        c.setdefault(k, v)
    c.setdefault("due", today().isoformat())


def sm2(c, q):
    """Update card c in place for grade q (0-5)."""
    ensure_sched(c)
    if q < 3:
        c["reps"] = 0
        c["interval"] = 1
        c["lapses"] += 1
    else:
        c["reps"] += 1
        if c["reps"] == 1:
            c["interval"] = 1
        elif c["reps"] == 2:
            c["interval"] = 6
        else:
            c["interval"] = max(1, round(c["interval"] * c["ease"]))
    c["ease"] = round(max(1.3, c["ease"] + 0.1 - (5 - q) * (0.08 + (5 - q) * 0.02)), 2)
    c["due"] = (today() + dt.timedelta(days=c["interval"])).isoformat()
    c["last"] = today().isoformat()
    c["last_grade"] = q


def find_module_dir(root, mid):
    hits = list((root / "curriculum" / "tracks").glob(f"*/modules/{mid}"))
    if not hits:
        sys.exit(f"module {mid} not found under curriculum/tracks/*/modules/")
    return hits[0]


def cmd_import(root, a):
    d = load(root)
    have = {c.get("id") for c in d["cards"]}
    added = 0
    for mid in a.modules:
        with open(find_module_dir(root, mid) / "cards.yaml", encoding="utf-8") as f:
            seed = (yaml.safe_load(f) or {}).get("cards") or []
        for c in seed:
            if c.get("id") in have:
                continue
            c = dict(c)
            c["module"] = mid
            c.setdefault("source", "module")
            ensure_sched(c)
            d["cards"].append(c)
            have.add(c["id"])
            added += 1
    save(root, d)
    print(f"imported {added} cards")


def cmd_add(root, a):
    d = load(root)
    if any(c.get("id") == a.id for c in d["cards"]):
        sys.exit(f"card {a.id} exists")
    c = {"id": a.id, "module": a.module, "type": a.type, "prompt": a.prompt,
         "answer": a.answer, "source": a.source}
    ensure_sched(c)
    d["cards"].append(c)
    save(root, d)
    print(f"added {a.id}")


def due_cards(d):
    t = today()
    due = [c for c in d["cards"] if as_date(c.get("due")) <= t and not c.get("suspended")]
    due.sort(key=lambda c: (as_date(c.get("due")), -c.get("lapses", 0)))
    return due


def cmd_due(root, a):
    due = due_cards(load(root))
    if a.count:
        print(len(due))
        return
    for c in due[: a.limit]:
        flag = "  [LEECH]" if c.get("lapses", 0) >= LEECH else ""
        print(f"{c['id']}  ({c.get('type', '?')}, {c.get('module', '?')}){flag}\n  {c.get('prompt')}\n")
    if len(due) > a.limit:
        print(f"... {len(due) - a.limit} more due")


def cmd_show(root, a):
    c = find(load(root), a.card_id)
    print(f"PROMPT: {c.get('prompt')}\nANSWER: {c.get('answer')}")


def cmd_grade(root, a):
    if not 0 <= a.grade <= 5:
        sys.exit("grade must be 0-5")
    d = load(root)
    c = find(d, a.card_id)
    sm2(c, a.grade)
    save(root, d)
    msg = f"{c['id']}: grade {a.grade}, next due {c['due']} (interval {c['interval']}d, ease {c['ease']})"
    if c["lapses"] >= LEECH:
        msg += f"\nLEECH: {c['lapses']} lapses. Rewrite or split this card, then run: srs.py reset {c['id']}"
    print(msg)


def cmd_reset(root, a):
    d = load(root)
    c = find(d, a.card_id)
    c.update(SCHED)
    c["due"] = today().isoformat()
    c.pop("last_grade", None)
    save(root, d)
    print(f"reset {a.card_id}")


def cmd_stats(root, a):
    d = load(root)
    cards = d["cards"]
    if not cards:
        print("deck empty")
        return
    due = due_cards(d)
    leeches = [c["id"] for c in cards if c.get("lapses", 0) >= LEECH]
    mature = sum(1 for c in cards if c.get("interval", 0) >= 21)
    future = sorted(as_date(c.get("due")) for c in cards if as_date(c.get("due")) > today())
    by_mod = {}
    for c in cards:
        by_mod[c.get("module", "?")] = by_mod.get(c.get("module", "?"), 0) + 1
    print(f"cards: {len(cards)}  due now: {len(due)}  mature (>=21d): {mature}  leeches: {len(leeches)}")
    if future:
        print(f"next due after today: {future[0].isoformat()}")
    if leeches:
        print("leeches: " + ", ".join(leeches))
    print("by module: " + ", ".join(f"{k}={v}" for k, v in sorted(by_mod.items())))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--root", default=".")
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("import"); p.add_argument("modules", nargs="+"); p.set_defaults(f=cmd_import)
    p = sub.add_parser("add")
    for k in ("id", "module", "type", "prompt", "answer"):
        p.add_argument(f"--{k}", required=True)
    p.add_argument("--source", default="session"); p.set_defaults(f=cmd_add)
    p = sub.add_parser("due"); p.add_argument("--limit", type=int, default=25)
    p.add_argument("--count", action="store_true"); p.set_defaults(f=cmd_due)
    p = sub.add_parser("show"); p.add_argument("card_id"); p.set_defaults(f=cmd_show)
    p = sub.add_parser("grade"); p.add_argument("card_id"); p.add_argument("grade", type=int); p.set_defaults(f=cmd_grade)
    p = sub.add_parser("reset"); p.add_argument("card_id"); p.set_defaults(f=cmd_reset)
    p = sub.add_parser("stats"); p.set_defaults(f=cmd_stats)
    a = ap.parse_args()
    a.f(Path(a.root).resolve(), a)


if __name__ == "__main__":
    main()
