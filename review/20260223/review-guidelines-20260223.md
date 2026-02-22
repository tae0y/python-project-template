# Guidelines Review Report — 2026-02-23

**Team**: guidelines-review (4 personas)
**Subject**: `.claude/rules/coding-guidelines.md` vs. original `.claude/rules/thinking-guidelines.md`
**Q1**: Did expansion of sections 6–10 degrade response quality?
**Q2**: Should thinking-guidelines be restored as a separate rule file?

---

## Round 1 — Independent Analysis

### Original Intent Guardian (Q2)

Verdict per principle in thinking-guidelines:

| # | Principle | Status | Evidence |
|---|-----------|--------|----------|
| 1 | Decompose Before Answering | PRESENT BUT DILUTED | coding-guidelines §1 covers "state assumptions" in code context only. The broader decomposition — separating facts vs. assumptions vs. preferences across all response types — is absent. "Verify material facts via search" is missing entirely. |
| 2 | Apply Multiple Personas | MISSING | Not in any file under `.claude/rules/`. CLAUDE.md has one echo ("Frame conclusions affirmatively") but the protocol — choose 2+ labeled personas, surface disagreement explicitly — is gone. |
| 3 | Stay Concise and Direct | PRESENT BUT DILUTED | CLAUDE.md covers Korean/concise/conclusion-first. Missing: "use plain text by default; avoid headings unless requested." In practice, responses now use headers and lists unprompted. |
| 4 | Follow-Up Suggestions | MISSING | Completely absent from all rule files and CLAUDE.md. Neither document says anything about how to close a response with scannable options. |
| 5 | Affirmative by Default | PRESENT BUT DILUTED | CLAUDE.md covers "It is B" framing. Missing: "avoid strawman framing" and "reinforce with supporting cases after asserting." |

**Round 1 Verdict (Q2)**: Yes, restore thinking-guidelines. The two MISSING principles (§2 Apply Multiple Personas, §4 Follow-Up Suggestions) are precisely the ones that make responses feel analytical rather than merely compliant. Their absence is structural, not incidental.

---

### Cognitive Load Analyst (Q1)

Cognitive load scores per section (1=lightweight, 5=heavy):

| Section | Title | Score | Reason |
|---------|-------|-------|--------|
| §1 | Think Before Coding | 2 | 4 short bullets, single decision mode |
| §2 | Simplicity First | 2 | Negative rules ("no X"), easy self-check |
| §3 | Surgical Changes | 3 | Two sub-scenarios (editing / orphans); requires tracking scope |
| §4 | Goal-Driven Execution | 3 | Introduces plan format; medium; verifiable |
| §5 | Use the Real Interface | 4 | Three distinct scenarios (deps / scripts / tests); tool-specific (`uv`); requires knowing the toolchain |
| §6 | Diagnose Before Fixing | 2 | Simple 3-step protocol; lightweight |
| §7 | No Indirect Solutions | 4 | Embeds specific anti-patterns (env vars at module load, Docker Compose defaults); requires deep implementation context |
| §8 | Verify External Constraints | 3 | Calls for external tool lookup on every integration; adds async lookup step |
| §9 | Secrets and Domain Hygiene | 3 | Concrete checklist but requires knowing "DDNS hostname" domain |
| §10 | Pre-Commit Quality Gate | 2 | Linear 3-step process; lowest abstraction |

**Total weighted load**: sections 5 and 7 are the heaviest and both encode project-specific tool knowledge rather than general behavioral heuristics.

**Suppression effect**: Do any sections suppress thinking-guidelines' reasoning behaviors?

- §7 ("take the direct path") conflicts with §2 Apply Multiple Personas. Multi-persona analysis requires exploring multiple approaches. "Direct path" kills that exploration.
- §8 (external lookup required) redirects cognitive resources away from internal reasoning toward tool invocation.
- Cumulative saturation: ~800 words of behavioral rules in coding-guidelines alone. Combined with CLAUDE.md + commit-convention + document-management ≈ 1500+ words at session start. This leaves less working context for reasoning patterns.

**Q1 Verdict**: Length is NOT the primary failure mode. The failure mode is **checklisting displacement** — specific procedural rules (`uv add`, run `check`, verify external docs) train the model to operate in compliance/checklist mode, which actively suppresses exploratory multi-perspective reasoning. Length amplifies this effect but does not cause it alone.

