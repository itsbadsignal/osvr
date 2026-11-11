---
name: fuzzing-vd-sources
description: Fetch behaviour and dead ends for VD (fuzzing, variant analysis, AI-VR) research, found 2026-11-10
metadata:
  type: reference
---

Works: llvm.org/docs/LibFuzzer.html, clang.llvm.org/docs/*Sanitizer*.html, raw.githubusercontent.com/AFLplusplus/AFLplusplus/stable/docs/fuzzing_in_depth.md, google.github.io/oss-fuzz/*, projectzero.google/YYYY/MM/*.html (project zero moved off blogspot), anthropic.com/research/zero-days (red.anthropic.com redirects), appsec.guide (Trail of Bits Testing Handbook), cwe.mitre.org/top25/archive/2025/*.
Redirects needing a second WebFetch: semgrep.dev/docs -> docs.semgrep.dev.
Dead/unreadable: PDF decks via WebFetch return binary (Black Hat decks); no pdftotext/pypdf in sandbox. The Read tool can render a small PDF (worked for a 1-page poster). p.ost2.fyi and ost2.fyi course lists do not extract. AFL++ utils/desock/README.md 404.
GitHub API unauthenticated rate limit hits after ~13 calls per run; batch the repo checks first.
Status facts (2026-11-10): google/AFL, google/fuzzing, google/oss-fuzz-gen archived; libFuzzer maintenance mode; Semgrep OSS C/C++ experimental (vendor blog 2024-02-27).
