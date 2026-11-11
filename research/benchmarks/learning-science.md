# Benchmark: Learning-science evidence for the OSVR ultralearning mechanics
Researched: 2026-11-10   Questions answered: 11/12 (Q9 partial, Q12 not found; see list)

Mode: BUILD / metalearning, field-wide evidence review. Output is evidence for the architect; it does not change curriculum files.

## Method and fetch caveats (read first)

- Nothing here is from memory. Every study below was confirmed by retrieving a bibliographic record plus abstract from Europe PMC, OpenAlex, Semantic Scholar or the publisher/institutional page on 2026-11-10 (`verified: 2026-11-10`). Where the full text could not be read (publisher paywalls, 403s, PDFs the fetch tool could not decode, PubMed and PMC cookie/captcha walls), effect sizes come from the **abstract only**. Anything beyond the abstract is marked `abstract-only`.
- Three sources are `verified: null, status: unverified` because I could not retrieve their abstracts directly and only saw them summarised in web-search snippets: Bisra et al. 2018, Barbieri et al. 2023, Latimier et al. 2021 (published version). Their numbers are quoted as leads, not evidence.
- The *Ultralearning* book itself was not fetched. The author's book landing page (fetched) cites no studies and lists case studies and endorsements. So "where the book exceeds the evidence" below is assessed against the **claims as OSVR operationalises them** in `CLAUDE.md` and `docs/ULTRALEARNING.md`, plus what the book's public page asserts without citation.
- No direct trial of any mechanic on exploit development or vulnerability research exists in what I found. Everything for OSVR's domain is extrapolation from general learning science, CS education and a thin cybersecurity-education literature. Treat the ratings as "evidence for the mechanic in general", then see the extrapolation note in each section.
- Evidence-strength scale: **strong** = multiple meta-analyses or large reviews agree, effects robust to moderators in the population studied; **moderate** = meta-analytic support with large heterogeneity or restricted materials/populations; **weak** = few studies, small samples, or only indirect; **contested** = published disagreement among qualified researchers.

## Question list (planned before searching)

1. Retrieval practice: effect size, conditions, transfer to complex tasks.
2. Spacing: effect size, optimal gap, whether it holds for skills as well as facts.
3. Interleaving: effect size, where it fails.
4. Deliberate practice: how much does it explain (Macnamara et al.), what is the counter-argument?
5. Feedback: effect size, timing (immediate vs delayed), type, harmful forms.
6. Desirable difficulties / generation effect / productive failure: support for "struggle before hints".
7. Worked examples and expertise reversal: the tension with "closed-book before walkthrough".
8. Self-explanation and Feynman-style explanation.
9. Programming education evidence: worked examples, subgoal labels, Parsons problems, predict-run. (Partial: no programming-specific retrieval/spacing/interleaving trials found.)
10. Security-skills evidence: CTF effectiveness, cybersecurity education, how real VR practitioners learn.
11. Self-directed adult learning: MOOC/self-paced attrition and what reduces it.
12. Transfer / directness: does learning in context transfer? (Partial: general transfer literature only; no VR-specific.)

## 1. Retrieval practice / testing effect

**Rating: STRONG for retention of facts and concepts; MODERATE for transfer to application and for complex skills; WEAK for exploit-development specifically (no direct trials).**

| Source | Finding (abstract-only unless noted) | Population / materials |
|---|---|---|
| Dunlosky et al. 2013, *PSPI* (monograph reviewing 10 techniques) | Practice testing and distributed practice received the highest utility ratings (high-utility rating confirmed from the APS press release; abstract confirms the 10 techniques and four-category generalisability framework) | Mostly students; lab and classroom; note the authors' own caveat that techniques help motivated, capable students and are "not a panacea" (APS release) |
| Rowland 2014, *Psych Bull* (meta-analysis) | Testing beats restudy for retention; initial **recall** tests yield larger benefits than recognition tests; support for effortful processing. Pooled d of about 0.50 appears only in a secondary snippet, not in the abstract: `unconfirmed` | Mostly lab, verbal materials |
| Yang et al. 2021, *Psych Bull* (meta-analysis, 222 studies, 48,478 students) | Classroom quizzing g = 0.499. Moderated by control-condition strategy, test-format consistency, **provision of corrective feedback**, number of repetitions | Real classrooms, mostly school and university |
| Pan & Rickard 2018, *Psych Bull* (meta-analysis, 122 experiments, N = 10,382) | Transfer d = 0.40. Largest transfer to application and inference questions, medical diagnosis problems, different test formats. **Weakest** to untested materials and to problems involving worked examples. Elaborated retrieval, response congruency and initial test performance drive transfer. After publication-bias correction, intercept predictions often show no positive transfer when none of those moderators is present | Mixed; includes problem-solving transfer |
| Donoghue & Hattie 2021, *Front Educ* (meta-analysis of the 10 Dunlosky techniques, 242 studies) | Distributed practice and practice testing again top; overall mean 0.56 across techniques. **Major limitation: most studies measure surface/factual outcomes**; feedback presence, near vs far transfer, and learner ability moderate (effects larger for lower-ability students) | Mixed |
| Adesope et al. 2017 (practice-testing meta-analysis) | Not retrieved; search did not return it. Omitted | n/a |

Conditions under which it holds: recall (production) beats recognition; feedback after the retrieval attempt improves it; successful initial retrieval matters; delayed tests show larger gains than immediate tests (this last point is from the Yang/Rowland framing, `abstract-only`, not independently confirmed).