---

### Token CFO (Sections 6–10 ROI)

| Section | Verdict | Rationale |
|---------|---------|-----------|
| §6 Diagnose Before Fixing | **KEEP** | Common, observed LLM failure pattern. High ROI: prevents "fix by guess" commits. |
| §7 No Indirect Solutions | **KEEP but TRIM** | Core principle is valid. But env-var and Docker Compose specifics are project-level implementation details, not behavioral heuristics. Move examples to a project-specific ops doc. |
| §8 Verify External Constraints | **KEEP but TRIM** | Principle valid; specific tool names (context7, microsoft-learn) will age. Keep the principle, remove tool names. |
| §9 Secrets and Domain Hygiene | **MOVE TO SEPARATE FILE** | This is ops/security hygiene, not a reasoning behavioral guideline. Belongs in a pre-commit checklist or security doc (or WORKFLOW.md §C). |
| §10 Pre-Commit Quality Gate | **MOVE TO SEPARATE FILE** | Pure process rule. WORKFLOW.md already references it (§C, "check + auto-fix"). Duplication. Move there and delete from coding-guidelines. |

**Verdict on restoring thinking-guidelines**: Conditional KEEP. Restoring thinking-guidelines while keeping all 10 coding sections adds to total load. The correct sequence: first trim coding-guidelines (remove §9, §10, trim §7 and §8), then restore a pruned thinking-guidelines (3 sections max). Net effect: fewer total words, higher reasoning density.

**Challenge to Original Intent Guardian (Round 2 preview)**: Absence of thinking-guidelines may not be the primary cause of quality degradation. The question is: did the MODEL's behavior change because a file was removed, or because a file full of checklists was ADDED? These require different fixes.

---

### New Member (Gaps and Contradictions)

**Top 3 Gaps** — things neither document covers:

1. **Rule conflict resolution**: coding-guidelines §1 says "if unclear, stop and ask." coding-guidelines §7 says "take the direct path." When a task is ambiguous AND a direct path exists, which wins? Neither doc provides a tiebreaker. A new member either asks too much (annoying) or acts without confirming (risky).

2. **Non-code response scope**: coding-guidelines is explicitly for code. thinking-guidelines covered all responses. For a conceptual/architectural question (no code produced), which rules apply? Currently: CLAUDE.md alone. The analytical protocol (multi-persona, decompose, follow-up suggestions) has no active rule file.

3. **Persona activation threshold**: thinking-guidelines §2 says "choose 2+ personas appropriate to the request" but gives no trigger criteria — no guidance on WHEN the request warrants multi-persona vs. a direct answer. New member either over-applies (every response becomes a debate) or under-applies (never surfaces disagreement).

**Top 2 Contradictions**:

1. **Conciseness vs. Plan format**: coding-guidelines §4 requires a structured multi-step plan with "→ verify:" tags. thinking-guidelines §3 says "use plain text by default; avoid headings/separators/lists unless requested." The plan format IS structured output. Direct contradiction — neither doc resolves the precedence.

2. **Ask vs. Act**: coding-guidelines §1 ("stop, name confusion, ask") vs. §7 ("take the direct path, do not deviate without explaining why"). These pull in opposite directions on ambiguous tasks.

**Readability verdict**: coding-guidelines is navigable for code tasks but opaque for non-code responses. thinking-guidelines was more useful for onboarding because it addressed the foundational question: "how do I respond in this project?" coding-guidelines assumes that answer is already known and adds constraints on top.

---

## Round 2 — Cross-Examination

### Token CFO challenges Original Intent Guardian

> "The quality gap is caused by TOO MANY coding rules suppressing reasoning, NOT by the absence of thinking-guidelines. These are different diagnoses requiring different fixes."

**Original Intent Guardian response**: Acknowledged — I cannot produce session logs showing responses were better when thinking-guidelines existed as a file. The direct causal claim is unverifiable.

