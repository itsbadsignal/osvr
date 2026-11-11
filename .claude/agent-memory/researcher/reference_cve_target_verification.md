---
name: cve-target-verification-workflow
description: Working method and environment facts for verifying CVE targets (podman, MITRE API, git clone) and FND shortlist outcomes
metadata:
  type: reference
---

- Docker is not installed on the maintainer machine; rootless `podman` 6.1.x works and pulls `docker.io/library/debian:trixie`. Mount sources with `-v dir:/src:ro,Z`. Debian base lacks `pkill`.
- Fast CVE verification: `curl https://cveawg.mitre.org/api/cve/CVE-ID` returns the MITRE record (description, CWE, references, affected). Then `git clone` upstream and `git show <fix>` locally; `git tag --contains` finds the release.
- Search-engine snippets mislabel fix commits (stb CVE-2021-28021: Red Hat cites 5ba0baa, which is a different bug; real fix 86b7570). Always read the diff.
- WebFetch of GitHub issues/advisories works.
- FND shortlist result (2026-11-10): TinyDir 1.2.5 / CVE-2023-49287 verified top pick; libmodbus CVE-2022-0367 and cJSON CVE-2023-53154 also built and crashed. See research/targets/FND.md.
- Dead ends: rxi microtar CVE-2026-55738 has no fix; lz4 CVE-2021-3520 needs hand-crafted stream; stb PoC is a zip attachment.