Where it fails or weakens: transfer to materials never tested, and to problems built from worked examples, is weakest (Pan & Rickard). A bias-corrected analysis suggests transfer can vanish without elaboration, congruent response formats, or good initial performance.

Extrapolation to OSVR: `cards.yaml` free-recall cards directly use the best-supported variant (recall, not recognition). The evidence supports cards for facts and concept explanations. For procedures ("write the tcache poisoning steps") the evidence is indirect; retrieval of a step list is plausible to help recall the list, but there is no evidence found that it builds the ability to execute on a new binary. Pan & Rickard's finding that elaborated, application-level retrieval transfers better argues for cards that ask for **application to a fresh case**, not only recitation. `needs-lab-verification` by pilot learners.

Where OSVR's claims exceed evidence: "Testing is learning" is well supported for retention; "closed-book challenge before solutions" as a *pre-test on unseen material* is a different mechanic (generation/productive failure; see section 6), not the testing effect, which concerns retrieval of previously studied content. The contract conflates them.

## 2. Spacing / distributed practice

**Rating: STRONG for retention of verbal/declarative material; MODERATE for skills and procedures (task-dependent); WEAK/untested for multi-week exploit-building projects.**

- Cepeda et al. 2006, *Psych Bull* (meta-analysis; 839 assessments, 317 experiments, 184 articles): inter-study interval and retention interval operate jointly; the interval that gives maximal retention grows as the retention interval grows. (abstract-only)
- Cepeda et al. 2008, *Psych Sci* (1,350+ people, gaps up to 3.5 months, tests up to 1 year later): final test performance first rises then slowly falls as the gap widens. The optimal gap, as a **proportion** of the retention interval, falls from about 20 to 40% for a 1-week test delay to about 5 to 10% for a 1-year delay. Authors conclude many educational practices are highly inefficient. Material: trivia-type facts, adults. (abstract-only)
- Donovan & Radosevich 1999, *J Appl Psych* (63 studies, 112 effect sizes): overall d = 0.46 for spaced over massed, but the **nature of the task and the inter-trial interval significantly moderate it, and effects were larger in methodologically weaker studies**. This is the main caution for skill practice: the "spacing always wins" claim is robust for verbal recall and not uniformly so for tasks. (abstract-only)
- Latimier et al. 2021 (spaced retrieval practice meta-analysis, 29 studies): published version `verified: null`; only the preprint abstract (29 studies) was retrieved. Not used for effect sizes.
- Dunlosky 2013 and Donoghue & Hattie 2021 both rank distributed practice at the top.

Practical gap rule supported by Cepeda 2008: pick the review gap from when you need to remember. For needing recall in about a week, review gaps of a day or two; for months, gaps of a few days to a couple of weeks; do not be too short, because too-short gaps cost more than too-long gaps (the gap-versus-retention curve peaks then declines gently; the "short is worse than long" asymmetry is from a press summary of the 2008 study and is `unconfirmed` against the paper).

Whether expanding intervals beat uniform spacing: Cepeda 2006 analysed expanding intervals but its abstract does not state the result; I did not find a fetched source settling it. `needs-lab-verification` / do not claim.

Where OSVR's claims exceed evidence: "15 minutes daily beats 2 hours weekly" (`docs/ULTRALEARNING.md`, section 7) is directionally consistent with spacing but not tested as stated; spacing studies compare gaps between study events for the same material, not session lengths. Say "distributed review beats cramming" rather than a 15-vs-120 minute comparison.

## 3. Interleaving

**Rating: MODERATE overall and CONTESTED for generalisation beyond category-learning tasks; WEAK for procedural/exploit skills.**

- Brunmair & Richter 2019, *Psych Bull* (59 studies, 238 effect sizes): overall Hedges g = 0.42. Paintings g = 0.67; mathematics g = 0.34; expository texts and tastes non-significant; **blocking beat interleaving for words (g = -0.39)**. Effect stronger when material is **more similar between categories**, **less similar within categories**, and more complex. (abstract-only)
- Dunlosky 2013 rated interleaving "moderate" (rating from a web-search summary of the monograph, not confirmed in the abstract I retrieved: `unconfirmed`).
- A classroom cluster RCT of interleaved maths practice (AERA 2019 conference paper) exists; I retrieved only the design abstract, not the result. Not used.

Mechanism per the meta-analysis: interleaving helps when the learner must discriminate between confusable categories (inductive learning). It does not help, and may hurt, when items are dissimilar between categories or when the task is rote association.

Extrapolation to OSVR: the discrimination case maps well to *bug-class triage* (UAF vs double free vs type confusion; which primitive does this write give?), where categories are similar between classes and varied within. It maps poorly to learning a single new procedure (first build of a ROP chain). No evidence was found for interleaving in exploit-development, programming or any security training. Recommendation: block first, interleave only in discrimination drills after each class is individually competent. `needs-lab-verification`.

## 4. Deliberate practice

**Rating: CONTESTED as an explanation of individual differences; the training principles bundled inside it (targeted practice on weaknesses, immediate informative feedback) are separately supported.**