What I can argue structurally: the two MISSING principles (Apply Multiple Personas, Follow-Up Suggestions) are not covered by any existing rule. Even if you trimmed coding-guidelines to 5 sections, those behaviors would still not be activated without explicit instruction. Trimming alone fixes the suppression problem; it does not restore the missing behaviors. Both fixes are necessary — they address different deficiencies.

**Token CFO counter**: Accepted partially. The restoration is justified IF trimming happens first. Restoring thinking-guidelines before trimming coding-guidelines makes the combined rule set worse, not better.

**Resolution**: Trim first, restore second. The restoration is conditional on the trim.

---

### Cognitive Load Analyst responds to New Member's gaps

**Gap 1 (Rule conflict resolution)**: Real gap, not covered implicitly. coding-guidelines has no meta-rule about rule priority. This gap causes concrete behavioral ambiguity.

**Gap 2 (Non-code response scope)**: Real gap. CLAUDE.md fills it partially but incompletely. The analytical protocols (multi-persona, decompose) that should apply to all responses exist only in thinking-guidelines, which is now absent.

**Gap 3 (Persona activation threshold)**: Real gap, but a nuanced one. The original thinking-guidelines also didn't specify a threshold — it said "for each response." This was actually the original intent (always apply), but it's unrealistic in practice. The real issue is that without the rule at all, the behavior never activates.

**Summary**: All 3 gaps are genuine. None are covered implicitly.

---

## Round 3 — Highest-Priority Proposals (One Per Persona)

| Persona | Proposal |
|---------|---------|
| **Original Intent Guardian** | Restore `thinking-guidelines.md` with exactly 3 sections: §1 Decompose Before Answering, §2 Apply Multiple Personas, §4 Follow-Up Suggestions. (§3 Concise/Direct and §5 Affirmative are already partially in CLAUDE.md — no duplication needed.) |
| **Cognitive Load Analyst** | Move §9 (Secrets) and §10 (Pre-Commit) out of coding-guidelines into WORKFLOW.md §C. This removes 2 heavy-ish sections without losing any rule, drops total word count ~20%, and reduces saturation. |
| **Token CFO** | Trim §7 (No Indirect Solutions) to its core sentence: "Take the direct path. If you must deviate, say so and get approval first." Remove the Python env-var and Docker Compose implementation examples — they belong in project-specific docs, not behavioral guidelines. |
| **New Member** | Add a 3-line "Rule Hierarchy" note to CLAUDE.md: "For non-code responses: thinking-guidelines > CLAUDE.md. For code tasks: coding-guidelines > CLAUDE.md. When rules conflict, prefer thinking over acting." |

**Resolved conflicts**: All four proposals are additive-compatible (no two proposals contradict each other). Recommended execution order: Token CFO → Cognitive Load Analyst → Original Intent Guardian → New Member.

---

## Final Synthesis

### Q1 Verdict

**Did sections 6–10 degrade response quality? Yes — mechanism: checklisting displacement.**

The addition of procedural, tool-specific rules (§5 `uv add`, §7 env-var anti-patterns, §8 external lookup, §9 commit scan, §10 quality gate) shifts the model's operating mode from _exploratory reasoner_ to _checklist executor_. The model follows the checklist and forgets to do the broader cognitive work — decomposing assumptions, surfacing alternatives, offering follow-up options. Length amplifies this effect but is secondary. The primary mechanism is the cognitive frame shift: "compliance with specific procedures" overrides "analytical exploration."

Sections 6 (Diagnose Before Fixing) and 8 (Verify External Constraints) individually have good ROI. The problem is sections 7, 9, and 10 which encode project-specific implementation details as behavioral heuristics — a category error that bloats the document and deepens the checklist framing.

### Q2 Verdict

**Should thinking-guidelines be restored? Yes — partially. Conditional on trimming first.**

Two principles are MISSING from all current rule files:
- **Apply Multiple Personas** — the mechanism that differentiates analytical responses from compliant ones. Without it, the model produces direct answers but never surfaces trade-offs or disagreements.
- **Follow-Up Suggestions** — the mechanism that keeps the user in control by presenting options. Without it, responses terminate without next-step scaffolding.

The absence of thinking-guidelines explains why responses feel like code reviews rather than collaborative analysis. These behaviors do not activate from CLAUDE.md alone.

