# Understand Claude Code Rules

This page describes how rules in `.claude/rules/` shape Claude's behavior throughout every session.

## How rules work

Rules are Markdown files that Claude Code loads as standing instructions before every response. Unlike skills (which are invoked on demand) or hooks (which intercept tool calls), rules are always active — they constrain reasoning, communication style, and tool usage unconditionally.

Rules are picked up automatically from `.claude/rules/`. No registration in `settings.json` is required.

## Rules in this template

### `thinking-guidelines.md`

Governs how Claude reasons and communicates on non-coding tasks: conversation, analysis, review, planning, and research.

**Reasoning protocol:** Every request is decomposed into facts (verifiable), assumptions (unstated premises to surface), and preferences (subjective choices to present trade-offs for). Conclusions are stated in positive, affirmative form first — hedging never leads.

**Critical thinking:** At least two distinct lines of reasoning are considered for non-trivial questions. Where lines disagree, the disagreement and trade-offs are stated explicitly. Factual accuracy takes priority over agreement.

**Communication style:**
- Korean by default (`해요/어요` register), switching language when the user does.
- Concise prose over formatted lists — structure only when it improves clarity.
- No praise, filler, emotional language, emojis, or hedging preambles.

### `commit-convention.md`

Enforces a prefix scheme for all commit messages on the `main` branch. Messages must be written in English and begin with one of three tags:

| Prefix | Scope |
|--------|-------|
| `[MAINTENANCE]` | No functional change: refactoring, formatting, dependency bumps, doc updates, test additions |
| `[NEW FEATURE]` | New capability exposed to users or callers |
| `[BREAKING CHANGES]` | Incompatible change: removed/renamed tool, changed response schema, dropped API |

This rule works in concert with `check-commit-convention.sh` (PostToolUse hook) and the `commit-msg` pre-commit hook, which each enforce the same constraint at different points in the workflow.

### `document-management.md`

Defines where project documents live and how they must be named. All project documents go into `localdocs/` (gitignored, local-only). The `worklog` skill and `progress-guardian` agent depend on exact filenames — do not rename them.

**Naming scheme:**

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

**Knowledge store precedence:** Learning notes go to `localdocs/learn.*.md` during work, are merged into `CLAUDE.md` via the `learn` agent at feature end, and cross-project patterns go to auto memory (`~/.claude/projects/`).

### `markdown-reading-guidelines.md`

Describes an efficient two-step pattern for reading large Markdown files. When only a specific section is needed in a file longer than ~100 lines:

1. Scan headings with `grep -n "^#" <file.md>`.
1. Read the target section with `Read` using `offset` and `limit`.

For short files or when full context is needed, skip step 1 and read directly.

### `code-navigation-guidelines.md`

Directs Claude to use `jcodemunch-mcp` before reading files when exploring the codebase — locating symbols, tracing call hierarchies, finding definitions.

**Preferred order:**

1. `jcodemunch` symbol or semantic search → get the precise file and line.
1. Read only the targeted file range.

Whole-file reads to find a symbol are avoided when jcodemunch can return the location directly. Each session begins with `jcodemunch_guide` to load current agent instructions.

> This rule depends on the jcodemunch MCP server being configured in `.mcp.json`. If you are not using jcodemunch, remove this rule file and the corresponding entries from `.mcp.json`. See the [External Services](../README.md#external-services) section in the README.

## Add a new rule

1. Create a Markdown file in `.claude/rules/` with a descriptive kebab-case name.
1. Write the rule as a clear, affirmative instruction. Avoid vague language — Claude follows these literally.
1. Keep each rule file to one concern. Split unrelated constraints into separate files.

Rules take effect immediately on the next session — no restart or registration needed.
