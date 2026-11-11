---
name: field-overview-sources
description: Which sources worked and which were dead ends in the 2026-11-10 field-overview sweep
metadata:
  type: reference
---

Fetch works (T1): cloud.google.com GTIG reviews (2025 at /2025-zero-day-review/, 2024 at /2024-zero-day-trends/, NOT /2024-zero-day-review), projectzero.google/0day.html, CISA KEV JSON via curl (computable CWE tallies), google.github.io kernelCTF rules, security.apple.com MIE, blog.google Rust-in-Android, source.android.com MTE page, v8.dev/blog/sandbox, anthropic.com/research/zero-days, daniel.haxx.se curl post, ZDI Pwn2Own posts (thezdi.com), lwn.net, learn.microsoft.com oem-hvci-enablement.

Dead ends: phoronix (403), wiki.ubuntu.com/Security/Features (404), sourceware glibc (Anubis block), MS Learn kernel-mode-hardware-enforced-stack-protection (404), arxiv /pdf URLs (binary, use /abs/). WebSearch summaries are secondary: always fetch before citing. No verified first-person beginner "time-to-first-bug" accounts found yet (gap).
