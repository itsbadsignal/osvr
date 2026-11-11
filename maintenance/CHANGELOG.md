# Changelog

Dated entries for every curriculum change. Newest first.

## 2026-11-11
- FND-01-linux-lab-and-learning-protocol: status ready. Audit READY on re-audit after one fix round (checker now grades learner artefacts read-only; uncached rebuild evidence; Docker labelled unverified). Lab verified on rootless podman 6.1.4 only. Shared base image labs/shared/fnd-base (osvr-fnd-base:1) and labs/shared/tools/check_session.py added. Hours 6 -> 8 (pilot parameter); outcomes now [rootcause].


## 2026-11-11: FND-02 ready
- FND-02-c-pointers-and-memory promoted to `status: ready` after audit round 2. Round-2 blocking item (project.md Target/Deliverables contradicted required step 6; `realbug/` path) fixed by the main thread; lab fixtures re-run OK.
- Real-bug step: learner harness reproduces iperf3 CVE-2025-54349 (WRITE of size 1, iperf_auth.c:390) at 4eab661d, clean at 4e5313ba; graded read-only by `check.sh realbug`.
- Open markers (non-blocking, declared): Docker untested; why glibc accepts the damaged top-chunk size (BX material).
