# Context Management

Claude Code operates within a ~200K token context window (up to 1M on premium plans).
Every message, file read, and tool output consumes context. When it fills,
quality degrades and earlier decisions are lost.

## Strategies

- **Auto-compaction**: Triggers at a configurable threshold (default ~95%).
  Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (e.g., "50" for earlier compaction).
- **Strategic compaction**: Use `/compact` at logical breakpoints rather than relying
  on auto-compaction at capacity.
- **Subagent delegation**: Verbose operations (tests, log parsing, doc fetching)
  belong in subagents — only summaries return to main context.
- **Model routing**: Use Haiku subagents for exploration (cheap, fast),
  Sonnet for implementation, Opus for complex reasoning.
- **MAX_THINKING_TOKENS**: Cap extended thinking tokens to control cost
  (e.g., "10000").

## Session continuity

- `claude --continue` / `claude -c`: Resume last session.
- `claude --resume` / `claude -r`: Choose from recent sessions by ID or name.
- `claude --continue --fork-session`: Branch off from a session without modifying the original.
- Fresh session with written handoff file is usually better than resuming stale context.
