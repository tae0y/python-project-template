# Proposal: Clarify that template-upstream skill belongs to the template repo context

**Date:** 2026-02-22
**Source project:** that-night-sky
**Category:** skill
**Status:** applied

## Summary

The `template-upstream` skill description and trigger phrases do not make clear that it should be invoked from the **template repo context**, not from a downstream project. Add an explicit note that proposals are per-template, not per-project, and that the skill should be run when the working directory (or active project context) is the template repo.

## Motivation

When the skill was invoked from the `that-night-sky` downstream project, it was natural to assume proposals go in that project. There was no guidance in the skill description indicating otherwise. The result was a proposal file created in the wrong location that had to be manually moved.

The core misunderstanding: proposals are not per-project artifacts. They are template-level artifacts reviewed and applied by the template maintainer. The skill should make this boundary explicit upfront.

### Evidence from localdocs

No localdocs evidence — discovered directly during template-upstream skill invocation on 2026-02-22.

## Proposed Change

### Target path(s) in template

- `.claude/skills/template-upstream/SKILL.md`

### Content

In the frontmatter `description` field, prepend:

```
IMPORTANT: This skill must be run in the template repo context, not in a downstream project.
```

After the `# template-upstream` heading, add a context note before "Direction:":

```markdown
> **Context:** Run this skill from the **template repo** (`python-project-template`), not from a downstream project. Proposals are template-level artifacts — one shared `proposals/` directory for all projects, not one per downstream project.
```

Full updated opening section:

```markdown
# template-upstream

> **Context:** Run this skill from the **template repo** (`python-project-template`), not from a downstream project. Proposals are template-level artifacts — one shared `proposals/` directory for all projects, not one per downstream project.

Direction: Project → Template. Generate a structured proposal file in `proposals/` so that good patterns discovered in this project can be reviewed for inclusion in the upstream template.
```

## Caveats

None. This is documentation-only — no functional change to the skill steps.

## Review checklist

- [ ] No conflict with existing template files
- [ ] All project-specific values removed (paths, domains, secrets)
- [ ] Downstream sync test needed after applying via template-downstream
- [ ] localdocs evidence cited (or absence explicitly noted)
