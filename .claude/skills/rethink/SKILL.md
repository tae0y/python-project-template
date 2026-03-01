---
name: rethink
description: Break out of a stuck approach by reframing a technical problem through structured thinking frameworks. Use when blocked, going in circles, or when a fresh perspective is needed on architecture, design, or debugging.
user_invocable: true
---

# Rethink — Structured Reframing for Technical Problems

When you're stuck on a technical problem, apply two of the four frameworks below to generate alternative approaches. The goal is to break fixed thinking patterns and surface options you haven't considered.

## Triggers

Use this skill when:
- An approach has failed 2+ times
- You're going in circles on a design decision
- The "obvious" solution feels wrong or overly complex
- You need to evaluate fundamentally different architectures
- Debugging has stalled and root cause is unclear

## Process

### Step 1: State the Problem Clearly

Write one sentence describing what you're trying to achieve and what's blocking you.

```
Problem: [What I want to achieve]
Blocker: [What's preventing it]
Attempts so far: [What I've already tried]
```

### Step 2: Select Two Frameworks

Choose the two most relevant frameworks from below and apply them to the problem.

### Step 3: Generate Alternatives

Produce 3-5 concrete, actionable alternative approaches. Each must include:
- **Approach**: One-sentence description
- **Mechanism**: How it solves the blocker
- **Trade-off**: What you give up
- **First step**: The immediate next action to try

---

## Framework 1: Problem Redefinition (관점 전환)

Rotate the problem to see it from a different angle.

**Techniques:**
- **Invert** (180°): What if the opposite is the real problem? ("Can't make it fast" → "Why does it need to be fast?")
- **Zoom out** (10x): What problem does THIS problem live inside? Is there a higher-level solution?
- **Zoom in** (0.1x): Which specific sub-part is actually broken? Isolate the exact failure point.
- **Domain shift**: How would a different field solve this? (Database problem → think like a filesystem. UI problem → think like a CLI.)
- **Time shift**: How would this be solved if performance/storage/bandwidth were unlimited? What if it had to work on a 1990s machine?

**Output**: Restate the problem in at least two alternative formulations before generating solutions.

---

## Framework 2: Cross-Domain Connection (연결 탐색)

Find solutions by connecting to patterns from other domains.

**Process:**
1. **Direct analogy**: What existing system solves a structurally similar problem? (e.g., event sourcing ↔ git history, circuit breaker ↔ electrical fuse)
2. **Inverse pattern**: What's the opposite architectural pattern, and would it work here? (polling ↔ push, monolith ↔ microservice, eager ↔ lazy)
3. **Borrow from stdlib/ecosystem**: Is there a well-tested library or language feature that handles this class of problem? Don't reinvent.
4. **Prior art search**: Has this exact problem been solved in another project, language, or framework? Search before building.

**Output**: Name the analogous system/pattern and explain how the mapping works.

---

## Framework 3: Complexity Decomposition (복잡성 분해)

Break a complex problem into independently solvable parts.

**Process:**
1. **List components**: What are the 3-5 distinct sub-problems?
2. **Map dependencies**: Which parts depend on which? Draw the DAG.
3. **Find the leverage point**: Which single sub-problem, if solved, unblocks the most others?
4. **Isolate the hard part**: Separate the genuinely hard sub-problem from the boilerplate. Solve the hard part first in isolation.
5. **Sequence**: Determine the order — solve independent parts in parallel, dependent parts in sequence.

**Output**: A numbered list of sub-problems with their dependency relationships and a suggested solve order.

---

## Framework 4: Multi-Dimensional Analysis (다차원 분석)

Analyze the problem across multiple dimensions to find the real constraint.

**Dimensions to evaluate:**
- **Time**: Is this a build-time, deploy-time, or runtime problem? Can you shift when the work happens?
- **Layer**: Is the problem in the data model, business logic, API boundary, or presentation? Are you solving it at the right layer?
- **Scope**: Is this a local fix, a module-level redesign, or a system architecture issue? Are you at the right scope?
- **Constraint**: What's the actual bottleneck — correctness, performance, maintainability, or compatibility? Are you optimizing the right thing?
- **Lifecycle**: Is this a one-time migration, a growing problem, or a steady-state concern? Does the solution need to scale?

**Output**: Identify which dimension reveals the real constraint, and propose solutions that address that specific dimension.

---

## Output Format

```
## Rethink: [Problem Title]

**Problem**: [one sentence]
**Blocker**: [one sentence]
**Attempts**: [what was tried]

### Frameworks Applied: [Name 1] + [Name 2]

#### [Framework 1 Name] Analysis
[Framework-specific analysis, 3-5 sentences]

#### [Framework 2 Name] Analysis
[Framework-specific analysis, 3-5 sentences]

### Alternative Approaches

1. **[Approach name]**
   - Mechanism: [how it solves the blocker]
   - Trade-off: [what you give up]
   - First step: [immediate next action]

2. **[Approach name]**
   - Mechanism: ...
   - Trade-off: ...
   - First step: ...

3. **[Approach name]**
   - Mechanism: ...
   - Trade-off: ...
   - First step: ...

### Recommendation
[Which approach to try first and why, 1-2 sentences]
```

## Anti-Patterns

- Generating vague or generic advice ("try a different approach") — every alternative must be concrete and actionable
- Analysis paralysis — limit to 3-5 alternatives, pick one, and try it
- Reframing without action — the output must include a "first step" for each alternative
- Using this skill as procrastination — if the problem is clear and the solution is obvious, just do it
