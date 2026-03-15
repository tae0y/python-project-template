# Manage Template Synchronization with Skills

This page describes the bidirectional sync skills between the template and downstream projects.

## Skills

| Skill | Direction | Description |
|-------|-----------|-------------|
| `template-upstream` | project → template | Proposes useful patterns from a downstream project by creating a draft in `proposals/draft/`. Proposals must include evidence from `localdocs/` (learn files, ADRs, worklog entries). Proposals without evidence are treated as weak candidates. |
| `template-proposal-review` | template internal | Reviews drafts accumulated in `proposals/draft/`. Evaluates against criteria such as "useful to all downstream projects", "project-specific values removed", and "backed by real adoption evidence", then classifies each as `accepted/`, `rejected/`, or pending. |
| `template-downstream` | template → project | Applies the latest `.claude/`, `.mcp.json`, and `.pre-commit-config.yaml` from the template to a downstream project. Only files that exist upstream are updated; files that exist only in the downstream project are left untouched. |
| `template-broadcast` | template → all projects | Applies `template-downstream` to every registered downstream project in bulk. The project registry is managed in `.claude/skills/template-broadcast/references/projects.md`. A failure in one project does not stop the others. |

## Flow

```
┌───────────────────────────────────┐
│           Template repo           │
│                                   │
│   Draft received → Review → Accept / Reject  │
│                                   │
└──────┬────────────────────▲───────┘
       │                    │
  downstream           upstream
  broadcast            (proposal)
       │                    │
┌──────▼────────────────────┴───────┐
│          Downstream project(s)    │
└───────────────────────────────────┘
```

## Register a downstream project

To include a project in `template-broadcast`, add a row to `.claude/skills/template-broadcast/references/projects.md`.

### Prerequisites

- The project must be cloned locally.
- The local path must be accessible from the machine where `template-broadcast` runs.

### Steps

1. Open `.claude/skills/template-broadcast/references/projects.md`.

1. Add a row to the **Active Projects** table.

    ```markdown
    | <project-name> | /absolute/local/path | https://github.com/<org>/<repo>.git |
    ```

    Example:

    ```markdown
    | my-new-project | /Users/you/src/my-new-project | https://github.com/you/my-new-project.git |
    ```

1. Save the file. No other configuration is needed — `template-broadcast` reads this file at runtime.

### Remove a project

Delete the row from the **Active Projects** table, or move it to the **Excluded** table with a reason. Do not leave stale paths in the active list, as missing directories cause a `MISSING` warning on every broadcast run.