- Ericsson, Krampe & Tesch-Römer 1993, *Psych Rev* (the original framework; abstract fetched): expert performance is the product of prolonged, effortful activities designed to improve performance, over a minimum of about 10 years in most domains.
- Macnamara, Hambrick & Oswald 2014, *Psych Sci* (meta-analysis): deliberate practice explained 26% of variance in performance for games, 21% for music, 18% for sports, **4% for education, and less than 1% for professions**. Conclusion: important, but less than claimed. (abstract-only)
- Macnamara, Moreau & Hambrick 2016, *Perspect Psych Sci* (sports): 18% of variance overall, only **1% among elite performers**; athletes reaching high levels did not start earlier. (abstract-only)
- Macnamara & Maitra 2019, *R Soc Open Sci* (replication of the 1993 violin study with double-blind procedure): did **not** replicate the core finding that accumulated practice corresponded to each skill level; effect substantial but considerably smaller; teacher-designed practice did not account for more variance than practice alone. (abstract-only)
- Ericsson 2020, *Psych Res* (reply, abstract fetched): argues Macnamara et al. defined deliberate practice too broadly and that the original five criteria were not what the meta-analysis coded.
- Frontiers in Psychology 2020 (review; authors not captured in the record): documents inconsistencies in how deliberate practice has been defined and tested.

