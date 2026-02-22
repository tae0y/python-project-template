Use Agent Teams with 4 teammates to review `.claude/rules/coding-guidelines.md` over 3 rounds.
Set --max-turns 15 for each teammate.

**Context:** There are two distinct documents to compare:

1. **Original Thinking Guidelines** — 5 sections focused on reasoning and communication style (decompose before answering, apply multiple personas, stay concise, follow-up suggestions, affirmative by default). This governed *how to think and respond*.

2. **Current Coding Guidelines** — inherits sections 1–4 in adapted form, then adds sections 5–10 as concrete tool/process rules (use real interfaces, diagnose before fixing, no indirect solutions, verify external constraints, secrets hygiene, pre-commit quality gate). This governs *how to write and commit code*.

The user observes that response quality degraded after this evolution. The team has **two parallel questions** to answer:
- Q1: Did the expansion of coding-guidelines.md (sections 6–10) cause quality degradation, and if so, how?
- Q2: The original Thinking Guidelines no longer exists as a rule file. Should it be restored? Does its absence explain part of the quality gap?

Before starting, all teammates must read:
- `.claude/rules/thinking-guidelines.md` (original document — the baseline for comparison)
- `.claude/rules/coding-guidelines.md` (current document — the subject of review)
- `.claude/rules/` (all other rule files — understand the full rule set)
- `.claude/WORKFLOW.md` (understand how rules are applied)
- `CLAUDE.md` (understand the project's stated communication style and architecture)

Reference text — the original thinking-guidelines document:
- `.claude/rules/thinking-guidelines.md` (read this file before starting)

---

Teammates:

1. **Original Intent Guardian** — owns Q2. Argues from the thinking-guidelines perspective: which principles from the original are missing or diluted in the current file? Assesses whether restoring a separate thinking-guidelines rule file would close the quality gap. Points out which current sections are redundant with other rule files.

2. **Cognitive Load Analyst** — owns Q1. Measures both documents from the model's perspective. Flags rules that are too long to hold in working context, rules that conflict with each other, and rules that require external lookup to apply. Assesses whether the combined length of current coding-guidelines is the primary failure mode.

3. **Token CFO** — challenges every proposed addition or restoration with ROI: does this rule prevent real observed failures, or is it speculative armor? Pushes for deletion over retention. Must challenge Original Intent Guardian if they argue for restoring thinking-guidelines without evidence it was responsible for the quality gap.

4. **Onboarding New Member** — reads both documents as a first-timer. For the original thinking-guidelines: "Would these make me respond better?" For the current coding-guidelines: "Do I know what to do in every situation these describe?" Flags top 3 gaps — things neither document covers that a new member would get wrong.

---

Round 1: Each teammate posts independent analysis to the shared task list.
- Original Intent Guardian (Q2): which principles in thinking-guidelines are absent from the current rules/ directory? Verdict per principle: missing / present but diluted / fully covered elsewhere.
- Cognitive Load Analyst (Q1): score coding-guidelines sections 1–10 for cognitive load (1=lightweight, 5=heavy). Identify which sections, if any, suppress the reasoning behaviors the thinking-guidelines were trying to activate.
- Token CFO: for each section 6–10 in coding-guidelines, verdict: keep / cut / move to separate file. Separately: verdict on restoring thinking-guidelines as a rule file — justified or nostalgia?
- New Member: top 3 gaps neither document covers. Top 2 contradictions between the two documents.

Round 2: Teammates respond directly to each other.
- Token CFO must challenge Original Intent Guardian: is the quality gap caused by the *absence* of thinking-guidelines, or by the *presence* of too many coding rules? These are different fixes.
- Cognitive Load Analyst must respond to New Member's gap findings: are the gaps real coverage holes, or already implicit in existing rules?
- Original Intent Guardian must respond to Token CFO's verdict on restoration: what is the concrete evidence that thinking-guidelines improved response quality when it existed?

Round 3: Converge. Each teammate proposes exactly one highest-priority change. Resolve conflicts through direct messaging.

---

Final output: Lead synthesizes findings and saves the full report to `localdocs/review-guidelines-YYYYMMDD.md` (use today's date).

The report must include:
- **Q1 verdict**: did the expansion of coding-guidelines.md (sections 6–10) degrade response quality? State the mechanism, not just yes/no.
- **Q2 verdict**: should thinking-guidelines be restored as a separate rule file? What specific behaviors does its absence explain?
- **Root cause**: if both Q1 and Q2 are contributing factors, which is primary?
- Prioritized action list (with owner persona per item)
- Recommended final structure: what stays in coding-guidelines.md, what belongs in a restored thinking-guidelines.md, what moves elsewhere, what gets cut entirely
- Unresolved disagreements with explicit trade-off statements
- One-paragraph verdict: does the current rule set help or hinder this developer's workflow?
