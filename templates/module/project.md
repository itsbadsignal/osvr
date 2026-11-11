# Project: <MODULE_ID>

## Target
Real artefact: <CVE / codebase / firmware>   Version: <pinned>   Fix: <commit or advisory, from research/>
Lab: `lab/` (see lab/README.md)   Mitigations on: <list>

## Goal
<What success looks like, observable. e.g. "spawn a shell from the service with ASLR, PIE, NX and full RELRO enabled">

## Constraints
- ...

## Deliverables
1. `exploit.py`: reliable (≥ 9/10 runs), commented by stage.
2. `rootcause.md`: bug location to the line, CWE, primitive, broken invariant.
3. `feynman.md`: under 400 words, for a smart non-specialist.
4. `advisory.md`: affected versions, impact, reproduction, root cause, suggested fix, as if sending to the vendor.

## Variations (experimentation)
- [ ] <different primitive>
- [ ] <added mitigation>
- [ ] <stripped binary / no symbols>
- [ ] <no-leak or size constraint>

## Overlearning stretch
<one task a level above>

Submit with `/submit <MODULE_ID>`.
