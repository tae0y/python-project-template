---
name: prd
description: Generate high-quality Product Requirements Documents (PRDs) for software systems and AI-powered features. Includes executive summaries, user stories, technical specifications, and risk analysis.
argument-hint: "product-or-feature-name"
---

# Product Requirements Document (PRD)

## Overview

Design comprehensive, production-grade Product Requirements Documents (PRDs) that bridge the gap between business vision and technical execution. This skill works for modern software systems, ensuring that requirements are clearly defined.

## When to Use

Use this skill when:

- Starting a new product or feature development cycle
- Translating a vague idea into a concrete technical specification
- Defining requirements for AI-powered features
- Stakeholders need a unified "source of truth" for project scope
- User asks to "write a PRD", "document requirements", or "plan a feature"

---

## Operational Workflow

### Phase 1: Deep Discovery (The Interview)

Before writing a single line of the PRD, you **MUST** conduct an in-depth, multi-round interview with the user using `AskUserQuestion`. Do not assume context. Do not settle for surface-level answers.

**Interview Protocol:**

1. **Start broad, then drill deep.** Begin with the core problem, then follow each answer with probing follow-ups that surface hidden assumptions, edge cases, and trade-offs.
2. **Ask non-obvious questions.** Avoid generic checklist questions. Tailor each question to what the user just said. Challenge vague or contradictory statements.
3. **Continue until saturation.** Keep interviewing until no new information emerges. Minimum 3 rounds of questions — more if the domain is complex or ambiguous.
4. **Surface gray zones explicitly.** For every major feature or requirement, ask: "What happens when [unexpected scenario]?" and "What should we NOT do here?"

**Interview Dimensions (cover all that apply):**

- **The Core Problem**: Why now? What happens if we don't build this? Who suffers most?
- **Success Metrics**: How do we know it worked? What's the minimum bar vs. aspirational target?
- **User Context**: Who are the actual users? What are their current workarounds? What will frustrate them?
- **Scope Boundaries**: What's explicitly out of scope? What adjacent features will users expect but we won't deliver?
- **Edge Cases & Failure Modes**: What inputs or states break the happy path? What does graceful degradation look like?
- **Trade-offs**: Speed vs. accuracy? Flexibility vs. simplicity? Build vs. buy?
- **Constraints**: Budget, tech stack, timeline, team size, compliance requirements?
- **Dependencies & Integration**: What existing systems does this touch? Who else needs to agree?
- **Evolution**: How might requirements change in 3-6 months? What's the most likely pivot?

**Anti-Patterns for Discovery:**

- ❌ Asking all questions in one giant batch (overwhelms the user, loses follow-up depth)
- ❌ Accepting "it should be fast" or "it should be easy" without pressing for numbers
- ❌ Skipping edge cases because the user didn't mention them
- ❌ Moving to Phase 2 before the user confirms "I think that covers it"

### Phase 2: Analysis & Scoping

Synthesize the user's input. Identify dependencies and hidden complexities.

- Map out the **User Flow**.
- Define **Non-Goals** to protect the timeline.

### Phase 3: Technical Drafting

Generate the document using the **Strict PRD Schema** below.

---

## PRD Quality Standards

### Requirements Quality

Use concrete, measurable criteria. Avoid "fast", "easy", or "intuitive".

```diff
# Vague (BAD)
- The search should be fast and return relevant results.
- The UI must look modern and be easy to use.

# Concrete (GOOD)
+ The search must return results within 200ms for a 10k record dataset.
+ The search algorithm must achieve >= 85% Precision@10 in benchmark evals.
+ The UI must follow the 'Vercel/Next.js' design system and achieve 100% Lighthouse Accessibility score.
```

---

## Strict PRD Schema

You **MUST** follow this exact structure for the output:

### 1. Executive Summary

- **Problem Statement**: 1-2 sentences on the pain point.
- **Proposed Solution**: 1-2 sentences on the fix.
- **Success Criteria**: 3-5 measurable KPIs.

### 2. User Experience & Functionality

- **User Personas**: Who is this for?
- **User Stories**: `As a [user], I want to [action] so that [benefit].`
- **Acceptance Criteria**: Bulleted list of "Done" definitions for each story.
- **Non-Goals**: What are we NOT building?

### 3. AI System Requirements (If Applicable)

- **Tool Requirements**: What tools and APIs are needed?
- **Evaluation Strategy**: How to measure output quality and accuracy.

### 4. Technical Specifications

- **Architecture Overview**: Data flow and component interaction.
- **Integration Points**: APIs, DBs, and Auth.
- **Security & Privacy**: Data handling and compliance.

### 5. Risks & Roadmap

- **Phased Rollout**: MVP -> v1.1 -> v2.0.
- **Technical Risks**: Latency, cost, or dependency failures.

---

## Implementation Guidelines

### DO (Always)

- **Define Testing**: For AI systems, specify how to test and validate output quality.
- **Iterate**: Present a draft and ask for feedback on specific sections.

### DON'T (Avoid)

- **Skip Discovery**: Never write a PRD without asking at least 2 clarifying questions first.
- **Hallucinate Constraints**: If the user didn't specify a tech stack, ask or label it as `TBD`.

---

## Example: Intelligent Search System

### 1. Executive Summary

**Problem**: Users struggle to find specific documentation snippets in massive repositories.
**Solution**: An intelligent search system that provides direct answers with source citations.
**Success**:

- Reduce search time by 50%.
- Citation accuracy >= 95%.

### 2. User Stories

- **Story**: As a developer, I want to ask natural language questions so I don't have to guess keywords.
- **AC**:
  - Supports multi-turn clarification.
  - Returns code blocks with "Copy" button.

### 3. AI System Architecture

- **Tools Required**: `codesearch`, `grep`, `webfetch`.

### 4. Evaluation

- **Benchmark**: Test with 50 common developer questions.
- **Pass Rate**: 90% must match expected citations.