How to read this: the disagreement is partly definitional (does "hours of structured practice" equal Ericsson's deliberate practice?). Both sides agree practice matters. What the meta-analyses undercut is the stronger public claim that accumulated deliberate practice hours, not other factors, largely explain who becomes elite. For a **professions** domain like vulnerability research, the pooled contribution is near zero in the coded studies, but these are correlational, mostly retrospective-estimate studies and say little about whether a *designed* programme raises a given learner's skill.

Where the ultralearning approach exceeds the evidence: any claim that sufficient aggressive practice reliably produces expert performance (the book's public page promises mastering hard skills quickly, with case studies and no cited studies). Treat as motivational framing, not a finding. Also the "magnifying glass: 10x normal time on one component" drill has no evidence found.

Implication: OSVR should not quote practice-hours as a predictor or promise; it can still justify drills on the rate-determining step by the separately supported mechanics (feedback, generation, retrieval).

## 5. Feedback: timing, type, harm

**Rating: STRONG that feedback helps on average; CONTESTED on immediate vs delayed; STRONG that content and target of feedback matter, and that some feedback harms.**

- Kluger & DeNisi 1996, *Psych Bull* (607 effect sizes, 23,663 observations): feedback interventions improve performance on average (d = 0.41), but **more than a third decreased performance**. Feedback Intervention Theory: effectiveness falls as attention shifts toward the self and away from the task. (abstract fetched)
- Wisniewski, Zierer & Hattie 2019 (open access; abstract retrieved via Europe PMC; the PMC full text was blocked): 435 studies, k = 994, N > 61,000; d = 0.48; **information content** is a strong moderator; effects are higher for cognitive and motor-skill outcomes than for motivational/behavioural outcomes; large heterogeneity.
- Hattie & Timperley 2007, *Rev Educ Res* (conceptual review, abstract): type and delivery matter; discusses timing and positive vs negative feedback. Shute 2008 (review, abstract): formative feedback should be nonevaluative, supportive, timely, specific; types include verification, explanation, hints, worked examples.
- **Timing**: Kulik & Kulik 1988 (meta-analysis, 53 studies, abstract): applied classroom studies usually found immediate feedback more effective; experimental studies of acquisition of test content usually found the opposite (delay better); list-learning labs varied systematically with study features. A 2021 experiment (QJEP, abstract) found no immediate/delayed difference in two studies and a delayed advantage when feedback was delayed by days, with the authors proposing that delay lets learners forget their wrong hypotheses.
- Yang 2021 above: corrective feedback moderates the testing effect.
- Higher-education feedback is thinly evidenced: a systematic review of trials (Rev Educ 2021, abstract) says there is little causal evidence at HE level, but low-stakes quizzing is particularly powerful, peer/tutor feedback helps depending on implementation, and evidence for praise, grading and technology-based feedback is mixed.

Conditions: task-level, information-rich feedback helps; self-level praise/criticism diverts attention and can hurt; "immediate" is the safer default for procedural/applied tasks, and a delay can help conceptual learning when the learner has had to commit to an answer first.

Where OSVR's labels hold up: its outcome/informational/corrective split corresponds to the literature's verification vs elaboration distinction (Shute 2008). "Corrective only after the learner tries to self-correct" is consistent with generation and productive-failure evidence but was not directly tested.

Help/hint ladders: Aleven et al. 2016 (*IJAIED*, abstract): an ITS "Help Tutor" that gave feedback on help-seeking made students use on-demand help more deliberately, even after feedback was removed, but **did not improve domain learning outcomes**. So the evidence that teaching help-seeking improves behaviour is better than the evidence that it improves learning. No direct evidence found for a six-rung hint ladder as designed here. `weak`.

## 6. Desirable difficulties, generation effect, productive failure (supports "struggle before hints", with conditions)

**Rating: generation effect STRONG (moderate size); productive failure MODERATE with an important prior-knowledge condition; "20-minute struggle" threshold has NO evidence found.**

- Generation effect: Bertsch et al. 2007, *Mem Cognit* (86 studies, 445 effect sizes): overall effect 0.40, generation beats reading; substantial variability across 11 moderators. (abstract-only; the abstract does not say which moderators matter or whether it holds for complex material)
- Productive failure: Sinha & Kapur 2021, *Rev Educ Res* (53 studies, 166 comparisons): problem-solving-then-instruction (PS-I) beats instruction-then-problem-solving (I-PS), Hedges g = 0.36 [0.20, 0.51]; g = 0.37 to 0.58 when implemented with high fidelity to Productive Failure design; bias-adjusted estimate g = 0.87 (the authors' own estimate; treat with caution, because bias correction on heterogeneous data is itself model-dependent). **Contrasting trends: younger learners (grades 2 to 5) and learning of domain-general skills favoured instruction first.** (abstract fetched via OpenAlex). The press coverage reports a prior-knowledge requirement; I did not confirm that in the paper.
- Alfieri et al. 2011, *J Educ Psychol* (164 studies; abstract retrieved via Semantic Scholar): **unassisted discovery lost to explicit instruction (d = -0.38, 580 comparisons)**; **enhanced/assisted discovery beat other instruction (d = 0.30, 360 comparisons)**. The authors conclude unassisted discovery does not benefit learners, whereas feedback, worked examples, scaffolding and elicited explanations do.
- Kirschner, Sweller & Clark 2006 (position paper, abstract): minimally guided instruction is less effective and efficient; the advantage of guidance recedes only when learners have sufficiently high prior knowledge. Hmelo-Silver, Duncan & Chinn 2007 (response, abstract): problem-based and inquiry learning are highly scaffolded and so are not the same as unguided discovery. The honest reading: both sides endorse scaffolded, guided inquiry and reject unguided discovery.
- Bjork-style "desirable difficulties" as an umbrella: I could not retrieve the primary integrative review (a search for it returned no match), so the framework is supported here only through its components (testing, spacing, interleaving, generation). `unverified` as a unifying claim.

What this means for "struggle before hints": supported **if** (a) the learner has the prerequisite knowledge to make productive attempts, (b) the struggle is followed by explicit consolidating instruction that contrasts the learner's attempt with the canonical solution (the PF structure), and (c) the struggle is bounded. A 20-minute threshold is not derived from any source I found; treat it as a pilot parameter. Struggle that is not scaffolded and not followed by consolidation corresponds to the unassisted-discovery condition that lost.

## 7. Worked examples and expertise reversal (the tension with "closed-book before walkthrough")

**Rating: worked-example effect for novices STRONG; expertise reversal MODERATE (well documented, theory-driven, boundary conditions vary); the combination with productive failure is CONTESTED.**

- Expertise reversal: Kalyuga, Ayres, Chandler & Sweller 2003, *Educ Psychol* (review, abstract): instructional techniques that are highly effective with inexperienced learners can lose their effectiveness and even have negative consequences with more experienced learners. Explained through limited working memory and schema construction.
- Worked examples in maths: Barbieri et al. 2023, *Educ Psych Rev*: g = 0.48 average, per a web-search snippet; study counts and moderators (e.g. self-explanation prompts reducing the effect) are from snippets only. `verified: null`, `status: unverified`; do not rely on figures.
- Pan & Rickard 2018 (above): transfer of testing is weakest for worked-example problems, relevant to how retrieval and worked examples interact.
- Alfieri 2011: worked examples are one of the features that make guided discovery succeed.
- Kirschner et al. 2006: guidance advantage recedes with high prior knowledge, which is the same boundary as expertise reversal.

**The tension, stated plainly:** OSVR's "closed-book challenge before the walkthrough" (D5) is a PS-I design. Productive failure says PS-I helps (g about 0.36 overall), but only reliably when the learner can generate something relevant and when consolidation follows. Worked-example/cognitive-load theory predicts that a true **novice to this sub-skill** wastes working memory on search and learns less than from a worked example first, then faded practice. The learner population (no degree, wide range from "can use a terminal" to working SOC) means the same challenge is productive for some and wasteful for others. Neither literature tested exploit development; the closest populations are novice programmers (section 9) and school or university maths/science.

Resolution supported by the evidence: make the order **conditional on prior knowledge of the specific sub-skill**:
1. First exposure to a new technique or tool (a new mitigation, a first heap exploit): worked example first, with subgoal labels, then a faded/completion task.
2. Once the learner has the prerequisite pieces (as shown by a quick diagnostic), use the struggle challenge, followed by comparison with the canonical solution.
3. Late in the track, scaffolding should fade; the capstones are the expertise-reversal end state.

## 8. Self-explanation and Feynman-style explanation

**Rating: MODERATE for self-explanation prompts; WEAK specifically for the "explain it to a smart non-specialist" (teaching) format.**

- Chi et al. 1989, *Cogn Sci* (abstract fetched): think-aloud study of "Good" and "Poor" students studying worked examples of physics mechanics problems; good students generated more self-explanations and monitored their understanding more accurately; poor students relied heavily on examples. Small sample, correlational (good students self-explain more; not randomised).
- Dunlosky 2013: self-explanation rated moderate (rating `unconfirmed` against a fetched primary page; from a search summary).
- Bisra et al. 2018, *Educ Psych Rev* meta-analysis: web-search snippets say 64 studies, nearly 6,000 participants, small to moderate effect, generic prompts outperformed specific prompts, holding for procedural and conceptual knowledge. **`verified: null`, `status: unverified`**; abstract could not be retrieved.
- Barbieri 2023 (unverified) snippet: self-explanation prompts added to worked examples may reduce the effect; if confirmed this is a notable boundary condition. `needs-lab-verification`.
- Learning-by-teaching / protege effect: no meta-analysis located in my searches; results returned were individual studies of teachable agents (e.g. a 2013 study with 141 students found improved proficiency but no observed improvement in conceptual understanding). Treat Feynman-as-teaching as **weak** and as self-explanation by another name.

Implication: grading the Feynman explanation is defensible as a form of elaboration/self-explanation, but the specific "explain to a non-specialist" format is not separately validated. Also, quality of the learner's explanation is a measurement of understanding (a diagnostic), not itself the evidence of a learning gain.

## 9. Programming education evidence (the closest well-studied domain)

**Rating: MODERATE for subgoal-labelled worked examples; MODERATE/WEAK for Parsons problems (efficiency, not gains); WEAK for PRIMM-style predict-run (one mixed-methods quasi-experiment, school-age).** No evidence for retrieval, spacing or interleaving specifically in programming was found (searches returned unrelated results). That is a gap, not a negative finding.

- Subgoal labels: Margulieux 2014 (abstract): subgoal labels in both instructional text and worked example let learners solve novel problems better; the two placements act differently. Margulieux 2016 (abstract; 138 undergraduates, App Inventor): sequence interacts with subgoal labels; worked example then expository text with subgoal labels was best for outlining the procedure. Margulieux et al. 2020, *Int J STEM Educ* (265 students, semester-long): subgoal instruction improved formative quizzes given within a week of learning, **but not summative exams**; fewer students dropped or failed, and variance in exam scores was lower. (abstract fetched) Effects seemed especially useful for students at risk of failing.
- Parsons problems (rearrange mixed-up code blocks): the 2023 multi-institution paper's introduction (abstract) summarises prior evidence as: engaging, perceived useful, typically easier and faster than writing code from scratch, **with equivalent learning gains**; the 2018 ICER paper reports adaptive Parsons problems as a more efficient form of practice. Population: undergraduates and school-age novices. Takeaway: efficiency gain at equal learning, not superior learning.
- PRIMM (Predict, Run, Investigate, Modify, Make; 2019 *Comput Sci Educ*, abstract): 13 schools, 493 students aged 11 to 14, control group, 8 to 12 weeks, mixed methods; learners did better on the post-test than controls and teachers reported benefits. School-age, one study family, abstract-only.
- Cross-cutting: dropout and failure in introductory programming are regularly about 50% (Margulieux 2020 abstract, which states this as background).

Extrapolation to OSVR:
- **Subgoal labels** are directly transferable to exploit walkthroughs (label "leak", "groom", "corrupt", "pivot" as explicit subgoals), because the exploit procedure is a multi-subgoal problem-solving procedure of the same kind.
- **Parsons-style completion tasks** can be built for exploit steps (reorder the steps of a heap-grooming sequence; fill the missing step in a ROP chain) as a lower-cost drill that appears not to sacrifice learning, per the programming evidence; `needs-lab-verification` for the security domain.
- **Predict-run** (predict the allocator state or crash, then run it) is a plausible fit with the cognitive-component drill and with self-explanation, but the supporting trial is school-age and single-study.
- All of this is **novice-programmer** evidence. The OSVR learner is much further along in a much harder domain, so expertise reversal could reduce some of these effects midway through a track.

## 10. Security-skills evidence

**Rating: WEAK. CTF/cybersecurity-education evidence is rated Low certainty or Very Low certainty by the only GRADE-based systematic review found.**

- A 2026 systematic review of CTF methodologies in cybersecurity education (*Eur J STEM Educ*; abstract retrieved via OpenAlex; PDF could not be decoded): 18 eligible empirical studies from 2017 to 2025; CTF participation is frequently associated with engagement and self-reported confidence; some short-term technical-skill gains, but based on self-report, indirect indicators, small samples or uncontrolled designs. Using GRADE: certainty **Low** for engagement and perceived confidence, **Very Low** for demonstrated technical competence, retention and transfer to practice. Recurring design features (scaffolded difficulty, teamwork, progressive challenges) had independent effects that were rarely evaluated. This is a recent single review and the authors' own appraisal; there is not yet a second independent confirmation. Flag: `single source`.
- Svabensky et al. 2020, *Computers & Security* (abstract fetched via arXiv): analysed 15,963 textual CTF solutions since 2012, mapped to ACM/IEEE curricular guidelines by keyword; skills taught are heavily technical (cryptography and network security prominent); human aspects such as social engineering and awareness are underrepresented. This is a coverage study, not an effectiveness study.
- How practitioners actually learn and work (descriptive, interview/observation, not trials):
  - Votipka et al. 2018, IEEE S&P (n = 25 testers and hackers, abstract): both groups follow similar processes but get different results mostly because of differing experience and underlying knowledge of security concepts; the paper discusses how they develop skills.
  - Votipka et al. 2019 arXiv (N = 16 reverse engineers, abstract): a three-phase model of reverse engineering: overview, sub-component scanning, focused experimentation; static methods in the first two phases. Useful as a task-analysis source for RE drills.

Implication: the OSVR claim that CTF-style, project-driven learning is effective rests on general learning science and expert accounts, not on demonstrated effectiveness data in the domain. This should be stated as an assumption, and the pilot should collect outcome data (time to reproduce, retention at 4 and 12 weeks, ability on a fresh binary).

## 11. Self-directed adult learning and attrition (tutorial hell, quitting)

**Rating: attrition descriptive evidence STRONG that it is high; evidence on what reduces it MODERATE and mostly from MOOCs; evidence on "tutorial hell" per se NONE found (no studies using that construct).**

- Jordan 2014, *IRRODL* (abstract): average MOOC enrolled about 43,000 students, of whom 6.5% completed; completion negatively correlated with course length. Data are from 2012 to 2013 era public figures and are dated; completion is also a questionable success metric for learners with different intentions (a point made in the 2017 IRRODL motivation study abstract below).
- Heliyon 2023 (systematic review, 21 studies 2008 to 2021, PRISMA): dropout factors fall into Course Attributes, Social Status, Cognitive Ability, Emotional Factor, and Learning Behaviour; engagement patterns group into start, mid, end stages. Abstract-only.
- Motivation and retention systematic review, 2022 (50 publications): six motivational factors; academic motives most important; self-determination theory most used; effects mediated by satisfaction, **self-regulation**, attitude, performance, engagement.
- SRL intervention, *Comput Educ* 2019 (three MOOCs; authors not captured in the record): short videos teaching SRL instruction and study suggestions **positively affected course completion**; complying learners did more planning, help-seeking and persistence. Experimental, but MOOC volunteers.
- Margulieux 2020 above: subgoal-labelled instruction reduced dropping/failing in a semester programming course.
- Learners' motivations vary widely (IRRODL 2017 study of 6,335 learners from 160 countries, abstract), so a completion rate is not by itself a failure signal.

Implication for the target learner failure modes: the evidence supports structured planning and SRL scaffolds (the session protocol's declared goal and timebox is in the spirit of the SRL intervention) and making early tasks achievable. It does not validate specific session mechanics such as 50/10 timeboxes, 5-minute "just open the debugger" starts, or "never end at a natural stopping point"; I found no sources for those and did not test them. Flag as pilot parameters.

## 12. Transfer and "directness"

**Rating: transfer is CONDITIONAL (strong that far transfer is rare; contested/unsettled for conditions); directness as a design principle is a reasonable inference, not a tested intervention.**

- Barnett & Ceci 2002, *Psych Bull* (abstract): a single effect size for far transfer is misguided; transfer varies along 9 dimensions; evidence for transfer under some conditions is substantial.
- Sala & Gobet 2017, *Curr Dir Psychol Sci* (abstract): meta-analyses of chess, music and working-memory training found small to moderate effects inversely related to design quality; "far transfer of learning rarely occurs".
- Pan & Rickard 2018: near and moderate transfer of retrieval is real, far weaker without elaboration.

Relation to OSVR: this supports practising on real tools and real targets (D1) because skills tied to context transfer poorly across contexts. It does not show that the best way to learn is by direct practice from the start; novices benefit from decomposed worked examples (sections 7, 9) before whole-task practice. The book's public page asserts claims about what education beliefs are "debunked" without cited studies; the transfer literature above is the real support for directness, and it is more qualified than the book.

## Evidence ledger by OSVR contract mechanic

| Mechanic (CLAUDE.md contract) | Strength | Key conditions | Where OSVR exceeds evidence |
|---|---|---|---|
| Metalearning (map first, ~10% planning) | Not reviewed (no studies retrieved) | n/a | The 10% figure has no source |
| Focus (session protocol) | Weak (SRL interventions support planning; no support for 50/10) | MOOC volunteers | 50/10, 5-min start, stop-mid-task |
| Directness | Moderate by inference | Transfer is conditional | "Toy examples only as stepping stones" is consistent; "directness first" for novices is not supported |
| Drill (rate-determining step) | Weak-moderate by inference (deliberate practice contested; targeted feedback supported) | n/a | 10x magnifying glass; hours-based claims |
| Retrieval | Strong (recall, feedback) | Facts/concepts; transfer needs elaboration | Using pre-tests as testing effect |
| Feedback (outcome/informational/corrective) | Strong that it helps; heterogeneous | Task-level, informative; avoid self-directed | Hint ladder as designed is untested |
| Retention (SRS, proceduralisation, overlearning) | Spacing strong for facts, moderate for skills | Gap scales with retention interval | 15 min/day vs 2 h/week; leech rule; overlearning not reviewed |
| Intuition (struggle rule, Feynman, derive-it) | Moderate (generation, PF, self-explanation) | Prior knowledge; consolidation; guidance | 20-minute rule; Feynman-as-teaching |
| Experimentation (copy then create) | Not directly reviewed; consistent with worked-example-then-variation and guided discovery (Alfieri) | Scaffolded | n/a |

## Implications for OSVR (suggestions for the architect to accept or reject)

1. **Make struggle-before-walkthrough conditional, not universal.** Evidence: Alfieri (unassisted -0.38 vs enhanced +0.30), Kirschner (guidance advantage recedes with prior knowledge), Sinha & Kapur (PS-I g = 0.36, reversed for domain-general skills and young learners), Kalyuga (expertise reversal). Suggest D5 text: for a technique the learner has not met, run worked example plus subgoal labels, then a faded completion exercise; use the closed-book challenge once a short prerequisite diagnostic passes; always follow with consolidation that compares the learner's attempt to the canonical solution. Replace "20 minutes" with a tunable parameter and log time-to-first-hint in pilots.
2. **Add worked examples and subgoal labels to the walkthrough template** (README walkthrough). Support: Margulieux 2014/2016/2020 (programming novices), Alfieri (worked examples a feature of effective guided discovery). Keep `needs-lab-verification` for exploit tasks.
3. **Reword retrieval cards toward application, with feedback.** Support: Pan & Rickard (elaborated retrieval, application transfer), Yang (feedback moderates), Rowland (recall > recognition). Add card types that ask for the next step on a fresh case, not just recitation. Keep success on first retrieval high; low initial performance reduces transfer benefit.
4. **Do not claim CTF or practice hours are validated.** State in MAP.md files and in contributor docs that effectiveness evidence for CTF-style learning is Low/Very Low certainty (2026 GRADE review) and that deliberate practice is contested (Macnamara 2014: <1% variance in professions). Replace "practice hours" language with targeted, feedback-rich practice and measure outcomes in the pilot.
5. **Spacing guidance**: give an explicit rule of thumb tied to Cepeda 2008 (review gap roughly 5 to 40% of the time you need to remember, shrinking as the horizon lengthens) and drop "15 minutes daily beats 2 hours weekly" as a numeric claim. For long procedural builds, accept that spacing evidence is weaker (Donovan & Radosevich); mark `needs-lab-verification`.
6. **Interleaving**: introduce bug-class discrimination drills (similar-between, varied-within) only after blocked mastery per class. Support: Brunmair & Richter moderators; words/rote material is blocked-favoured.
7. **Feedback design**: keep assessor feedback task-level and informational; avoid evaluative/self-directed comments (Kluger & DeNisi: over a third of interventions reduced performance). Immediate for procedure checks (lab checkers); consider delaying the corrective explanation until the learner commits to a diagnosis (Kulik & Kulik; the 2021 QJEP result), flagged as weak support.
8. **Attrition**: add a short SRL primer in the first module (plan, monitor, seek help) and keep the first wins fast; evidence is from MOOCs and CS1 courses, so pilot with a retention metric (weeks active, modules completed).
9. **Treat the Feynman task as self-explanation graded for diagnostic value**; do not claim it independently improves learning. If self-explanation prompts are used with worked examples, test with and without (possible negative interaction, unverified).
10. **Instrument the pilot** to fill the evidence gaps that this review found empty for VR: time-to-solution with worked-example-first vs struggle-first cohorts, retention at 4 and 12 weeks on fresh binaries, completion rates. These are the questions no published study answers.

## Open questions / conflicting sources

- Ericsson vs Macnamara/Hambrick: definition of "deliberate practice" is disputed; both are T1 (peer-reviewed) and disagree.
- Kirschner/Sweller vs Hmelo-Silver: whether problem-based/inquiry learning is "unguided"; they agree on the role of scaffolding.
- Sinha & Kapur's bias-adjusted g = 0.87 vs unadjusted 0.36; interpret the lower figure.
- Feedback timing: applied vs lab findings point in opposite directions (Kulik & Kulik 1988).
- Not found: security-specific or exploit-development learning trials; programming-specific retrieval/spacing/interleaving trials; any meta-analysis of learning-by-teaching; the primary Bjork "desirable difficulties" integrative review; Adesope 2017.
- Not retrieved and possibly relevant: Hattie-style effect-size conversions, Zeigarnik/stop-mid-task evidence, timeboxing evidence.

## Sources (all `verified: 2026-11-10` unless marked)

Verification method codes: EPMC = Europe PMC REST record with abstract; OA = OpenAlex record with abstract; S2 = Semantic Scholar record with abstract; PAGE = page fetched directly. All are abstract/record-level.

T1 (peer-reviewed / review level):
- Dunlosky et al. 2013, Psychological Science in the Public Interest, doi 10.1177/1529100612453266 (EPMC; ratings via APS release below)
- Rowland 2014, Psychol Bull, doi 10.1037/a0037559 (EPMC)
- Yang et al. 2021, Psychol Bull, doi 10.1037/bul0000309 (EPMC)
- Pan & Rickard 2018, Psychol Bull, doi 10.1037/bul0000151 (EPMC)
- Donoghue & Hattie 2021, Front Educ, doi 10.3389/feduc.2021.581216 (OA)
- Cepeda et al. 2006, Psychol Bull, doi 10.1037/0033-2909.132.3.354 (EPMC)
- Cepeda et al. 2008, Psychol Sci, doi 10.1111/j.1467-9280.2008.02209.x (EPMC)
- Donovan & Radosevich 1999, J Appl Psychol, doi 10.1037/0021-9010.84.5.795 (OA)
- Brunmair & Richter 2019, Psychol Bull, doi 10.1037/bul0000209 (EPMC)
- Ericsson, Krampe & Tesch-Romer 1993, Psychol Rev, doi 10.1037/0033-295x.100.3.363 (OA)
- Macnamara, Hambrick & Oswald 2014, Psychol Sci, doi 10.1177/0956797614535810 (EPMC)
- Macnamara, Moreau & Hambrick 2016, Perspect Psychol Sci, doi 10.1177/1745691616635591 (EPMC)
- Macnamara & Maitra 2019, R Soc Open Sci, doi 10.1098/rsos.190327 (OA)
- Ericsson 2020, Psychol Res, doi 10.1007/s00426-020-01368-3 (OA)
- Frontiers in Psychology 2020, deliberate practice review, doi 10.3389/fpsyg.2020.01134 (OA)
- Kluger & DeNisi 1996, Psychol Bull, doi 10.1037/0033-2909.119.2.254 (PAGE: https://cris.huji.ac.il/en/publications/the-effects-of-feedback-interventions-on-performance-a-historical/)
- Wisniewski, Zierer & Hattie 2019, Front Psychol, doi 10.3389/fpsyg.2019.03087 (EPMC; PMC full text blocked)
- Hattie & Timperley 2007, Rev Educ Res, doi 10.3102/003465430298487 (OA)
- Shute 2008, Rev Educ Res, doi 10.3102/0034654307313795 (OA)
- Kulik & Kulik 1988, Rev Educ Res, doi 10.3102/00346543058001079 (OA)
- Immediate vs delayed feedback on complex concept learning, QJEP 2021, doi 10.1177/1747021820977739 (EPMC)
- Higher-education feedback systematic review, Review of Education 2021, doi 10.1002/rev3.3292 (OA)
- Aleven et al. 2016, IJAIED, doi 10.1007/s40593-015-0089-1 (OA)
- Bertsch et al. 2007, Mem Cognit, doi 10.3758/bf03193441 (EPMC)
- Sinha & Kapur 2021, Rev Educ Res, doi 10.3102/00346543211019105 (OA)
- Alfieri et al. 2011, J Educ Psychol, doi 10.1037/a0021017 (S2)
- Kirschner, Sweller & Clark 2006, Educ Psychol, doi 10.1207/s15326985ep4102_1 (OA)
- Hmelo-Silver, Duncan & Chinn 2007, Educ Psychol, doi 10.1080/00461520701263368 (OA)
- Kalyuga, Ayres, Chandler & Sweller 2003, Educ Psychol, doi 10.1207/s15326985ep3801_4 (OA)
- Chi et al. 1989, Cognitive Science, doi 10.1207/s15516709cog1302_1 (OA)
- Barnett & Ceci 2002, Psychol Bull, doi 10.1037/0033-2909.128.4.612 (OA)
- Sala & Gobet 2017, Curr Dir Psychol Sci, doi 10.1177/0963721417712760 (OA)
- Margulieux et al. 2020, Int J STEM Educ, doi 10.1186/s40594-020-00222-7 (OA; springer pages blocked)
- Margulieux 2014 subgoal labeled instructional text, GSU ScholarWorks, https://scholarworks.gsu.edu/ltd_facpub/6 (OA record)
- Margulieux 2016 instructional material order and subgoal labels, GSU ScholarWorks, https://scholarworks.gsu.edu/ltd_facpub/8 (OA record)
- PRIMM, Computer Science Education 2019, doi 10.1080/08993408.2019.1608781 (OA)
- Adaptive Parsons problems, ICER 2018, doi 10.1145/3230977.3231000 (OA)
- Multi-institutional Parsons problems, ITiCSE 2023, doi 10.1145/3623762.3633498 (OA; the ACM PDF returned 403)
- Svabensky et al. 2020, Computers & Security, doi 10.1016/j.cose.2020.102154 (PAGE: https://arxiv.org/abs/2101.01421)
- CTF systematic review, Eur J STEM Educ 2026, doi 10.20897/ejsteme/19494 (OA; PDF not decodable)
- Votipka et al. 2018, IEEE S&P, doi 10.1109/sp.2018.00003 (OA)
- Observational study of reverse engineers, arXiv 2019, doi 10.48550/arxiv.1912.00317 (OA)
- Jordan 2014, IRRODL, doi 10.19173/irrodl.v15i1.1651 (OA)
- Heliyon 2023 MOOC dropout review, doi 10.1016/j.heliyon.2023.e15220 (OA)
- Motivation and MOOC retention review 2022, doi 10.1186/s41039-022-00181-3 (OA)
- Understanding learners' motivation and learning strategies in MOOCs, IRRODL 2017, doi 10.19173/irrodl.v18i3.2996 (OA)
- Supporting learners' self-regulated learning in MOOCs, Comput Educ 2019, doi 10.1016/j.compedu.2019.103771 (OA)

T3 (used only for the Dunlosky ratings and the book's public claims; reason: the monograph PDF was not fetchable):
- APS press release on Dunlosky et al. 2013: https://www.psychologicalscience.org/news/releases/which-study-strategies-make-the-grade.html (PAGE)
- Ultralearning book landing page: https://www.scotthyoung.com/blog/ultralearning/ (PAGE; no studies cited)

Unverified (`verified: null`, `status: unverified`; web-search snippets only; not used for evidence):
- Bisra et al. 2018, Inducing Self-Explanation: a Meta-Analysis, Educ Psychol Rev, doi 10.1007/s10648-018-9434-x (Springer abstract blocked)
- Barbieri et al. 2023, A Meta-analysis of the Worked Examples Effect on Mathematics Performance, Educ Psychol Rev, doi 10.1007/s10648-023-09745-1 (Springer abstract blocked)
- Latimier et al. 2021, spacing out retrieval practice, Educ Psychol Rev, doi 10.1007/s10648-020-09572-8 (abstract elided; only the preprint abstract retrieved)

Counts: about 46 sources verified at abstract/record level (not full text); 3 unverified. Full-text reading was not achieved for any paywalled source.

Dead ends (for the next researcher): PubMed and PMC pages return cookie/captcha walls to the fetch tool, Springer article pages redirect to an identity provider, SAGE and ACM PDFs return 403, and several author-hosted PDFs return binary the tool cannot decode. Europe PMC's REST search (`resultType=core`) and OpenAlex's API return abstracts reliably.
