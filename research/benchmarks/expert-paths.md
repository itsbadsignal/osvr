# Benchmark: expert learning paths (in their own words)
Researched: 2026-11-10   Questions answered: 4 of 5 fully, 1 partially (see Q3 and Q2 gaps)

Scope note: this file covers the "documented expert learning paths" part of the Benchmark format only. Serious training syllabi / university courses and the job-posting tally are covered in other files under `research/benchmarks/`. Ends with "Implications for OSVR".

## Query plan (written before searching)
1. Which working vulnerability researchers / exploit developers have described, in first person (blog, interview, talk, podcast transcript), how they learned the craft?
2. For each person: learning order; what they wish they had done earlier; what they call wasted or low-yield; time from start to first real bug/CVE; current specialisation and how they were first paid.
3. Which of them state they have no degree? (Degree status is recorded only where the source states it.)
4. Cross-person: common sequencing, recurring advice (read code, n-day reproduction, CTFs yes/no), disagreements.
5. How does time-to-first-bug vary by target class (web, browser, kernel, hypervisor, embedded/ICS)?

## Honesty notes on the evidence
- Most public "how I got into it" material is short, journalistic, and silent on regrets, wasted time and first-paid details. Where a source does not say, the entry says `not stated`. Nothing is filled from memory.
- Several transcripts are fetched from mirrors (rosetta.to for LiveOverflow videos, auto-generated captions; darknetdiaries.com transcripts; the Critical Thinking site). Mirrors are marked. Primary video was not watched.
- Survivorship bias: every person here succeeded, and stories are self-selected. First-bug timings are anecdotes, not a distribution.
- Only one fetched person self-describes as a college dropout (Bryant), and he is ecosystem/web-focused, not memory-corruption. The no-degree evidence base for native-code exploit development is thin in this file (see Open questions).

---

## Person entries

Format per entry: Source (tier, mirror?) / Degree status as stated / Learning order / Wish earlier / Wasted or low-yield / Time to first bug / Specialisation and first paid.

