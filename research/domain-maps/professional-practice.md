# Domain map: professional practice (PRO-01..PRO-07)
Researched: 2026-11-10   Questions answered: 21/26 (5 partial or open, listed under "Open questions")

Scope: ethics, scope and legal landscape; CVE/CNA/CWE/CVSS; coordinated disclosure; advisory and writeup quality; bounty and vendor programmes; portfolio and hiring (reuses `research/benchmarks/job-market.md`, adds only what is new).

All legal material below is a summary of public primary texts. It is not legal advice. Learners must check their own jurisdiction and read each programme's own safe-harbour terms.

## Questions planned (written before searching)
1. US: what does the DOJ CFAA charging policy say about good-faith research, and what does it not do?
2. EU: what do NIS2 Art. 12 and the CRA say on CVD, researchers, reporting duties, dates? What does ENISA run?
3. UK: is there a research defence in the Computer Misuse Act today; what reform is in motion?
4. disclose.io and platform safe-harbour wording: what is promised, what is excluded (third parties)?
5. CVE Program: current CNA Operational Rules version, assignment/first-refusal rules, publication deadlines, CWE requirement, CNA-LR.
6. How does a researcher actually request a CVE (CNA lookup, CNA-LR form, GitHub, kernel CNA)?
7. CVSS v4.0: groups, nomenclature, what a researcher should score.
8. CWE usage guidance for mapping.
9. NVD status 2025-26.
10. ISO/IEC 29147 and 30111: edition, scope, status.
11. CERT/CC CVD guide: phases, unresponsive vendors.
12. Project Zero policy today; ZDI policy; kernel and curl examples; embargo norms.
13. Strong advisory examples (vendor, researcher, broker) and their structure.
14. Report-quality guidance from programmes (Apple, kernel, curl).
15. Platform safe harbour; duplicate handling; AI-report policies (curl, Apple, Google OSS VRP, others).
16. ZDI process.
17. Portfolio/hiring: anything new beyond job-market.md?

