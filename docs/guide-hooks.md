# Understand Claude Code Hooks

This page describes how hooks in `.claude/hooks/` intercept tool calls to enforce workflow rules automatically.

## How hooks work

Claude Code hooks are shell scripts that run before or after specific tool calls. They receive the tool input as JSON on stdin and can block an action (exit 2), prompt for user confirmation (JSON with `permissionDecision: "ask"`), or emit a reminder to stderr (exit 0).

| Hook event | When it runs |
|------------|-------------|
| `PreToolUse` | Before a tool executes — can block or ask for confirmation |
| `PostToolUse` | After a tool executes — typically emits reminders |

Hooks are registered in `.claude/settings.json` under the `hooks` key. Each entry maps a hook event to a shell script path.

## Hooks in this template

### `guard-settings-files.sh`

**Event:** PreToolUse — blocks `Read`, `Write`, `Edit`, and `Bash` commands that target `.claude/settings*.json`.

**Why it exists:** Settings files control permissions and hook registration. Allowing Claude to modify them during a session creates a self-modifying loop that can bypass the very guards the hooks enforce. Use `/update-config` skill instead, which is designed to make deliberate, reviewed changes.

### `check-commit-convention.sh`

**Event:** PostToolUse — triggers after any `git commit` Bash command.

**What it checks:** Reads the last commit subject via `git log -1 --format='%s'` and verifies it starts with one of the three required prefixes. Exits 2 (blocking) if the prefix is missing.

**Prefixes enforced:**

| Prefix | Use |
|--------|-----|
| `[MAINTENANCE]` | No functional change: refactoring, formatting, dependency bumps, doc updates, test additions |
| `[NEW FEATURE]` | New capability exposed to users or callers |
| `[BREAKING CHANGES]` | Incompatible change: removed/renamed tool, changed response schema, dropped API |

> **Note:** This hook fires after the commit has already been created. To fix a violation, run `git commit --amend -m "[PREFIX] original message"`. The pre-commit hook installed via `pre-commit install --hook-type commit-msg` provides hard enforcement for non-Claude commit sources.

### `check-pre-commit-gate.sh`

**Event:** PostToolUse — triggers after any `git commit` Bash command.

**What it does:** Emits a checklist reminder to stderr. It does not block; it ensures the developer confirms the quality gate was run before the commit went in.

The four-step gate it reminds you to complete:

1. `check` skill — detect lint, format, type, and security issues (read-only).
1. `auto-fix` skill — apply safe automatic fixes via ruff.
1. Re-run `check` — confirm clean.
1. Secrets scan — verify no API keys, tokens, or `.env` values are in source files.

### `check-new-test-file.sh`

**Event:** PreToolUse on `Write` — triggers when a new `test_*.py` file is about to be created.

**What it does:** Asks for user confirmation before the file is written. The confirmation prompt reminds the developer to verify that the new test imports and calls the real function under test — not a stub or dummy that mimics the implementation. A test that bypasses the real code is a false safety net: it passes while hiding actual bugs.

The hook skips the check if the file already exists (i.e., this is an overwrite, not a new creation).

### `check-external-lib-usage.sh`

**Event:** PostToolUse on `Write` and `Edit` — triggers when a Python file is saved with new import statements.

**What it does:** Scans the written content for `import` or `from … import` lines that reference external libraries (anything outside the standard library). Emits a reminder to stderr asking whether official documentation was consulted before the import was written.

It also reminds you to run the `audit` skill after adding any new dependency, to check for known vulnerabilities in the updated dependency graph.

This hook is a non-blocking reminder (exit 0). Continue if the library has already been verified.

## Add a new hook

1. Write the shell script in `.claude/hooks/`. Start with `#!/bin/bash` and read stdin into `INPUT`.
1. Parse the tool name and relevant input fields using `jq`.
1. Exit 0 to allow, exit 2 to block, or emit the JSON confirmation payload to block with a user prompt.
1. Register the hook in `.claude/settings.json` under `hooks` → the appropriate event key.

> Use the `/update-config` skill when editing `settings.json` — `guard-settings-files.sh` blocks direct file access.
