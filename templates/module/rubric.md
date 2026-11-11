# Rubric: <MODULE_ID>

Automated check: `lab/check.sh` (exit 0 = outcome pass)

| Deliverable | Not yet | Pass | Strong pass |
|---|---|---|---|
| exploit.py | fails checker, or works only with mitigations off when they were required on | passes checker ≥ 9/10 runs with required mitigations | passes 10/10, no hardcoded addresses, stages clearly separated |
| rootcause.md | wrong line, wrong class, or primitive misdescribed | correct line, CWE, primitive | also names the broken invariant and why the original code looked safe |
| feynman.md | jargon hides at least one step | a non-specialist could follow every step | also explains why the mitigation fails here |
| advisory.md | a triager could not reproduce from it | reproducible, versions and impact stated | includes fix suggestion and a realistic CVSS rationale |

Pass the module: all deliverables at Pass or above.
