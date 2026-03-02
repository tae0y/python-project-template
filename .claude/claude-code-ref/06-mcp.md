# MCP (Model Context Protocol)

MCP servers are external tool providers that extend Claude Code's available tools
beyond the local filesystem — into live APIs, databases, or custom business logic.
MCP uses the [open standard](https://modelcontextprotocol.io/introduction).

## Configuration

MCP servers can be configured in three ways:
- CLI: `claude mcp add --transport http <name> <url>`
- Project: `.mcp.json` (committable, team-shared)
- Settings files (user/local/managed scope)

Supported transports: **HTTP** (recommended), **SSE** (deprecated), **stdio** (local processes).

## Installation scopes

| Scope   | Storage                      | Use case                                              |
|---------|------------------------------|-------------------------------------------------------|
| local   | `~/.claude.json` (default)   | Personal, current project only                        |
| project | `.mcp.json` (version control)| Team-shared                                           |
| user    | `~/.claude.json`             | Personal, all projects                                |
| managed | System directories           | Admin-controlled, organization-wide                   |

## Key features

- **OAuth authentication**: Use `/mcp` to authenticate with remote servers requiring OAuth 2.0.
- **MCP resources**: Reference with `@server:protocol://path` in prompts.
- **MCP prompts**: Exposed as commands: `/mcp__<server>__<prompt>`.
- **Tool Search**: Automatically enabled when MCP tool definitions exceed 10% of context.
  Dynamically loads tools on-demand instead of preloading all. Configure with `ENABLE_TOOL_SEARCH`.
- **Dynamic updates**: Servers can send `list_changed` notifications to refresh tools without reconnect.
- **Claude Code as MCP server**: `claude mcp serve` exposes Claude Code's tools to other MCP clients.
- **Plugin MCP servers**: Plugins can bundle MCP servers that start automatically when enabled.
- **Environment variable expansion**: `.mcp.json` supports `${VAR}` and `${VAR:-default}` syntax.

## CLI commands

```bash
claude mcp add --transport http <name> <url>     # Add HTTP server
claude mcp add --transport stdio <name> -- <cmd>  # Add local server
claude mcp list                                    # List all servers
claude mcp get <name>                              # Get server details
claude mcp remove <name>                           # Remove server
claude mcp add-json <name> '<json>'                # Add from JSON config
claude mcp add-from-claude-desktop                 # Import from Claude Desktop
claude mcp serve                                   # Run Claude Code as MCP server
claude mcp reset-project-choices                   # Reset project server approvals
```

## Token cost awareness

Each MCP server's tool descriptions consume context tokens. With many servers active,
your effective context can drop significantly. Tool Search mitigates this
by dynamically loading tool definitions only when relevant.
Monitor with `/context` and remove unused servers.
`MAX_MCP_OUTPUT_TOKENS` (default 25,000) controls maximum output per tool call.