Restoration is not nostalgia. But restoring a full 5-section thinking-guidelines while keeping a 10-section coding-guidelines would be worse than the current state. The trim must happen first.

### Root Cause

Both Q1 and Q2 contribute. **Q1 is primary**: the checklisting displacement actively suppresses the reasoning behaviors. **Q2 is secondary**: even without the suppression, the missing Multi-Persona and Follow-Up Suggestions behaviors would not activate without explicit instruction.

The failure is a compound one: the document that taught reasoning was removed, and the document that replaced it progressively trained away from reasoning.

---

## Prioritized Action List

| Priority | Action | Owner Persona | Type |
|----------|--------|---------------|------|
| 1 | Move §9 (Secrets) and §10 (Pre-Commit) out of `coding-guidelines.md` → `WORKFLOW.md` §C | Cognitive Load Analyst | Trim |
| 2 | Trim §7 to core sentence only; remove env-var/Docker examples | Token CFO | Trim |
| 3 | Trim §8 to principle only; remove specific tool names | Token CFO | Trim |
| 4 | Restore `thinking-guidelines.md` with 3 sections: §1 Decompose, §2 Apply Multiple Personas, §4 Follow-Up Suggestions | Original Intent Guardian | Restore |
| 5 | Add "Rule Hierarchy" note (3 lines) to `CLAUDE.md` | New Member | Clarify |
| 6 | Add activation threshold to restored thinking-guidelines §2: "Apply when task involves trade-offs, competing approaches, or subjective judgment" | New Member | Clarify |

---

## Recommended Final Structure

### `thinking-guidelines.md` (restored, 3 sections)
- §1 Decompose Before Answering
- §2 Apply Multiple Personas *(with added activation threshold)*
- §3 Follow-Up Suggestions

*Remove: §3 Concise/Direct (covered in CLAUDE.md), §5 Affirmative by Default (covered in CLAUDE.md)*

### `coding-guidelines.md` (trimmed to 8 sections)
- §1 Think Before Coding
- §2 Simplicity First
- §3 Surgical Changes
- §4 Goal-Driven Execution
- §5 Use the Real Interface, Not a Shortcut
- §6 Diagnose Before Fixing
- §7 No Indirect Solutions *(core principle only, examples removed)*
- §8 Verify External Constraints *(principle only, tool names removed)*

*Remove: §9, §10 (moved to WORKFLOW.md)*

### `WORKFLOW.md` (additions to §C)
- §9 Secrets and Domain Hygiene *(moved from coding-guidelines)*
- §10 Pre-Commit Quality Gate *(moved from coding-guidelines; already referenced here)*

### `CLAUDE.md` (minor addition)
- Add 3-line Rule Hierarchy note after communication style section

---

## Unresolved Disagreements

1. **Restore timing**: Original Intent Guardian argues restore immediately; Token CFO argues trim first. Resolution attempted: trim → restore is the agreed sequence. But if the user restores without trimming, total rule count increases. **Trade-off**: restore now risks higher saturation; delay loses the behavioral activation while the trim PR is in review.

2. **§5 Use the Real Interface scope**: Token CFO says §5's tool-specific content (uv commands) also belongs in a project doc, not behavioral guidelines. Original Intent Guardian argues §5's core principle ("same result via a different path is not equivalent") is a genuine reasoning rule worth keeping as a behavioral heuristic. **Trade-off**: keep in coding-guidelines loses generality; move to project docs loses visibility.

---

## One-Paragraph Verdict

The current rule set **hinders** this developer's workflow. The coding-guidelines document has grown from a reasoning primer into a compliance manual — it tells the model what commands to run and what patterns to avoid, but the document that taught the model *how to think and respond* (thinking-guidelines) was removed without replacement. The result is a model that runs `uv add` correctly and checks for secrets, but responds to architectural questions with a single direct answer and no trade-off analysis, never surfaces disagreement, and closes conversations without next-step scaffolding. The fix is not to revert the coding-guidelines expansion entirely — sections 6, 7, and 8 address real failure patterns — but to trim the implementation-specific content out of sections 7 and 8, relocate the purely procedural sections 9 and 10 to WORKFLOW.md where they belong, and restore a minimal (3-section) thinking-guidelines that reactivates the reasoning behaviors the current rule set has trained away.
