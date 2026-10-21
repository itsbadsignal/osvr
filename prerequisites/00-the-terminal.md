# 00 · The Terminal

> Own the machine you already have: shell, editor, version control, one scripting language, and the math floor.

**Requires:** a computer · **Hours:** 30–50 · **Next:** [01 · The Machine](../core/01-the-machine.md)

## Outcomes

- Navigate and manipulate a filesystem from a shell without hesitating.
- Use one editor competently.
- Commit, branch, push and read a diff.
- Automate a chore you actually have, in Python.
- Read basic mathematical notation (Σ, ∈, ⊆, f(x)) and work with exponents and logarithms.

## Resources

| Role | Resource | Cost | Notes |
|------|----------|------|-------|
| Core | [pwn.college · Linux Luminarium](https://pwn.college/dojos) | Free | Browser workspace, nothing to install. Teaches the shell as adversarial territory. |
| Core | [MIT · The Missing Semester](https://missing.csail.mit.edu/) | Free | Shell, editors, tooling, debugging, git. |
| Core | [Automate the Boring Stuff with Python](https://automatetheboringstuff.com/) | Free | Through functions and file I/O. pwntools, fuzzers and angr all assume Python. |
| Alt | [OverTheWire · Bandit](https://overthewire.org/wargames/bandit/) | Free | Gentler than Luminarium, less thorough. |
| Alt | [The Linux Command Line](https://linuxcommand.org/tlcl.php) (Shotts) | Free | If you prefer a book. |
| Ref | [Pro Git](https://git-scm.com/book/en/v2) | Free | Chapters 1–3. |
| Ref | [Khan Academy · Algebra](https://www.khanacademy.org/math/algebra) · [Book of Proof](https://richardhammack.github.io/BookOfProof/) ch. 1 | Free | Math floor. If Book of Proof ch. 1 reads fine, you're past it. |

Calculus, linear algebra and statistics aren't needed. Only the RF track needs calculus.

## Milestones

- **~15 h:** In one pipeline, written from memory: find every file over 10 MB modified in the last week, sort by size, write to a file.

## Ship

A public repo with a script that automates something you were doing by hand, plus a README explaining what it does and why.

## Gate · 2 hours

1. From a directory of mixed files, produce a shell-only report: counts by type, the ten largest, and any containing a given string.
2. Clone a repo, branch, commit with a meaningful message, and explain what a merge conflict is and how you'd resolve it.
3. Write a script that takes a filename argument, handles a missing file, and produces useful output.

**Fail if:** you look up basic navigation, or the script crashes on a missing file.
