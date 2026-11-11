# Maintenance inbox

Defects reported from coaching sessions and audits. Format:

- YYYY-MM-DD | <MODULE_ID> | typo|factual|lab-broken|pedagogy|structure | <what, where, evidence>


- 2026-11-11 (FND-02 audit): FND-01 README:70 says `--security-opt seccomp=unconfined` is used "only" in FND-03; FND-02 now uses it too. Fix wording.
- 2026-11-11 (FND-02 audit, cosmetic): FND-02 check.sh realbug INFO line prints "allocated in *.LC2" for global/string-literal reports (failing harnesses only). Reword.
- 2026-11-11 (FND-02 audit): resources.yaml EVP_PKEY_decrypt card: docs.openssl.org page unfetchable by tools; add pod source on openssl-3.5 branch as fallback URL.
