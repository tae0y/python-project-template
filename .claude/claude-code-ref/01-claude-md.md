# CLAUDE.md

CLAUDE.md is Claude Code's persistent project memory. It loads automatically at session start
and survives `/clear`. Think of it as "what Claude should know" — project architecture,
coding conventions, testing standards, and workflow rules.

Claude Code also discovers nested CLAUDE.md files in subdirectories, so you can scope
instructions per module. The main CLAUDE.md lives at the project root; subdirectory files
complement it with domain-specific context.

Put stable, reusable context here, not in the conversation. If you need to pass state
between sessions, write a plan to a file and point the next session at it — a fresh session
with a written handoff beats resuming a stale context.

CLAUDE.md is "what Claude should know." settings.json is "what Claude can do."
Keep that separation clean.

Auto-memory can be enabled via `/memory` to let Claude write persistent notes
to `~/.claude/projects/.../memory/MEMORY.md` automatically.
