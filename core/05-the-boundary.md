# 05 · The Boundary

> Learn what a trust boundary is in access control, cryptography, the web, the cloud and the law before crossing one.

**Requires:** [M4 gate](04-the-system.md) · **Hours:** 250-380 · **Next:** [M6 · The Bug](06-the-bug.md)

Nothing in M6-M10 starts until this gate is passed. Read [Legal scope, lab and disclosure](../guides/legal-and-lab.md) alongside this module.

## Outcomes

- State what a crypto primitive guarantees and what it doesn't, and break three deployments that got it wrong.
- Map an application's trust boundaries before touching it.
- Name the statute that applies to you and produce a written authorization.
- Build an isolated lab from a script, destroy it, rebuild it.

## Resources

| Role | Resource | Cost | Notes |
|------|----------|------|-------|
| Core | [MIT 6.858 · Computer Systems Security](https://css.csail.mit.edu/6.858/) | Free | Privilege separation, isolation, web, side channels. Graduate-level, with labs. |
| Core | [Saltzer & Schroeder, *The Protection of Information in Computer Systems*](https://web.mit.edu/Saltzer/www/publications/protection/) (1975) | Free | Least privilege, complete mediation, fail-safe defaults. Read the original. |
| Core | [Serious Cryptography](https://nostarch.com/serious-cryptography-2nd-edition) (Aumasson, 2nd ed.) | ~€50 | Attack-aware, current through post-quantum. |
| Core | [CryptoHack](https://cryptohack.org/) | Free | The math made concrete. |
| Core | [Cryptopals](https://cryptopals.com/) · sets 1-3 | Free | Implement the attack or fail. No hints; CryptoHack is the fallback. |
| Core | [PortSwigger Web Security Academy](https://portswigger.net/web-security) | Free | The best free resource in this curriculum. It trains recognition, not discovery; the gate corrects that. |
| Core | [flaws.cloud](https://flaws.cloud/) · [CloudGoat](https://github.com/RhinoSecurityLabs/cloudgoat) | Free | Cloud IAM and misconfiguration. Deploy CloudGoat yourself. |
| Core | [SEED Labs](https://seedsecuritylabs.org/) | Free | Network, PKI, access control. Some labs disable mitigations for visibility; don't mistake that for reality. |
| Core | Your jurisdiction's statutes, read directly. EU: national [Budapest Convention](https://www.coe.int/en/web/conventions/full-list?module=treaty-detail&treatynum=185) law · UK: [Computer Misuse Act](https://www.legislation.gov.uk/ukpga/1990/18/contents) · US: [18 U.S.C. §1030](https://www.law.cornell.edu/uscode/text/18/1030) | Free | Don't rely on a summary here. |
| Core | Five bug bounty policies on [HackerOne](https://hackerone.com/directory/programs) / [Bugcrowd](https://bugcrowd.com/programs), read side by side | Free | Safe-harbour language differs more than you expect. |
| Core | [CERT Guide to Coordinated Vulnerability Disclosure](https://certcc.github.io/CERT-Guide-to-CVD/) | Free | |
| Core | Lab as code: hypervisor + [Vagrant](https://developer.hashicorp.com/vagrant/docs) or [Ansible](https://docs.ansible.com/), host-only network, snapshots | Free | See [lab rules](../guides/legal-and-lab.md#lab-rules). |
| Alt | *Real-World Cryptography* (Wong) | ~€50 | Less math, more engineering. |
| Ref | [MDN · Web security](https://developer.mozilla.org/en-US/docs/Web/Security) | Free | Same-origin, CORS, CSP, cookies. |

## Milestones

- **~80 h:** Capture and annotate a TLS 1.3 handshake byte by byte.
- **~160 h:** Toy RSA with your own modular exponentiation; break it three ways.
- **~240 h:** Three-host isolated lab from a script, destroyed and rebuilt identically.

## Ship

1. A threat model of a system you depend on.
2. A writeup of a crypto misuse you exploited, with the math.
3. A dated written authorization for your own lab, plus a one-page summary of the offence-relevant law in your jurisdiction.

## Gate · 6 hours, both parts

1. **Technical:** for an unfamiliar application, write its trust-boundary and authorization map *before* testing, then find an authorization or logic flaw nobody pointed you at.
2. **Legal:** for five described activities against five described targets, state whether you're authorized and cite the basis: a document, a programme scope, a statute, or ownership.

**Fail if:** any legal answer is "probably fine".

**Unlocks:** systems you don't own, with written authorization only.

## Fork

From here you can run a **web/cloud** line in parallel with M6-M7. It's the shortest path to bounty income. See the [web/cloud track](../tracks/README.md#web-cloud-and-logic).
