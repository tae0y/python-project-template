# Proposal: Fix template-upstream skill to write proposals into the template repo

**Date:** 2026-02-22
**Source project:** that-night-sky
**Category:** skill
**Status:** applied

## Summary

The `template-upstream` skill currently creates `proposals/YYYYMMDD/proposal-<slug>.md` relative to the **source project root**. Proposals belong in the **template repo** (`/Users/bachtaeyeong/10_SrcHub/python-template/proposals/` or equivalent), not in the downstream project. Fix the skill to resolve the template root first and write the proposal there.

## Motivation

When the skill was invoked in the `that-night-sky` project, the proposal file was created at:

```
/Users/bachtaeyeong/10_SrcHub/that-night-sky/proposals/20260222/proposal-*.md
```

It had to be manually moved to:

```
/Users/bachtaeyeong/10_SrcHub/python-template/proposals/20260222/proposal-*.md
```

The correct destination is always the template repo, since proposals are reviewed and applied there — not in downstream projects.

### Evidence from localdocs

No localdocs evidence — discovered directly during template-upstream skill invocation on 2026-02-22.

## Proposed Change

### Target path(s) in template

- `.claude/skills/template-upstream/SKILL.md`

### Content

In **Step 3: Create date directory**, replace:

```markdown
### 3. Create date directory

\`\`\`bash
mkdir -p proposals/YYYYMMDD
\`\`\`

Skip if already exists.
```

With:

```markdown
### 3. Resolve template root and create date directory

Resolve `TEMPLATE_ROOT` using the same priority order as `template-downstream`:

1. **Local path** — if `/Users/bachtaeyeong/10_SrcHub/python-template/.claude` exists, use its parent as `TEMPLATE_ROOT`.
2. **Clone** — otherwise:

\`\`\`bash
TMPDIR=$(mktemp -d)
git clone --depth 1 https://github.com/tae0y/python-project-template.git "$TMPDIR/template"
TEMPLATE_ROOT="$TMPDIR/template"
\`\`\`

Then create the proposals directory:

\`\`\`bash
mkdir -p "$TEMPLATE_ROOT/proposals/YYYYMMDD"
\`\`\`

Skip if already exists.
```

In **Step 4: Write proposal file**, replace:

```markdown
Create `proposals/YYYYMMDD/proposal-<slug>.md` using the format above.
```

With:

```markdown
Create `$TEMPLATE_ROOT/proposals/YYYYMMDD/proposal-<slug>.md` using the format above.
```

In **Step 5: Report**, replace:

```markdown
Created: proposals/20260222/proposal-<slug>.md
```

With:

```markdown
Created: <TEMPLATE_ROOT>/proposals/20260222/proposal-<slug>.md

Review and apply via the template-proposal-review skill.
```

## Caveats

- The local path placeholder (`/Users/bachtaeyeong/10_SrcHub/python-template`) is machine-specific. The skill should use the same resolution logic as `template-downstream` so it works on any machine with a different local clone path.

## Review checklist

- [ ] No conflict with existing template files
- [ ] All project-specific values removed (paths, domains, secrets)
- [ ] Downstream sync test needed after applying via template-downstream
- [ ] localdocs evidence cited (or absence explicitly noted)
