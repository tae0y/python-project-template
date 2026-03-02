# Checkpointing

Claude Code automatically tracks file edits, allowing you to rewind to previous states
if anything gets off track. Checkpoints are a session-level safety net.

## How it works

- Every user prompt creates a new checkpoint.
- Only tracks edits made through Claude's file editing tools (not Bash commands).
- Checkpoints persist across sessions and can be accessed in resumed conversations.
- Automatically cleaned up after 30 days (configurable).

## Rewind and summarize

Press `Esc+Esc` or use `/rewind` to open the rewind menu. Options:

- **Restore code and conversation**: revert both to that point.
- **Restore conversation**: rewind to that message while keeping current code.
- **Restore code**: revert file changes while keeping the conversation.
- **Summarize from here**: compress conversation from this point forward into a summary,
  freeing context space. Original messages stay in the transcript for reference.
- **Never mind**: return without changes.

## Limitations

- Bash command changes (rm, mv, cp) are not tracked — only direct file editing tools.
- External changes from other sessions or manual edits are not captured.
- Not a replacement for version control. Think of checkpoints as "local undo" and Git as "permanent history."