## Why it matters
PRO serves the `disclose` outcome and gates the `find` outcome in practice: a bug you cannot legally test, report, get a CVE for or explain does not become portfolio evidence. job-market.md already shows written reporting as the most frequently required skill and "one explainable personal find" as the recurring hiring ask. New this session: the disclosure ecosystem changed materially in 2025-26 (curl bounty gone, Google OSS VRP paused, NVD triage, CNA Rules 4.2.x, EU CRA reporting duties from 2026-09-11, Project Zero's reporting-transparency trial). A curriculum written from 2022-era knowledge would mislead learners on at least five points (see Emphasise).

## Concepts / Facts / Procedures

### Concepts (understand)
- Authorization is the legal hinge: statutes turn on "unauthorised" access, so scope documents and safe-harbour text are the evidence of authorization. Third parties (hosting providers, other tenants, upstream vendors) are not bound by a programme's safe harbour.
- Good faith is defined by purpose and conduct (solely testing/fixing a flaw, avoiding harm, not extortion), not by self-label.
- The CVD pipeline (CERT/CC phases): discovery, reporting, validation and prioritisation, remediation, public awareness, deployment. Roles: finder, vendor, coordinator.
- Embargo logic: deadlines exist to bound user exposure and to force action; shorter when exploitation is in the wild.
- CVE is an identifier system run by CNAs under rules, not a severity or quality stamp. "Independently fixable" decides how many IDs a bug gets. Mitigation bypasses are generally not CVE-worthy by rule (CNA Rules 4.1.6).
- Root cause vs symptom in CWE mapping; CVSS-B is intrinsic severity, not risk.
- Incentive structures shape programme rules: bounty money attracts low-quality AI submissions; programmes respond with proof requirements, caps or closure.

### Facts (memorise)
| Fact | Source |
|---|---|
| DOJ policy (Justice Manual 9-48.000, "updated May 2022"): prosecutors should decline CFAA charges where evidence shows good-faith security research; definition: accessing "solely" for good-faith testing, investigation or correction of a security flaw; extortion is not good faith; no "exceeds authorized access" charge based solely on ToS violation; policy gives no enforceable rights and binds only DOJ attorneys (not states, civil plaintiffs) | JM 9-48.000 |
| EU NIS2 Art. 12: each Member State designates a coordinator CSIRT as trusted intermediary; reporters may report anonymously; ENISA runs a European vulnerability database; Recital 60 encourages national non-prosecution guidance, it does not itself grant immunity | NIS2 text |
| EU CRA: reporting of actively exploited vulnerabilities by manufacturers from 2026-09-11 (24h early warning, 72h notification, final report 14 days after fix), full application 2027-12-11; manufacturers must run a CVD policy and name a single contact point; Art. 15 allows voluntary reports by anyone to a CSIRT or ENISA | CRA text |
| UK CMA 1990 s.1 has no research defence in its text; government says reform of s.1 is coming ("not whether but how"), reported scope narrow, nothing enacted as of the sources read | legislation.gov.uk; Hansard committee 2026-02-24 |
| CNA Rules 4.2.1 (effective 2026-10, see conflicts): CNA with the most appropriate scope gets first refusal; if it refuses or is silent for 72 h on a publicly disclosed bug, a Root directs a CNA-LR to assign within 72 h; CNAs must publish the record within 72 h of public disclosure (SHOULD within 24 h); a CVE record must contain a CWE type (SHOULD use CWE), affected product, description, one public reference that is not the CVE itself | CNA Rules |
| CNA-LR (MITRE) assigns when the supplier has no CNA or after a valid dispute; will not assign for non-public vulnerabilities; not a coordinator | MITRE CNA-LR page |
| CVSS v4.0: groups Base, Threat, Environmental, Supplemental; labels CVSS-B, -BT, -BE, -BTE; Threat has one metric (Exploit Maturity A/P/U); Supplemental metrics do not change the score; spec page shows v1.2 dated 2024-06-18 | FIRST spec |
| NVD: from 2026-04-15 NIST enriches only KEV, federal-use and EO 14028 critical software CVEs; others labelled "Lowest Priority"; pre-2026-03-01 backlog moved to "Not Scheduled"; NIST no longer routinely adds its own score where the CNA supplied one | NIST announcement |
| ISO/IEC 29147:2018 (edition 2, 2018-10) vendor disclosure; ISO/IEC 30111:2019 (edition 2, 2019-10) vendor handling; both "to be revised" | iso.org committee pages |
| Project Zero: 90 days to patch plus 30 days after patch before details; 104-day grace option; in-the-wild exploitation 7 days; 2025 reporting-transparency trial publishes vendor, product and deadline of reports soon after filing | P0 policy and trial page |
| ZDI: 120-day vendor window, faulty patch 30/60/90, may publish limited advisory after 15 business days without vendor contact | ZDI policy |
| Linux kernel: embargo max 7 days, extendable to 14; CVEs are assigned by the kernel CNA after the fix lands in a stable tree, not at report time; kernel docs say AI-assisted findings should be treated as public | kernel docs |
| curl: no bounty since 2026-01-31; confirmed-vulnerability rate fell from over 15% to under 5% in 2025; distro notice at most 7 days before release | Stenberg post |
| Apple: ineligible if LLM-generated and unvalidated; requires working exploit or reliable PoC with numbered steps; only the first complete actionable report earns the reward; repeated ineligible submissions can pause processing 180 days | Apple guidelines |
| HackerOne duplicates: Resolved original +2 reputation, Informative 0, Not Applicable -5 | H1 docs |

### Procedures (automate)
1. Scope check: read programme scope, safe-harbour clause and rules; list planned actions; mark each in/out; stop and ask the programme when unsure; stay inside the lab otherwise.
2. Advisory dissection: extract affected versions, fixed versions, CWE, CVSS vector, fix commit and credit from an advisory and its references; cross-check against the CVE record.
3. CWE mapping: root cause first, Base/Variant level, check mapping-usage label (Allowed/Discouraged/Prohibited), peer check.
4. CVSS v4.0 scoring: score Base from the Vector spec, record vector string, state it is CVSS-B.
5. Report to a vendor: summary, affected version (commit or exact), reproducer with numbered steps, impact, suggested fix, your deadline policy, contact details.
6. CVE request: find the CNA (supplier or project, GitHub, kernel) first; fall back to the CNA-LR form only when no CNA covers the product or on a valid dispute; keep the CAN tracking number private until accepted.
7. Follow-up cadence and escalation: ack request, reminders, coordinator (CERT/CC, national CSIRT, ZDI) when silent, publish on the stated date.
8. Write a vendor-grade advisory and a reproducible public writeup; publish with a timeline.
9. Map artefacts to a posting's stated evidence.

## Mitigation landscape (legal and process defaults)
The "mitigations" analogue here is the legal and ecosystem state. Era: 2026-11.
- US: DOJ charging policy since 2022 reduces federal prosecution risk for good-faith research but is internal guidance; it does not bind states or civil plaintiffs, and the "solely" wording leaves prosecutorial discretion on mixed motives (law-firm commentary, secondary). Safe-harbour terms by the programme operator remain the main practical protection.
- EU: NIS2 pushes national CVD policies and coordinator CSIRTs; the CRA makes manufacturer CVD policies and reporting mandatory (dates above). Researcher immunity remains a national-law matter.
- UK: no statutory research defence; reform announced; reported scope narrow (press-reported, unverified against bill text: scanning of internet-facing assets, accreditation condition). `needs-verification` before teaching specifics.
- Programme level: HackerOne Gold Standard Safe Harbor is on by default for new programmes (per H1 docs; separate AI research safe harbour added 2026); disclose.io offers CC0 safe-harbour boilerplate. Both exclude third-party infrastructure.
- CVE: CNA Rules 4.2.x require CVE ID request channels free of restrictive disclosure terms (rule 3.2.4.2, per revision history). Mitigation-bypass reports are not normally vulnerabilities (4.1.6).
- Known gaps/bypass families (of the system): mixed-motive prosecutions; third-party systems behind in-scope assets; vendor non-response (answers: CNA-LR, coordinator CSIRT, ZDI, publication after deadline); NVD enrichment gaps (consumers must read the CNA's own CVSS/CWE).

## Rate-determining steps
| Step | Evidence it is hard | Used by |
|---|---|---|
| Writing a reproduction section a stranger can follow cold | Apple, kernel and curl policies all reject or deprioritise reports without a tested reproducer; curl's confirmed rate under 5% | PRO-04 (matches MAP) |
| Deciding scope from text, including third-party and "mixed" cases | Safe harbour covers only what the operator controls; H1 says contact them if unsure | PRO-01, PRO-05 |
| Keeping disclosure moving over months (silence, collisions, CNA fallback) | CERT/CC lists "somebody stops replying" and "unresponsive vendor" as their own how-tos; Qualys's AppArmor timeline shows a release date postponed until upstream patches | PRO-06 |
| Choosing the right CWE and "independently fixable" boundary | CWE guidance warns against symptom-mapping; CNA rule 4.2.11 and 4.2.12 | PRO-02 |
Expert statements here are policy and practitioner documents rather than interviews; no source says "this is the hardest step", so the ranking is inferred and flagged as such.

## Emphasise (what tutorials skip)
1. Safe harbour is not law: read what it promises (no legal action by the operator, support if sued) and what it excludes (third parties).
2. Mitigation-bypass and "hardening gap" reports often get no CVE under rule 4.1.6 and may be refused by the programme; set expectations before writing it up.
3. A CVE is requested through the CNA that covers the product, not by default through MITRE; the kernel and curl assign their own. Fix-first for kernel: no CVE until the fix is in a stable tree unless you request a reserved ID.
4. Report needs: tested reproducer, exact version or commit, impact, in your own words. AI help is tolerated by some programmes only with human validation; unvalidated AI reports get ineligible, paused or banned (Apple, curl).
5. NVD no longer enriches most CVEs: learners must read the CNA record and vendor advisory for CVSS/CWE/affected ranges.
6. Embargo norms differ by venue: P0 90+30, ZDI 120, kernel 7-14 days, distros at most 7 days (curl). State your own policy in the first report.
7. Duplicates and collisions are normal: novelty check, keep timestamped notes, accept informative/duplicate outcomes (cost in reputation on H1).
8. Credit and timeline sections in a writeup are part of the quality bar (Qualys timeline, OpenSSL credits field).

## Exclude
- Memorising CVSS v3.1 tables as the primary scoring tool: v4.0 is current (spec page v1.2); teach 3.1 only to read old records. Cite FIRST.
- Reading the full ISO/IEC standards (paid, CHF 179 for 29147, vendor-oriented): use abstracts plus the free CERT/CC guide.
- Bounty-chasing as a strategy: programme closures (curl, Google OSS VRP product submissions paused 2026-10-01 per secondary coverage) and AI-driven report floods lower the yield; treat bounty as a venue, not the spine.
- Legal opinion content, jurisdiction-by-jurisdiction analysis: out of scope per CLAUDE.md; point to local law.
- MITRE-form-first CVE advice from older blog posts: contradicts current first-refusal rules.
- Press-release-level DOJ or UK commentary as primary sources.

## Candidate direct targets
PRO modules are practice-on-artefacts rather than CVE labs. Candidates, all legal to read and use:
| Module | Candidate | Why suitable | Feasibility |
|---|---|---|---|
| PRO-02 | OpenSSL advisory 2026-09-29 (14 issues, structured fields) plus its CVE records | Fields to extract: severity, CWE, affected/fixed versions, credits; practice cross-checking with CVE.org and NVD status | no lab; read-only |
| PRO-02 | Qualys CrackArmor advisory (2026-03) | Multi-bug advisory with timeline and no CVEs at time of writing, shows CNA/kernel path | read-only |
| PRO-03 | the BX-05 N-day chosen by the learner | writeup against a patched public CVE | per BX module |
| PRO-04 | Role-play: write a report to the kernel security process format (docs.kernel.org) against a lab bug the learner found in a deliberately vulnerable local target | follows a real policy, no third party contacted | lab only |
| PRO-05 | Compare Apple, curl, kernel and H1-hosted programme texts | real current policies | read-only |
| PRO-06 | The learner's VD-10 result | real disclosure | depends on hunt |
Build/verify notes: nothing needed to build; `build: not applicable`. Fix commits are per advisory and were not collected.

## Resources (resource cards; sorted by tier then score)
Scores 1-5 (D directness, C currency, De depth, A activity, Co cost, Ac accessibility). `role` left to module-builder.

```yaml
- title: "Justice Manual 9-48.000 Computer Fraud and Abuse Act"
  url: "https://www.justice.gov/jm/jm-9-48000-computer-fraud"
  author: "U.S. Department of Justice"
  kind: docs
  tier: T1
  cost: free
  published: 2022
  targets: "US federal CFAA charging policy; page shows [updated May 2022]"
  covers: "good-faith research definition, extortion carve-out, ToS-only violations, no enforceable rights"
  assumes: "none; read with a lawyer's caution"
  scores: {directness: 4, currency: 4, depth: 3, activity: 1, cost: 5, accessibility: 4}
  verified: 2026-11-10
  status: ok
  note: "Direct URL .../jm-9-48000-computer-fraud-and-abuse-act returned 404; the URL above works."

- title: "CNA Operational Rules 4.2.1"
  url: "https://www.cve.org/Resources/Roles/Cnas/CNA_Rules_v4.2.1.pdf"
  author: "CVE Program"
  kind: docs
  tier: T1
  cost: free
  published: 2026-10
  targets: "CVE Program rules, version 4.2.1"
  covers: "vulnerability determination, assignment, first refusal, publication deadlines, record content, disputes"
  assumes: "CNA vocabulary (glossary links in the PDF)"
  scores: {directness: 5, currency: 5, depth: 5, activity: 1, cost: 5, accessibility: 3}
  verified: 2026-11-10
  status: ok
  note: "Text recovered by decompressing PDF streams locally; WebFetch could not read it."

- title: "MITRE CNA of Last Resort (CNA-LR)"
  url: "https://mitre.github.io/mitre-cve-roles/CNA-LR/"
  author: "MITRE"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "CVE ID requests when no CNA covers the product"
  covers: "when to use the CNA-LR, what it refuses, no timelines promised"
  assumes: "CNA concept"
  scores: {directness: 5, currency: 5, depth: 3, activity: 2, cost: 5, accessibility: 5}
  verified: 2026-11-10
  status: ok

- title: "CVE ID request form (MITRE)"
  url: "https://mitre.github.io/mitre-cve-roles/cve-id-request"
  author: "MITRE"
  kind: tool
  tier: T1
  cost: free
  published: unknown
  targets: "CNA-LR request process"
  covers: "required fields, CAN tracking number, login, do not use CAN publicly"
  assumes: "have a public-disclosure plan; do not submit real third-party findings in a drill"
  scores: {directness: 5, currency: 5, depth: 2, activity: 3, cost: 5, accessibility: 5}
  verified: 2026-11-10
  status: ok

- title: "CVSS v4.0 Specification Document"
  url: "https://www.first.org/cvss/v4.0/specification-document"
  author: "FIRST"
  kind: docs
  tier: T1
  cost: free
  published: 2023-11-01
  targets: "CVSS 4.0, page v1.2 dated 2024-06-18"
  covers: "metric groups, nomenclature, Base/Threat/Environmental/Supplemental"
  assumes: "security terms"
  scores: {directness: 5, currency: 5, depth: 5, activity: 2, cost: 5, accessibility: 3}
  verified: 2026-11-10
  status: ok

- title: "CWE root cause mapping guidance"
  url: "https://cwe.mitre.org/documents/cwe_usage/guidance.html"
  author: "MITRE CWE"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "CWE mapping practice"
  covers: "map root cause, prefer Base/Variant, never Category, usage labels, process"
  assumes: "none"
  scores: {directness: 5, currency: 4, depth: 4, activity: 3, cost: 5, accessibility: 4}
  verified: 2026-11-10
  status: ok

- title: "NIST NVD enrichment change announcement (2026-04-15)"
  url: "https://www.nist.gov/node/1910421"
  author: "NIST"
  kind: docs
  tier: T1
  cost: free
  published: 2026-04-15
  targets: "NVD operations"
  covers: "risk-based enrichment, Not Scheduled backlog, nvd@nist.gov requests"
  assumes: "none"
  scores: {directness: 3, currency: 5, depth: 2, activity: 1, cost: 5, accessibility: 5}
  verified: 2026-11-10
  status: ok

- title: "Directive (EU) 2022/2555 (NIS2), Article 12"
  url: "https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32022L2555"
  author: "EU"
  kind: docs
  tier: T1
  cost: free
  published: 2022-12-14
  targets: "EU CVD coordination and EU vulnerability database"
  covers: "coordinator CSIRT, anonymous reporting, ENISA database; Recital 60 on researcher non-prosecution guidelines"
  assumes: "legal reading"
  scores: {directness: 3, currency: 4, depth: 3, activity: 1, cost: 5, accessibility: 2}
  verified: 2026-11-10
  status: ok
  note: "Date of the Directive not shown in the fetched excerpt; 2022 is from the instrument number only."

- title: "Regulation (EU) 2024/2847 (Cyber Resilience Act), Articles 13-15"
  url: "https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32024R2847"
  author: "EU"
  kind: docs
  tier: T1
  cost: free
  published: 2024
  targets: "EU product cybersecurity"
  covers: "manufacturer vulnerability handling and CVD policy, 24h/72h/14-day reporting, voluntary reporting"
  assumes: "legal reading"
  scores: {directness: 3, currency: 5, depth: 3, activity: 1, cost: 5, accessibility: 2}
  verified: 2026-11-10
  status: ok
  note: "Article 71 and Annex I not reached; dates come from Recital 126 as summarised by the fetch tool. needs-verification of Art. 71 text."

- title: "ENISA vulnerability disclosure topic page"
  url: "https://www.enisa.europa.eu/topics/vulnerability-disclosure"
  author: "ENISA"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "EUVD, Single Reporting Platform, CSIRT network"
  covers: "EU database listed 2025-05-13; SRP; contact vuln@enisa.europa.eu"
  assumes: "none"
  scores: {directness: 3, currency: 4, depth: 2, activity: 1, cost: 5, accessibility: 4}
  verified: 2026-11-10
  status: ok

- title: "Computer Misuse Act 1990, section 1"
  url: "https://www.legislation.gov.uk/ukpga/1990/18/section/1"
  author: "UK Parliament / legislation.gov.uk"
  kind: docs
  tier: T1
  cost: free
  published: 1990
  targets: "UK unauthorised access offence"
  covers: "offence text, no research defence"
  assumes: "none"
  scores: {directness: 3, currency: 3, depth: 2, activity: 1, cost: 5, accessibility: 4}
  verified: 2026-11-10
  status: ok
  note: "Site warns revised text may lag; last effect shown 2023-02-07."

- title: "Public Bill Committee, Cyber Security and Resilience Bill, 2026-02-24 (TheyWorkForYou)"
  url: "https://www.theyworkforyou.com/pbc/2024-26/Cyber_Security_and_Resilience_%28Network_and_Information_Systems%29_Bill/07-0_2026-02-24a.259.0"
  author: "UK Parliament record"
  kind: docs
  tier: T2
  cost: free
  published: 2026-02-24
  targets: "UK CMA reform statements"
  covers: "minister says reform is coming, limited s.1 defence under development, no timeline"
  assumes: "none"
  scores: {directness: 2, currency: 4, depth: 2, activity: 1, cost: 5, accessibility: 4}
  verified: 2026-11-10
  status: ok
  note: "Hansard mirror, not parliament.uk itself."

- title: "Gold Standard Safe Harbor statement (HackerOne docs)"
  url: "https://docs.hackerone.com/organizations/safe-harbor-statement.html"
  author: "HackerOne"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "HackerOne programmes"
  covers: "authorization, no legal action, support if sued, conditions, third-party exclusion"
  assumes: "none"
  scores: {directness: 5, currency: 5, depth: 3, activity: 2, cost: 5, accessibility: 5}
  verified: 2026-11-10
  status: ok

- title: "disclose.io (framework and terms)"
  url: "https://disclose.io/framework/terms/"
  author: "disclose.io"
  kind: docs
  tier: T2
  cost: free
  published: unknown
  targets: "VDP/BBP boilerplate, CC0"
  covers: "Safe Harbor and Simple Safe Harbor clauses, six maturity levels"
  assumes: "none"
  scores: {directness: 4, currency: 4, depth: 2, activity: 3, cost: 5, accessibility: 5}
  verified: 2026-11-10
  status: changed
  note: "Fetched page lists clause names only; clause text not read; not legal advice per site."

- title: "CERT Guide to Coordinated Vulnerability Disclosure"
  url: "https://certcc.github.io/CERT-Guide-to-CVD/"
  author: "CERT/CC (SEI)"
  kind: docs
  tier: T1
  cost: free
  published: 2017 (SR-022), web edition undated
  targets: "CVD practice"
  covers: "principles, roles, six phases, how-to pages including Unresponsive Vendor and Somebody Stops Replying, embargo topics"
  assumes: "none"
  scores: {directness: 4, currency: 3, depth: 5, activity: 3, cost: 5, accessibility: 5}
  verified: 2026-11-10
  status: ok
  note: "Old URL vuls.cert.org/confluence/display/CVD redirects here. Individual how-to pages not read, only the index."

- title: "Project Zero Vulnerability Disclosure Policy"
  url: "https://projectzero.google/vulnerability-disclosure-policy.html"
  author: "Google Project Zero"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "P0 policy"
  covers: "90+30, grace period, 7-day in-the-wild rule"
  assumes: "none"
  scores: {directness: 4, currency: 5, depth: 3, activity: 1, cost: 5, accessibility: 5}
  verified: 2026-11-10
  status: ok
  note: "Old blogspot URL 301-redirects here."

- title: "Project Zero Reporting Transparency"
  url: "https://projectzero.google/reporting-transparency.html"
  author: "Google Project Zero"
  kind: docs
  tier: T1
  cost: free
  published: 2025-07-29 (trial start)
  targets: "2025 policy trial; last update 2026-11-03"
  covers: "what is published and when"
  assumes: "none"
  scores: {directness: 4, currency: 5, depth: 2, activity: 1, cost: 5, accessibility: 5}
  verified: 2026-11-10
  status: ok

- title: "ZDI Disclosure Policy"
  url: "https://www.zerodayinitiative.com/advisories/disclosure_policy/"
  author: "Trend Micro Zero Day Initiative"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "ZDI-acquired bugs"
  covers: "120-day window, 15 business day no-contact rule, faulty patch timeline, no silent bugs"
  assumes: "none"
  scores: {directness: 4, currency: 5, depth: 3, activity: 1, cost: 5, accessibility: 5}
  verified: 2026-11-10
  status: ok

- title: "ZDI About"
  url: "https://www.zerodayinitiative.com/about/"
  author: "Trend Micro ZDI"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "ZDI researcher flow"
  covers: "submission portal, validation, offer, payment on acceptance, credit options"
  assumes: "none"
  scores: {directness: 4, currency: 4, depth: 2, activity: 1, cost: 5, accessibility: 5}
  verified: 2026-11-10
  status: ok
  note: "Exclusivity terms not stated on the page."

- title: "Linux kernel: Security bugs"
  url: "https://docs.kernel.org/process/security-bugs.html"
  author: "Linux kernel documentation"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "kernel security reporting"
  covers: "recipients, required report content, 7/14-day embargo, linux-distros rules, AI-assisted finding rule"
  assumes: "kernel patch workflow"
  scores: {directness: 5, currency: 5, depth: 4, activity: 3, cost: 5, accessibility: 3}
  verified: 2026-11-10
  status: ok

- title: "Linux kernel: CVE assignment"
  url: "https://docs.kernel.org/process/cve.html"
  author: "Linux kernel documentation"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "kernel CNA"
  covers: "CVEs after stable fix, cve@kernel.org for reserve and missed CVEs, no CVEs for unsupported versions"
  assumes: "none"
  scores: {directness: 5, currency: 5, depth: 3, activity: 1, cost: 5, accessibility: 4}
  verified: 2026-11-10
  status: ok

- title: "curl Vulnerability Disclosure Policy (source)"
  url: "https://raw.githubusercontent.com/curl/curl/master/docs/VULN-DISCLOSURE-POLICY.md"
  author: "curl project"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "curl"
  covers: "reporting, severity routing, distro 7-day rule, AI wording, transparency"
  assumes: "none"
  scores: {directness: 5, currency: 2, depth: 3, activity: 1, cost: 5, accessibility: 5}
  verified: 2026-11-10
  status: changed
  note: "Fetched copy still names HackerOne as the channel, contradicting Stenberg's 2026-01-26 post (GitHub PVR or email). Treat the post as the newer statement; re-check."

- title: "The end of the curl bug-bounty (Daniel Stenberg)"
  url: "https://daniel.haxx.se/blog/2026/01/26/the-end-of-the-curl-bug-bounty/"
  author: "Daniel Stenberg"
  kind: writeup
  tier: T1
  cost: free
  published: 2026-01-26
  targets: "curl programme"
  covers: "why the bounty ended 2026-01-31, confirmed rate drop, 87 confirmed vulns and over USD 100k paid, replacement channels"
  assumes: "none"
  scores: {directness: 5, currency: 5, depth: 4, activity: 1, cost: 5, accessibility: 5}
  verified: 2026-11-10
  status: ok

- title: "Apple Security Bounty guidelines"
  url: "https://security.apple.com/bounty/guidelines/"
  author: "Apple"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "Apple programme, copyright 2026"
  covers: "report requirements, AI rules, 180-day pause, duplicates (first complete report)"
  assumes: "none"
  scores: {directness: 5, currency: 5, depth: 3, activity: 2, cost: 5, accessibility: 5}
  verified: 2026-11-10
  status: ok
  note: "The reported per-researcher open-report cap was NOT on this page; press-only, unconfirmed."

- title: "HackerOne: Duplicate reports"
  url: "https://docs.hackerone.com/en/articles/8475030-duplicate-reports"
  author: "HackerOne"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "HackerOne platform"
  covers: "duplicate, informative, N/A definitions and reputation effects"
  assumes: "none"
  scores: {directness: 4, currency: 4, depth: 2, activity: 1, cost: 5, accessibility: 5}
  verified: 2026-11-10
  status: ok

- title: "OpenSSL security advisory 2026-09-29"
  url: "https://openssl-library.org/news/secadv/20260929.txt"
  author: "OpenSSL"
  kind: advisory
  tier: T1
  cost: free
  published: 2026-09-29
  targets: "OpenSSL supported branches"
  covers: "model vendor advisory: severity, summaries, CWE, affected/fixed, credits per issue"
  assumes: "TLS/DTLS basics"
  scores: {directness: 5, currency: 5, depth: 3, activity: 3, cost: 5, accessibility: 3}
  verified: 2026-11-10
  status: ok
  note: "No fix commit hashes in the advisory itself."

- title: "CrackArmor: Multiple vulnerabilities in AppArmor (Qualys)"
  url: "https://cdn2.qualys.com/advisory/2026/03/10/crack-armor.txt"
  author: "Qualys Threat Research Unit"
  kind: advisory
  tier: T1
  cost: free
  published: 2026-03-12
  targets: "AppArmor, Ubuntu 24.04.3 LTS, Debian 13.1"
  covers: "researcher advisory: summary, mechanism, chain, kernel bugs, acknowledgments, dated timeline"
  assumes: "Linux LSM and kernel basics"
  scores: {directness: 5, currency: 5, depth: 5, activity: 3, cost: 5, accessibility: 2}
  verified: 2026-11-10
  status: ok

- title: "ZDI published advisories"
  url: "https://www.zerodayinitiative.com/advisories/published/"
  author: "Trend Micro ZDI"
  kind: advisory
  tier: T1
  cost: free
  published: 2026-11-10 (latest entry seen)
  targets: "broker advisory format"
  covers: "ZDI-26-NNN titles encode product, component, class, impact"
  assumes: "none"
  scores: {directness: 4, currency: 5, depth: 2, activity: 3, cost: 5, accessibility: 4}
  verified: 2026-11-10
  status: ok
  note: "Only titles and one URL seen; an individual advisory was not read."

- title: "ISO/IEC 29147:2018 (committee page, abstract)"
  url: "https://committee.iso.org/standard/72311.html"
  author: "ISO/IEC"
  kind: docs
  tier: T1
  cost: paid
  published: 2018-10-23
  targets: "vendor disclosure"
  covers: "abstract only: receiving reports, disclosing remediation"
  assumes: "n/a"
  scores: {directness: 2, currency: 3, depth: 1, activity: 1, cost: 1, accessibility: 3}
  verified: 2026-11-10
  status: ok
  note: "www.iso.org returned 403; the committee.iso.org mirror worked. Standard costs CHF 179; do not require it."

- title: "ISO/IEC 30111:2019 (committee page, abstract)"
  url: "https://committee.iso.org/standard/69725.html"
  author: "ISO/IEC"
  kind: docs
  tier: T1
  cost: paid
  published: 2019-10-01
  targets: "vendor handling processes"
  covers: "abstract only"
  assumes: "n/a"
  scores: {directness: 2, currency: 3, depth: 1, activity: 1, cost: 1, accessibility: 3}
  verified: 2026-11-10
  status: ok
```

Unverified (verified: null, status: unverified):
- Google Bug Hunters, "Streamlining Google's OSS VRP: Key Rule Updates" `https://bughunters.google.com/blog/ossvrp-rule-updates-2026` (JS-rendered, body not retrievable; title confirmed by search only). Claims about the OT0/OT1 OSS-Fuzz requirement and the 2026-10-01 pause of product submissions come from news aggregators.
- DOJ press release on the 2022 policy (justice.gov OPA, blank fetch). JM page used instead.
- Project Zero policy FAQ, HackerOne AI Research Safe Harbor page (docs.hackerone.com article 8494502 was fetched and dates AI RSH and GSSH to 2026-01-16; full AI RSH text not read).
- CVE Program "How to request a CVE" FAQ and glossary pages (cve.org renders blank to fetch; title only).
- Wireshark, Node.js, GNOME and other programme AI/bounty policies: seen only in secondary search summaries.

## Portfolio and hiring (only what is new)
See `research/benchmarks/job-market.md` for tallies. New observations from this session that bear on PRO-07:
- Advisory and CVE records are themselves portfolio artefacts that stay verifiable: a CVE record needs a public reference and CWE (CNA Rules 5.1), so the learner's artefact chain is advisory, CVE record, fix commit, writeup.
- Bounty as evidence is weakening: curl closed its paid programme, Google paused OSS VRP product submissions, Apple tightened proof rules. job-market.md lists bounty results in 3 of 31 postings; the sample was already low, so PRO-07 should rank accepted CVEs and public writeups above bounty reputation. (Inference; mark for review.)
- Venues that still produce credit without payment: kernel via cve@kernel.org/security@kernel.org, GitHub private reporting (curl's replacement channel), ZDI (paid, credit options include anonymity or pseudonym).
- Not researched: clearance and residency gates beyond job-market.md.

## Open questions / conflicting sources
1. CNA Rules effective date: PDF cover text reads 2026-October-21; revision-history row for 4.2.1 reads 2026-10-14; a search snippet said October 20. Cite "4.2.1, October 2026" and re-check cve.org.
2. curl channel: Stenberg's 2026-01-26 post says GitHub PVR or email and no HackerOne; the policy file on master (fetched) still says HackerOne and no email. Possibly stale. Check before teaching.
3. Apple report cap: press says an undisclosed cap since June 2026; Apple's guidelines page (fetched) states no cap but a 180-day pause for ineligible reports. Teach the guidelines page only.
4. UK reform scope: press says scanning-only and accreditation condition; no bill text read. Teach "reform announced, scope unconfirmed".
5. NVD backlog figures conflict (about 4,000 visible vs more than 27,000 in an inspector-general report) because they count different statuses; both secondary. NIST's own announcement gives only the policy, not counts.
6. CRA Art. 71 and Annex I Part II not read; reporting date 2026-09-11 and application date 2027-12-11 come from Recital 126 via summarisation. needs-verification.
7. NIS2 Directive date and the ENISA EUVD operational status beyond the 2025-05-13 listing not verified.
8. Not reached: DMCA s.1201 exemption text, other jurisdictions (Germany s.202c, France, Australia), Bugcrowd and Intigriti policies, HackerOne AI-report policy, CERT/CC VINCE, GitHub CVE request docs (404). Learners must check their own law.
9. No source ranks "hardest step" directly; RDS table is inferred from policy texts.
10. Which public advisories and writeups best teach "reproduce cold" was not benchmarked beyond three examples; a quality rubric still needs a source (suggest module-builder uses OpenSSL and Qualys structures).

## Sources (all fetched 2026-11-10 unless noted)
Fetched and read:
- https://www.justice.gov/jm/jm-9-48000-computer-fraud
- https://www.cve.org/Resources/Roles/Cnas/CNA_Rules_v4.2.1.pdf (text recovered locally)
- https://mitre.github.io/mitre-cve-roles/CNA-LR/
- https://mitre.github.io/mitre-cve-roles/cve-id-request
- https://www.first.org/cvss/v4.0/specification-document
- https://cwe.mitre.org/documents/cwe_usage/guidance.html
- https://www.nist.gov/node/1910421
- https://committee.iso.org/standard/72311.html
- https://committee.iso.org/standard/69725.html
- https://certcc.github.io/CERT-Guide-to-CVD/ , /topics/phases/ , /howto/
- https://projectzero.google/vulnerability-disclosure-policy.html
- https://projectzero.google/reporting-transparency.html
- https://www.zerodayinitiative.com/advisories/disclosure_policy/ , /about/ , /advisories/published/
- https://docs.kernel.org/process/security-bugs.html , /cve.html
- https://daniel.haxx.se/blog/2026/01/26/the-end-of-the-curl-bug-bounty/
- https://curl.se/dev/vuln-disclosure.html and the raw GitHub copy
- https://security.apple.com/bounty/guidelines/
- https://esecurityplanet.com article on Apple (secondary, used only to flag the unconfirmed cap)
- https://docs.hackerone.com/organizations/safe-harbor-statement.html , /en/articles/8494502-safe-harbor , /en/articles/8475030-duplicate-reports
- https://disclose.io/ , /framework/ , /framework/terms/
- https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32022L2555 and ...:32024R2847 (partial, by offset)
- https://www.enisa.europa.eu/topics/vulnerability-disclosure
- https://www.legislation.gov.uk/ukpga/1990/18/section/1
- https://www.theyworkforyou.com/pbc/2024-26/... (2026-02-24)
- https://openssl-library.org/news/secadv/ and /20260929.txt
- https://www.qualys.com/research/security-advisories/ and https://cdn2.qualys.com/advisory/2026/03/10/crack-armor.txt
Search-only leads (not sources): news coverage of the King's Speech 2026 and CMA reform (therecord.media, securityboulevard), NVD coverage (infosecurity-magazine, socket.dev), Google OSS VRP pause (aggregators), gov.uk King's Speech 2026 background notes page (metadata only, text not read).
Not reachable: www.iso.org (403), justice.gov OPA press release (blank), cve.org FAQ/glossary/rules landing page (JS), bughunters.google.com blog (JS), GitHub CVE-request docs (404), justice.gov media dl link (404).
