# OSVR: Open Security Vulnerability Research

A free, self-paced curriculum that takes you from "can use a terminal" to finding, root-causing, exploiting and responsibly disclosing previously unknown vulnerabilities. No degree assumed. Built for about 10 hours a week on a Linux laptop.

## I want to learn

**Go to [`curriculum/README.md`](curriculum/README.md).** It is the map: setup, how a module works, and every module in the order you should take it, with links and status.

The short version: install rootless podman, open [`FND-01`](curriculum/tracks/FND/modules/FND-01-linux-lab-and-learning-protocol/README.md), and follow its README from the top.

## What you will be able to do

1. **Map**: pick a real target and prioritise its attack surface.
2. **Find**: discover a new bug by audit, fuzzing or variant analysis, and check it is novel.
3. **Root-cause**: explain the bug to the line, its class (CWE) and the primitive it gives.
4. **Exploit**: build a reliable exploit (or, for logic bugs, an impact proof of concept) in a lab you control.
5. **Disclose**: write the advisory, run coordinated disclosure to a CVE or fix, and publish the writeup.

All hands-on work happens in local labs, on archived vulnerable versions, or inside a published bug-bounty scope. Never against systems you do not own.

## Status

The curriculum is being built in order. The status column in [`curriculum/README.md`](curriculum/README.md) shows what is ready today.

## I want to build or maintain it

- [`CLAUDE.md`](CLAUDE.md): the project's rules, Definition of Done and agent roster.
- [`docs/ULTRALEARNING.md`](docs/ULTRALEARNING.md): the learning method.
- [`decisions/`](decisions/): why the curriculum is shaped the way it is.
- [`research/`](research/): the verified evidence base. [`research/FIELD-SYNTHESIS.md`](research/FIELD-SYNTHESIS.md) is the overview.
- [`prompts/`](prompts/): the build workflow, step by step.
- `python3 scripts/validate.py` checks structure; `python3 scripts/build_index.py` regenerates the curriculum map.
