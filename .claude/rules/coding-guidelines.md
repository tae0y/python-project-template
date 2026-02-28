# Coding Standards

These rules apply to all code-related tasks. They override default behavior where they conflict.

## Diagnose before fixing

IMPORTANT: Identify the root cause before proposing any solution.

State the observed symptom, your root-cause hypothesis, and how you will verify it — in that order. If the cause is unclear, investigate first. Do not write code until the cause is understood.

## Plan before implementing

For any change beyond a one-line fix, state a brief plan with verifiable checkpoints before writing code:

```
1. [Step] → verify: [how]
2. [Step] → verify: [how]
```

Wait for confirmation on multi-step plans unless the user has indicated to proceed autonomously.

## Simplicity first

Write the minimum code that solves the stated problem. No speculative features, premature abstractions, or flexibility that was not requested. If your solution exceeds 3x the expected size, stop and simplify.

## Surgical changes

Modify only what the current task requires. Match existing code style, even if you would do it differently.

Remove imports, variables, or functions that YOUR changes made unused. Do not touch pre-existing dead code, comments, or formatting unless asked.

The test: every changed line traces directly to the user's request.

## Verify through the real interface

Run the actual script, test file, or entry point — never simulate execution with `python -c` or inline stubs. Call the real function under test; never create parallel dummy implementations.

Use the project's package manager for dependencies (e.g., `uv add`, `npm install`). Never edit lock files or dependency manifests directly.

## Test-driven workflow

Write or update tests before implementation when the project has a test framework. Never modify existing tests to make new code pass. Never hard-code values or create placeholder data to satisfy tests.

## Protect existing safeguards

IMPORTANT: Never remove or disable existing error handling, safety checks, linter rules, type checking, or test assertions without explicit permission. If a guard blocks your change, report the conflict — do not silently bypass it.

## Verify external dependencies

Check official documentation before using any external library or API. Do not rely on training knowledge for API signatures, configuration options, or version-specific behavior.

When available, use project tooling (MCP servers, context7, docs commands) to verify. State when you are working from memory versus verified documentation.

## Direct solutions only

Take the most direct path to solve the problem. If a direct solution exists, use it. If you must use an indirect approach or workaround, name it, explain why the direct path is blocked, and get approval before proceeding.

## No silent failures

Never remove safety checks to make code compile. Never stub out failing paths instead of fixing them. Never hard-code expected output to pass tests. If something fails and you cannot fix it, report the failure clearly.

## Context management

Commit working changes frequently for rollback safety. After extended sessions (50+ tool calls), summarize current state and remaining tasks to prevent context drift.