# Document Management

Project documents live in `localdocs/` (gitignored, local-only) and follow strict naming conventions. The `worklog` skill and `progress-guardian` agent rely on these patterns via glob.

## File Naming Rules

| Type | Pattern | Examples |
|------|---------|---------|
| Backlog (future, pre-plan) | `backlog.*.md` | `backlog.api-v2.md` |
| Plan / architecture | `plan.*.md` | `plan.architecture.md` |
| Learning notes | `learn.*.md` | `learn.validation.md` |
| Worklog backlog | `worklog.todo.md` | fixed filename |
| Worklog in-progress | `worklog.doing.md` | fixed filename |
| Worklog completed | `worklog.done.md` | fixed filename |
| Reference material | `refer.*.md` | `refer.openapi.md` |
| ADR | `adr/adr-NNN-*.md` | `adr/adr-001-mcp-refactor.md` |

## Rules

- **Never rename** worklog files — skills depend on exact filenames.
- **Always use the prefix** when creating new documents.
- **One topic per file** — don't mix unrelated content.
- **ADR numbers are sequential.** Use kebab-case. Never reuse or skip numbers.
- `localdocs/` must be bootstrapped manually per clone: `mkdir -p localdocs/adr && touch localdocs/worklog.{todo,doing,done}.md`

## Knowledge Store Precedence

- **During work** → `localdocs/learn.*.md`
- **At feature end** → merge to `CLAUDE.md` via `learn` agent
- **Auto memory** (`~/.claude/projects/`) → cross-project patterns only
