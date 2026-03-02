# CLI Reference

## Commands

| Command                          | Description                                       |
|----------------------------------|---------------------------------------------------|
| `claude`                         | Start interactive session                         |
| `claude "query"`                 | Start session with initial prompt                 |
| `claude -p "query"`              | Print response without interactive mode (SDK)     |
| `cat file \| claude -p "query"`  | Process piped content                             |
| `claude -c`                      | Continue most recent conversation                 |
| `claude -c -p "query"`           | Continue via SDK                                  |
| `claude -r "session" "query"`    | Resume specific session by ID or name             |
| `claude update`                  | Update to latest version                          |
| `claude auth login/logout/status`| Authentication management                         |
| `claude agents`                  | List all configured subagents                     |
| `claude mcp`                     | Configure MCP servers                             |
| `claude remote-control`          | Start Remote Control session from claude.ai       |

## Key flags

| Flag                              | Description                                                     |
|-----------------------------------|-----------------------------------------------------------------|
| `--model`                         | Set model (alias: sonnet, opus, haiku or full name)             |
| `--allowedTools`                  | Tools that execute without permission prompts                   |
| `--disallowedTools`               | Tools removed from model's context                              |
| `--permission-mode`               | Start in a specified permission mode (plan, etc.)               |
| `--max-turns`                     | Limit agentic turns (print mode only)                           |
| `--max-budget-usd`                | Maximum dollar amount for API calls (print mode only)           |
| `--output-format`                 | Output: text, json, stream-json                                 |
| `--json-schema`                   | Get validated JSON output matching a schema (print mode only)   |
| `--system-prompt`                 | Replace entire system prompt                                    |
| `--system-prompt-file`            | Replace with file contents (print mode only)                    |
| `--append-system-prompt`          | Append to default system prompt                                 |
| `--append-system-prompt-file`     | Append file contents (print mode only)                          |
| `--agent`                         | Specify an agent for the session                                |
| `--agents`                        | Define subagents dynamically via JSON                           |
| `--tools`                         | Restrict which built-in tools are available                     |
| `--mcp-config`                    | Load MCP servers from JSON files                                |
| `--strict-mcp-config`             | Only use MCP servers from --mcp-config                          |
| `--worktree`, `-w`                | Start in isolated git worktree                                  |
| `--add-dir`                       | Add additional working directories                              |
| `--chrome` / `--no-chrome`        | Enable/disable Chrome browser integration                       |
| `--remote`                        | Create a web session on claude.ai                               |
| `--teleport`                      | Resume a web session locally                                    |
| `--verbose`                       | Enable verbose logging                                          |
| `--debug`                         | Enable debug mode with category filtering                       |
| `--fallback-model`                | Auto-fallback when default model is overloaded (print mode)     |
| `--fork-session`                  | Create new session ID when resuming                             |
| `--from-pr`                       | Resume sessions linked to a GitHub PR                           |
| `--plugin-dir`                    | Load plugins from directories for this session                  |
| `--no-session-persistence`        | Don't save session to disk (print mode only)                    |
| `--disable-slash-commands`        | Disable all skills and commands                                 |
| `--teammate-mode`                 | Agent team display: auto, in-process, tmux                      |

## Headless / SDK usage

`claude -p` runs non-interactively (formerly "headless mode"). The Agent SDK gives
the same tools, agent loop, and context management programmatically via CLI, Python, or TypeScript.

```bash
# Structured JSON output
claude -p "Summarize this project" --output-format json

# Schema-validated output
claude -p "Extract functions" --output-format json --json-schema '{...}'

# Stream responses
claude -p "Explain" --output-format stream-json --verbose --include-partial-messages

# Auto-approve tools
claude -p "Run tests and fix failures" --allowedTools "Bash,Read,Edit"

# Continue conversation
claude -p "Focus on DB queries" --continue

# Create a commit
claude -p "Commit staged changes" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git commit *)"
```