### 1. Jonathan Jacobi (browser/JIT; later product role)
- Sources: [LiveOverflow interview transcript, Apr 2025, rosetta.to mirror of video](https://rosetta.to/u/liveoverflow/from-zero-to-zero-day-and-beyond-life-of-a-hacker-jonathan-jacobi) (T3 mirror of T1 video); [35C3 talk abstract, 29 Dec 2018](https://media.ccc.de/v/35c3-9657-from_zero_to_zero_day) (T1). verified: 2026-11-10.
- Degree: stated. Entered a CS programme young; the abstract says BSc in Computer Science and Math; the interview says bachelor's finished around 18 alongside high school. Also about 5.5 years of Israeli military service (cyber course commander).
- Order: games, then private game servers, then coding challenges, then CTFs at about 15-16, learning from Twitter, articles and a classic stack-smashing paper. First buffer overflow was a no-mitigation CTF stack overflow he initially failed to implement; reading was easy, implementing exposed the gap.
- Wish earlier: not stated (says he is happy with his path).
- Wasted/low-yield: not directly stated. Says he was bad at CTFs for a long time and kept going; at 17 high school + degree + full workload at Check Point became too much and he scaled back work. Reports early feeling that networking-centred progress was not "technical" enough.
- Time to first bug: talk abstract says a little over a year, starting with almost no security background, to a first critical RCE in Edge (ChakraCore JIT type confusion). The interview transcript does not give method or hours.
- Specialisation / paid: vulnerability research internship at Check Point while studying (paid), then roughly 8-9 month MSRC internship (obtained by following up contacts met at a conference), then military research; now product/strategy role at a startup. Bounties not mentioned.
- Advice: move early to harder material you do not yet understand; post-CTF writeup discussion was among the most educational parts.

### 2. Valentina Palmiotti, "chompie" (Windows kernel/drivers; head of an offensive research team)
- Sources: [IBM X-Force Q&A, 2024](https://www.ibm.com/think/x-force/question-answer-valentina-palmiotti-chompie) (T2, employer-published interview); [CyberWire AI Security Brief ep. 5, 18 Jun 2026, transcript](https://www.thecyberwire.com/podcasts/ai-security-brief/5/transcript) (T2). verified: 2026-11-10.
- Degree: not stated. Prior career in macroeconomic research ("second career").
- Order: entered security "kind of by accident" via a cybersecurity boot camp in her city; a mentor showed her the basics ("I would have never discovered my passion and talent for hacking" without one); started learning security research in 2017; moved "officially" to vulnerability research and exploit development in 2020 during COVID lockdown.
- Wish earlier / wasted time: not stated.
- Time to first bug: not stated. She says one Pwn2Own exploit took weeks to build around mitigations (IBM Q&A). First Pwn2Own entry March 2024, a Windows 11 reference-count bug.
- Specialisation / paid: vulnerability research at IBM X-Force Red; first-paid details not stated. 2026 podcast: she tested an AI coding agent on a non-public race-condition exploit; reports it failed at first and improved when given her bug-class methodology and a way to check its work; says AI is lowering the bar but she has not yet seen unskilled users succeed with "find me 0-day" prompts. Not a learning-path claim; useful for the AI-era curriculum question.

### 3. Philippe Laulheret (embedded/IoT/medical, Cisco Talos)
- Source: [Talos interview](https://blog.talosintelligence.com/breaking-things-to-keep-them-safe-with-philippe-laulheret/) (T2). verified: 2026-11-10. Date of article not captured.
- Degree: stated. Math and physics in France, then an electrical and computer engineering school.
- Order: reverse engineering curiosity from childhood; CTF as a teenager; years of CTF alongside a development job (about four years at a design studio, then a security startup in New York) before moving into full-time vulnerability research.
- Wish earlier / wasted: not stated.
- Time to first bug: not stated.
- Specialisation / paid: vulnerability research at Talos. Credits CTF years ("even if it wasn't professional") for the transition.

### 4. Hypr (embedded routers, MediaTek SDK/kernel drivers; Pwn2Own)
- Source: [Critical Thinking podcast ep. 157 with transcript](https://www.criticalthinkingpodcast.io/episode-157-crushing-pwn2own-h1-with-kernel-driver-exploits/) (T2). verified: 2026-11-10. Final ~15k characters of the transcript read separately; interview partly read only (education, first job not covered).
- Degree: not stated.
- Order: long habit of buying cheap routers and poking at them in spare time; first real bug was a 2023 bug in a MediaTek userland daemon, written up and exploited; then a "biggest dive" into kernel driver bugs over a couple of years, using writeups, kernel source and trial and error.
- Wish earlier: not stated. Admits procrastinating without deadlines and accumulating 10 to 15 bugs before writing a full exploit.
- Wasted/low-yield: crash-and-reboot cycles on hardware called his least favourite part. Claims real-world bugs teach more than CTFs. Warns that if you only write exploits for bugs you find, most of your time goes into learning bug finding; uses 1-day bugs as exploit-development practice.
- Time to first bug: about a year of having "a small handful of bugs" he could not trigger, until he realised a vendor tool reached the driver handlers. Source came from an accidentally included GPL archive.
- Paid: the MediaTek bounty program was the first real money; earlier web work paid mostly in recognition. Has PSIRT experience. Recruited by a teammate about a month before Pwn2Own.

### 5. Fabian Fäßler, "LiveOverflow" (educator / CTF; later security research)
- Sources: [I've been Hacking for 10 Years (Stripe CTF speedrun), transcript mirror](https://rosetta.to/u/liveoverflow/i-ve-been-hacking-for-10-years-stripe-ctf-speedrun); [Self-Learning Reverse Engineering in 2022, transcript mirror](https://rosetta.to/u/liveoverflow/self-learning-reverse-engineering-in-2022). Both T3 mirrors of T1 videos. verified: 2026-11-10.
- Degree: not stated (mentions high school coursework and self-taught PHP; do not infer).
- Order: coded through teenage years; planned a normal developer path; found CTFs in 2012 and learning "really accelerated". Stripe CTF levels 3 and 4 (array out-of-bounds, then buffer overflow) hooked him. In the 2016 series, basics of computers, programming and assembly came before memory corruption.
- Method advice: write small C programs, compile them, compare source to assembly; compare decompiler output; use Compiler Explorer; once you know one ISA, learn another by side-by-side with the first. Practice and time spent beat hunting for the best tutorial.
- Wish earlier / wasted: lesson that he should have checked mitigations before attempting an exploit on an old challenge (a present-day habit, cost time). Calls function prologue/stack-protector boilerplate low-yield when reading code for algorithm understanding.
- Time to first bug, first paid: not stated in these sources.
- Reads writeups selectively; his balance is "mostly solving CTFs" first.

### 6. Maddie Stone (firmware/Android, Google Project Zero)
- Source: [Darknet Diaries ep. 127 transcript](https://darknetdiaries.com/transcript/127/) (T2). verified: 2026-11-10.
- Degree: stated. Double major CS and Russian at Johns Hopkins; master's in CS done while working.
- Order: loved assembly (TA for the course and wrote independent-study projects); first job about 4.5 years reverse engineering firmware/hardware at a university applied physics lab; then Google Android security as a malware reverse engineer (later led a team); joined Project Zero July 2019 with little Windows/iOS/browser vulnerability experience ("a lot of learning").
- First Project Zero task: matched supplied details of an exploited Android bug to a single vulnerability, reported on a 7-day deadline, PoC with a colleague.
- Hardest: ramping up on unfamiliar platforms; heavy obfuscation and anti-analysis taking over a month. Regrets: none discussed.

### 7. Vera Mens (industrial control systems, Claroty Team82)
- Source: [Synack Readme post, first person](https://readme.synack.com/from-programmer-to-pwner-my-zero-day-journey-to-pwn2own) (T2, vendor-published personal essay). verified: 2026-11-10. Date not captured.
- Degree: stated, a computer science degree.
- Order: junior software engineer; attended an infosec conference; decided to move into vulnerability research with no hacking experience; left the job and studied full-time for about three and a half years before joining Team82. For Pwn2Own Miami she learned OPC UA from scratch and built a network fuzzer on a public fuzzing framework.
- Time to first bug: about 3.5 years from the decision to a research job; the first described bug was a fuzzer crash roughly seven months after joining, turned into a pre-auth RCE. Wish earlier, wasted: not stated (mentions weeks of fuzzing with little success and false positives).
- First paid: not stated (team Pwn2Own result is stated, not her first pay).

### 8. Natalie Silvanovich (mobile/media parsers, Google Project Zero)
- Source: [SecurityWeek interview](https://www.securityweek.com/researcher-conversations-natalie-silvanovich-from-googles-project-zero/) (T2). verified: 2026-11-10. (The USENIX ;login: PDF interview was fetched but is unreadable here; see Could not reach.)
- Degree: stated. Electrical Engineering at UBC; says she does not use much of it besides math that helped with image-processing algorithms in Adobe Flash.
- Order: computer interest first; a university co-op at BlackBerry (job titled "junior hacker") introduced her to security and taught her to program and about devices. Wish earlier / wasted / first-bug timing: not stated. First paid: that co-op. Credits conferences and conversations there for good ideas.

### 9. Alex Ionescu (Windows internals; senior engineering/research roles)
- Source: [SecurityWeek Hacker Conversations](https://www.securityweek.com/hacker-conversations-alex-ionescu/) (T2). verified: 2026-11-10.
- Degree: the article describes him as self-taught and mentions no formal education; do not infer degree status beyond that.
- Order: home computer from age four in Romania, tinkering, then meeting like-minded people on the internet and forums; hobby became full-time work. Advice: curiosity, patience, willingness to learn, hard work. Warns that chasing fame or money tends to disappoint. Wish earlier, wasted, first bug, first paid: not stated. Favourite research theme: "emergent design" (two sound technologies combining into a weakness).

### 10. Csaba Fitzl (macOS, Windows; trainer)
- Source: [SecureMac interview](https://www.securemac.com/interviews/csaba-fitzl-on-macos-bug-hunting-and-careers-in-cybersecurity) (T3, trade interview). verified: 2026-11-10.
- Degree: stated, computer engineering. Interest sparked by a friend's ethical-hacking certification; took a five-day intro course.
- Order: Cisco network support, then network engineer at a large energy company, about six years blue team, then red team, then course author for macOS exploitation. Learned macOS bug hunting as a Windows person by starting from one conference talk on dylib hijacking, then hunting that bug class, plus blogs, talks and an OS-internals book.
- Advice: build IT and programming foundation first; start with a broad offensive course then specialise. Wish earlier / wasted: not stated (notes specialisation costs work-life balance and he lost Windows depth).
- Pattern: bug-class-first hunting on a new platform.

### 11. Matthew Bryant (web/ecosystem bug bounty; self-described college dropout)
- Source: [HackerOne Hacker Q&A](https://www.hackerone.com/blog/hacker-qa-matthew-bryant-good-artists-copy-great-artists-steal) (T2/T3, platform-published). verified: 2026-11-10.
- Degree: self-described "a college dropout".
- Order: drawn by the "magic" of exploits working without understanding; learns by digging deep into something that catches his interest (e.g., reproducing a tweeted technique). Advice: start in security consulting, work closely with the most talented people you can find, study terms you do not understand after work, copy and study other hackers' approaches with credit.
- Wasted: says long research efforts can feel wasted and hunting can be discouraging. First-bug time and first paid: not stated.
- Target class is web/ecosystem, not native code; use as no-degree evidence only for that class.

### 12. Team accounts and single-project learners (supporting data, not full paths)
- Ophir Harpaz and Peleg Hadar, hypervisor fuzzing: [The Hacker Mind via Security Boulevard](https://securityboulevard.com/2021/08/the-hacker-mind-podcast-fuzzing-hyper-v) (T3). About six months from project start to first Hyper-V bug; first bug about two hours after the harness ran stably; the hard part was the harness and nested hypervisor setup. Education and first-paid not stated. verified: 2026-11-10.
- Crusaders of Rust (CTF team): [Will's Root, CVE-2022-0185 writeup](https://www.willsroot.io/2022/01/cve-2022-0185.html) (T1 researcher writeup). A CTF team already fluent in kernel heap exploitation bought servers and ran syzkaller from early 2022; first KASAN hit on 6 Jan, exploit "several days straight", post on 25 Jan. Same bug had been hit by a public fuzzer days earlier and unhandled, and another researcher had found it earlier: collision risk is real. verified: 2026-11-10.
- Faraz (kernel beginner, hobby): [kTLS n-day analysis](https://faith2dxy.xyz/2025-10-02/kCTF-TLS-nday-analysis/) (T3 personal blog, 2 Oct 2025). Started with zero kernel exploitation experience; chose analysing a patched kTLS bug from the patch commit; first PoC was the slowest stage; needed community hints for the exploit; advises analysing patched bugs, building a QEMU + custom kernel lab, asking the community. verified: 2026-11-10.
- Kyle Zeng (kernel, kCTF): [CVE-2022-1786 writeup](https://blog.kylebot.net/2022/10/16/CVE-2022-1786/) (T1 writeup, 16 Oct 2022). Already had two kCTF exploits and a published paper; local exploit in 2 days, then about 5 days debugging remote-only behaviour (freelist order differed, 5 minute reboots). Shows remote-vs-local environment gap as a time sink, not a learning path. verified: 2026-11-10.
- Marc-Oliver Munz (web bug bounty): [Intigriti spotlight](https://www.intigriti.com/researchers/blog/hacker-spotlight/from-curiosity-to-critical-bugs-interview-with-marc-oliver-munz-c1phy) (T3). About three months to first valid bug, after practice-platform time; commits 1 hour weekdays plus 2-4 hours weekends (comparable to OSVR's learner budget); advises focusing on one CMS or a couple of bug types. verified: 2026-11-10.
- Asem Eleraky (web/identity bug bounty): [MSRC blog, Feb 2026](https://www.microsoft.com/en-us/msrc/blog/2026/02/asem-eleraky-shared-family-pc-critical-vulnerabilities) (T1 vendor). Self-taught early; CTFs, public disclosure programmes then private bounties; first paid was a VDP finding that earned a private invite; advises depth on one application, logging every request, "first vulnerability is hardest". Degree: university computer engineering (stated). verified: 2026-11-10.
- Alex Plaskett: [Demystifying Security Research part 1](https://alexplaskett.github.io/demystifying-security-research-part1) (T1 researcher blog). No personal timeline; advice only: fundamentals (programming, networking, OS), background research before starting (talks, papers, bug trackers, source history), notes under version control, share early, long-term focus. Described as a "non-academic" researcher. verified: 2026-11-10.
- Interrupt Labs: [Getting into vulnerability research](https://interruptlabs.teamtailor.com/pages/getting-into-vulnerability-research) (employer, T3). No sequence; lists traits and skills hiring looks for (RE with debuggers/disassemblers, discovery and exploitation incl. mitigation bypass, programming) and publishes challenges to submit with applications. verified: 2026-11-10.

---

## Cross-person synthesis

### Sequencing patterns observed
1. **Programming and assembly foundation, then CTF memory corruption, then a real target** (Jacobi, LiveOverflow, Laulheret). Memory corruption comes after how-computers-work and C/assembly (LiveOverflow explicitly).
2. **Reverse-engineering job first, vulnerability research later** (Stone: firmware RE then malware then Project Zero; Mens: dev job then full-time study). The employed RE route is the dominant path for researchers who describe a job sequence.
3. **Platform entry via one bug class and one published technique** (Fitzl: one talk then dylib hijacking; Eleraky and Munz: one application or one CMS and a few bug types).
4. **Patch-first learning**: analysing a patched bug from its commit (Faraz advice; Plaskett's background-research advice). Hypr uses 1-days as exploit-writing practice.
5. **Fuzzing as the first-bug engine for teams** (Hyper-V pair; Crusaders of Rust with syzkaller). Both show the harness/environment, not the fuzzer, as the cost.
6. **Mentor or senior peers early** (Chompie's mentor, Bryant's "work with talented people", Faraz's community hints).

### Recurring advice
- Practice time on real material beats choosing the perfect resource (LiveOverflow, Jacobi on implementing vs reading).
- Do harder material earlier than feels comfortable (Jacobi).
- Compare your output to a reference (compiler vs decompiler output, LiveOverflow; writeups after CTFs, Jacobi).
- Build a debuggable environment before attacking a target (Hypr wants a full debugger; Faraz's QEMU setup; Kyle's remote/local divergence).
- Pick one narrow target and iterate (Munz, Eleraky, Fitzl).
- Share work and ask for feedback early (Plaskett, Faraz).
- Work close to better people (Bryant, Chompie).

### Disagreements
- **CTFs**: helpful foundation (Laulheret, Jacobi, LiveOverflow, Eleraky, Crusaders of Rust as team) versus real-world bugs teach more (Hypr). Not a true contradiction: all CTF-positive accounts use CTFs as the entry ramp; Hypr is speaking about skills after the ramp.
- **Bug finding vs exploit writing**: Hypr says they are different skill sets and writing exploits only for your own bugs means mostly learning bug finding; no one else addresses it.
- **Credentials**: Fitzl recommends a broad certified offensive course first; Bryant recommends consulting experience; Ionescu and others describe pure self-teaching; Interrupt Labs says no single path. No source in this file argues certifications are necessary for VR.
- **Duration framing**: Jacobi says a bit over a year from near-zero (as a teen with a CS programme), Mens says 3.5 years full-time before hired. Different endpoints (first RCE versus job).

### First-bug time by target class (anecdotes, not statistics)
| Class | Datum | Source |
|---|---|---|
| Web bug bounty | about 3 months to first valid finding at 1 h/weekday + weekend | Munz |
| Browser JIT | a little over a year from almost no security background to a first RCE in Edge | Jacobi abstract |
| Hypervisor (fuzzing) | about 6 months for a project, bug 2 h after stable harness | Harpaz/Hadar |
| Linux kernel (fuzzing) | days after syzkaller started, but team had prior kernel exploit skill; duplicate collision | Will's Root |
| Linux kernel (beginner, n-day) | no timing; first PoC slowest, exploit needed community hint | Faraz |
| Embedded router/driver | about a year with unexploitable bugs before triggering them | Hypr |
| ICS network protocol | fuzzer crash about 7 months after joining a research team; 3.5 years of solo study before that | Mens |

### Gaps
- Regrets: almost nobody states any. The closest are habit-level lessons (check mitigations first; set deadlines; do not wait on 10-15 unexploited bugs).
- Wasted time: stated items are mostly environment pain (reboot loops, remote debugging), not wrong topics. No fetched source names a topic as a waste except LiveOverflow's note on reading boilerplate.
- First-paid: paths are internships (Jacobi, Silvanovich), employer research roles (Stone, Chompie), or bounty money (Hypr, Eleraky). No one reports being paid for exploit development before having a first public bug or job.

---

## Implications for OSVR
Suggestions for the architect to accept or reject.

1. **Gate "exploit" work behind an implement-it check, not a read-it check.** Jacobi found implementing a textbook overflow much harder than understanding it; LiveOverflow says practice time dominates. Every early BX module should require building the primitive from a blank file.
2. **Keep CTF-style challenges as the entry ramp, but label them as such and move to real targets early.** Four sources credit CTFs; Hypr says real bugs teach what CTFs do not. Suggest a ramp-then-real structure with an explicit exit criterion from the ramp.
3. **Add an n-day / patch-analysis module before the first 0-day attempt, and a lab-environment module (QEMU kernel build, debugger, remote-vs-local parity).** Faraz and Plaskett recommend patch-first; Kyle Zeng and Hypr show environment parity and debuggability absorb days.
4. **Plan realistic first-bug timelines by class in learner communications.** Web: months; hypervisor/kernel fuzzing: about six months with a working harness; browser JIT: more than a year; ICS: 3.5 years of study before being hired in one account. At 10 h/week this implies a first-0-day milestone in tens of weeks for the easiest classes, and track MAPs should say so. Flag as needs more sources.
5. **Teach duplicate/collision risk and the disclosure side early.** The CVE-2022-0185 case shows two independent finders and a fuzzer hit that nobody triaged.
6. **Teach bug-finding and exploit-writing as separate drillable skills** (Hypr). Use 1-days for exploit practice and a separate drill set for finding bugs.
7. **Mentor/community mechanic**: three accounts credit a mentor, talented peers or Discord hints. Add a public-feedback step (writeup review, community channel) to project.md files.
8. **Hedge on the no-degree evidence.** The only self-described dropout here (Bryant) is web; Ionescu is described as self-taught without degree status given. Do not market OSVR with the claim that no-degree native-code VR careers are well documented until more sources are found (see below).
9. **Do not rely on certification courses** as spine: no fetched source argues they are required (Fitzl suggests one only as a broad start).
10. **AI-era note**: Chompie reports AI agents fail at hard exploit work without expert-authored methodology; a module on writing bug-class skills/checkers is plausible. Single source, 2026-06; needs more evidence.

## Open questions / conflicting sources
- Need first-person accounts from more native-code researchers who state they have no degree (candidates not yet fetched: other Hacker Conversations profiles, conference-talk bios).
- Need Project Zero / OffensiveCon-style retrospectives with explicit regrets.
- Need one browser-exploitation and one macOS/iOS learner path with hour counts.
- The Jacobi time-to-RCE figure comes from the talk abstract; the interview mirror does not add detail.

## Could not reach (verified: null, status: unverified)
- Larry Cashdollar, CVE.org "My CVE Story" (2021): URL `CVE.MITRE.org/blog/March152021_My_CVE_Story...` redirected to the archived old site index; article text not retrieved. Search snippet only; not used above.
- MalwareTech, "Infosec Without a Degree" `malwaretech.com/2016/05/infosec-without-degree.html`: HTTP 403; web.archive.org blocked by tool. Highly relevant to no-degree; fetch manually.
- Natalie Silvanovich, USENIX ;login: summer 2020 interview PDF: fetched but binary; text not extractable here (no PDF tools). Saved copy: `/home/miguel/.claude/projects/-home-miguel-Repos-osvr/a28ace43-37bc-48d3-a261-9a2ce487b821/tool-results/webfetch-1794344375568-mg4wpv.pdf`. Fetch manually.
- HITCON 2025 slides "Compromising Linux the Right Way": binary PDF; speaker and content not extracted. Saved copy under the same tool-results directory (`webfetch-1794344522641-cdz3aq.pdf`).
- 35C3 "Layman's Guide to Zero-Day Engineering" subtitle file (amara.org): HTTP 403.
- Dark Reading "Lessons from My Strange Journey into InfoSec": HTTP 403.
- Yahoo article on Microsoft's youngest researcher "Dylan": HTTP 403; "nine months of self-study" appears only in a search snippet. Unverified.
- Guided Hacking podcast with a vulnerability researcher (SoundCloud): not fetched.
- Azeria Labs about page fetched but contains no learning-path statements (not an entry).
- Reddit r/ExploitDev threads and Hacker News threads: seen in search only, not fetched.

## Sources (all fetched 2026-11-10 unless in "Could not reach")
Fetched and used:
- https://rosetta.to/u/liveoverflow/from-zero-to-zero-day-and-beyond-life-of-a-hacker-jonathan-jacobi
- https://media.ccc.de/v/35c3-9657-from_zero_to_zero_day
- https://www.ibm.com/think/x-force/question-answer-valentina-palmiotti-chompie
- https://www.thecyberwire.com/podcasts/ai-security-brief/5/transcript
- https://blog.talosintelligence.com/breaking-things-to-keep-them-safe-with-philippe-laulheret/
- https://www.criticalthinkingpodcast.io/episode-157-crushing-pwn2own-h1-with-kernel-driver-exploits/
- https://rosetta.to/u/liveoverflow/i-ve-been-hacking-for-10-years-stripe-ctf-speedrun
- https://rosetta.to/u/liveoverflow/self-learning-reverse-engineering-in-2022
- https://darknetdiaries.com/transcript/127/
- https://readme.synack.com/from-programmer-to-pwner-my-zero-day-journey-to-pwn2own
- https://www.securityweek.com/researcher-conversations-natalie-silvanovich-from-googles-project-zero/
- https://www.securityweek.com/hacker-conversations-alex-ionescu/
- https://www.securemac.com/interviews/csaba-fitzl-on-macos-bug-hunting-and-careers-in-cybersecurity
- https://www.hackerone.com/blog/hacker-qa-matthew-bryant-good-artists-copy-great-artists-steal
- https://securityboulevard.com/2021/08/the-hacker-mind-podcast-fuzzing-hyper-v
- https://www.willsroot.io/2022/01/cve-2022-0185.html
- https://faith2dxy.xyz/2025-10-02/kCTF-TLS-nday-analysis/
- https://blog.kylebot.net/2022/10/16/CVE-2022-1786/
- https://www.intigriti.com/researchers/blog/hacker-spotlight/from-curiosity-to-critical-bugs-interview-with-marc-oliver-munz-c1phy
- https://www.microsoft.com/en-us/msrc/blog/2026/02/asem-eleraky-shared-family-pc-critical-vulnerabilities
- https://alexplaskett.github.io/demystifying-security-research-part1
- https://interruptlabs.teamtailor.com/pages/getting-into-vulnerability-research

Fetched, not used for claims (no relevant content): connormcgarr.github.io (index only), kawaiicon.org talk page, citation.thinkst.com talk 90548, c2dragon.github.io/posts/ZDW1, darknetdiaries.com/transcript/158/ (MalwareTech episode, no exploitation-learning content), training.azeria-labs.com/about.html.
