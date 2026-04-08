# Coding Standards

These rules apply to all code-related tasks. They override default behavior where they conflict.

## Task size classifier

| Size | Criteria | Plan | Worklog | TDD | Examples |
|------|----------|------|---------|-----|----------|
| **TRIVIAL** | Config-only, docs-only, dependency bump, typo fix | Skip | Skip | Skip | `.md` edits, `uv lock`, `.gitignore` |
| **SMALL** | Single-file logic change, ≤ 20 lines changed | One-liner | Optional | Required | Bug fix, add validation, rename |
| **STANDARD** | Multi-file, clear scope, ≤ 1 session | Brief plan | Required | Required | New endpoint, refactor module |
| **LARGE** | Multi-session, architectural impact | Full plan + approval | Required | Required | New subsystem, migration |

When in doubt, classify one level up.

## Diagnose before fixing

IMPORTANT: Identify the root cause before proposing any solution. State the observed symptom, your root-cause hypothesis, and how you will verify it — in that order. Do not write code until the cause is understood.

## Plan before implementing

For STANDARD or LARGE tasks, create `localdocs/plan.<topic>.md` before writing any code. Minimum sections: Purpose, Stage (SPIKE/MVP/PRODUCTION), Interface, Open Questions. Wait for user approval before starting. Update and re-approve if scope changes.

For any change beyond a one-line fix, state a brief plan with verifiable checkpoints and wait for confirmation unless the user has indicated to proceed autonomously.

## Simplicity first

Write the minimum code that solves the stated problem. No speculative features, premature abstractions, or unrequested flexibility. If your solution exceeds 3x the expected size, stop and simplify.

## Surgical changes

Modify only what the current task requires. Match existing code style. Remove imports, variables, or functions that YOUR changes made unused. Do not touch pre-existing dead code or formatting unless asked. Every changed line must trace directly to the user's request.

## Verify through the real interface

Run the actual script, test file, or entry point — never simulate execution with `python -c` or inline stubs. Use the project's package manager for dependencies (`uv add`, `npm install`). Never edit lock files directly.

## Test-driven workflow

Write or update tests before implementation when the project has a test framework. Never modify existing tests to make new code pass. Never hard-code values to satisfy tests.

## Protect existing safeguards

IMPORTANT: Never remove or disable existing error handling, safety checks, linter rules, type checking, or test assertions without explicit permission. If a guard blocks your change, report the conflict — do not silently bypass it.

## Verify external dependencies

Check official documentation before using any external library or API. Use project tooling (MCP servers, context7) to verify. State when working from memory versus verified documentation.

## Direct solutions only

Take the most direct path. If you must use a workaround, name it, explain why the direct path is blocked, and get approval before proceeding.

## No silent failures

Never stub out failing paths or hard-code expected output to pass tests. If something fails and you cannot fix it, report the failure clearly.

## Context management

Commit working changes frequently for rollback safety. After extended sessions (50+ tool calls), summarize current state and remaining tasks.
