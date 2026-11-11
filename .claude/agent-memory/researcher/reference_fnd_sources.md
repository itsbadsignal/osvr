---
name: fnd-sources-and-dead-ends
description: Which FND-track sources were reachable via WebFetch (and which are bot-blocked) as of 2026-11-10
metadata:
  type: reference
---

Reachable: clang ASan docs, GCC instrumentation options, OpenSSF compiler hardening guide (large, use offset), Debian dpkg-buildflags man page (manpages.debian.org), Launchpad bugs, pwn.college pages, p.ost2.fyi course /about pages (ost2.fyi/<code> gives only a redirect notice), csapp.cs.cmu.edu labs, man7.org man pages, Intel SDM landing page, exercism, cs50, mooc.fi.

Dead ends: Fedora docs/src.fedoraproject.org and Arch wiki (Anubis bot block), wiki.ubuntu.com CompilerFlags (404), ubuntu.com security blog (404), ost2.fyi/Learning-Paths.html (empty), PDFs (no pdftotext installed; Delphi SIGCSE 2008 PDF unreadable), ideals.illinois.edu (403).

Local machine (Arch, gcc 16.2.1, gdb 18.1): no clang, docker, pwntools, pwndbg. gcc -fsanitize works, useful for labelled local observations. WebFetch summaries drop details (e.g. author names): re-ask or mark "confirm".

FND domain map written: research/domain-maps/foundations.md. Gaps: Ubuntu/Fedora defaults, psABI PDF, FND-04 CVE targets.
