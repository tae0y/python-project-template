---
name: template-upstream
description: Propose changes from the current project back to the upstream python-project-template repository by generating a structured proposal file in proposals/. Use when a pattern, rule, hook, skill, or config in this project is good enough to share with the template. Triggers on: "템플릿에 반영", "upstream 제안", "template에 올리고 싶어", "이 패턴 템플릿에 추가", "proposal 만들어줘".
---

# template-upstream

Direction: Project → Template. Generate a structured proposal file in `proposals/` so that good patterns discovered in this project can be reviewed for inclusion in the upstream template.

## Proposal File Convention

Path: `proposals/YYYYMMDD/proposal-<slug>.md`

- `YYYYMMDD`: today's date
- `slug`: kebab-case summary of the change (e.g., `add-ruff-hook`, `update-commit-convention`)

Example: `proposals/20260222/proposal-add-ruff-hook.md`

## Proposal File Format

```markdown
# Proposal: <title>

**Date:** YYYY-MM-DD
**Source project:** <project name from git remote origin or directory name>
**Category:** <rule | hook | skill | config | command | other>
**Status:** draft

## Summary

One paragraph: what is being proposed and why it is useful.

## Motivation

What problem this pattern solved in the source project.
Why it belongs in the template.

### Evidence from localdocs

Cite specific artifacts that demonstrate the pattern has real-world value.
At least one citation required; proposal without evidence is weak.

| Artifact | Location | What it shows |
|----------|----------|---------------|
| learn file | `localdocs/learn.<topic>.md` | Problem encountered, pattern adopted |
| ADR | `localdocs/adr/adr-NNN-<slug>.md` | Architectural decision it supports |
| worklog entry | `localdocs/worklog.done.md` | Task where the pattern made a difference |

If no localdocs evidence exists, state: "No localdocs evidence — pattern is theoretical."
The reviewer (template-proposal-review) will weight this accordingly.

## Proposed Change

### Target path(s) in template

List of file paths to add or modify (relative to template repo root).

### Content

\`\`\`
Full file content or unified diff
\`\`\`

## Caveats

Any considerations when applying. Write "None." if not applicable.

## Review checklist

- [ ] No conflict with existing template files
- [ ] All project-specific values removed (paths, domains, secrets)
- [ ] Downstream sync test needed after applying via template-downstream
- [ ] localdocs evidence cited (or absence explicitly noted)
```

## Steps

### 1. Clarify scope and load localdocs context

If the user has not specified what to propose, ask:

```
What would you like to propose to the template?
Please provide a file path or describe the pattern.
```

Before reading the source file, read the project's `localdocs/` to surface evidence:

```bash
# Glob for all localdocs artifacts
localdocs/worklog.done.md
localdocs/learn.*.md
localdocs/adr/*.md
```

Scan these files for mentions of the proposed pattern, file name, or related concepts.
The goal is to find real-world evidence that the pattern was applied and produced value —
mirroring how the `.claude/` review team (review-20260222.md) validated patterns
by cross-referencing learn files, ADRs, and worklog entries before recommending promotion.

If `localdocs/` does not exist or is empty, note that no evidence is available.

### 2. Read source file and security review

Read the target file. Before including any content in the proposal, remove or replace the following:

| Check | Example | Replace with |
|-------|---------|--------------|
| API keys / tokens | `sk-...`, `ghp_...` | `<YOUR_API_KEY>` |
| DDNS / real domains | `myhouse.duckdns.org` | `example.com` |
| Internal IP addresses | `192.168.1.10` | `<HOST_IP>` |
| Inlined `.env` values | `password=secret123` | `<YOUR_PASSWORD>` |
| Absolute paths (home dir) | `/Users/john/projects/` | `<PROJECT_ROOT>/` |

After removal, verify the content would be safe to paste into a public GitHub issue.

### 3. Create date directory

```bash
mkdir -p proposals/YYYYMMDD
```

Skip if already exists.

### 4. Write proposal file

Create `proposals/YYYYMMDD/proposal-<slug>.md` using the format above.

- Replace all project-specific values with `<your-value>` placeholders
- Infer `Category` from file location: `.claude/rules/` → rule, `.claude/hooks/` → hook, `.claude/skills/` → skill, etc.

### 5. Report

```
Created: proposals/20260222/proposal-<slug>.md

Review and apply via the template-proposal-review skill.
```
