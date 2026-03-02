# Sandbox

Claude Code's native sandbox provides OS-level filesystem and network isolation
(Seatbelt on macOS, bubblewrap on Linux). Enable with `/sandbox` in a session.

## Behavior

- Writes restricted to current working directory and subdirectories.
- Reads unrestricted by default — harden with explicit deny rules in settings.
- Network limited to explicitly allowed domains.
- In auto-allow mode, Bash commands within sandbox boundaries skip permission prompts.

## Important distinction

Without `/sandbox`, deny rules only block Claude's built-in tools — Bash commands
bypass them. With sandbox enabled, deny rules are enforced at the OS level,
covering Bash as well.

Hooks are guardrails (prompt-level). Sandbox is walls (OS-level).
Use both for defense in depth.
