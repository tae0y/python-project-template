# Plugins

Plugins are distributable bundles that package skills, agents, hooks, MCP servers,
LSP servers, and commands into a single installable unit.

## Structure

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json      # Plugin metadata (name, version, description)
├── commands/             # Slash commands (legacy; use skills/ for new)
├── agents/               # Specialized subagents
├── skills/               # Skills with SKILL.md
├── hooks/
│   └── hooks.json        # Hook configurations
├── .mcp.json             # MCP server config
├── .lsp.json             # LSP server config
├── settings.json         # Default settings for the plugin
├── scripts/              # Hook and utility scripts
├── LICENSE
└── CHANGELOG.md
```

## Components

| Component     | Location             | Purpose                                        |
|---------------|----------------------|------------------------------------------------|
| Skills        | `skills/`            | Skills with `<name>/SKILL.md`                  |
| Commands      | `commands/`          | Legacy slash commands (Markdown files)          |
| Agents        | `agents/`            | Subagent Markdown files                        |
| Hooks         | `hooks/hooks.json`   | Event handler configurations                   |
| MCP servers   | `.mcp.json`          | MCP server definitions                         |
| LSP servers   | `.lsp.json`          | Language Server Protocol configurations        |
| Settings      | `settings.json`      | Default config applied when plugin is enabled  |

## LSP servers

Plugins can provide LSP (Language Server Protocol) servers for real-time code intelligence:
instant diagnostics, go-to-definition, find references, hover info, and type information.

Available LSP plugins: `pyright-lsp` (Python), `typescript-lsp` (TypeScript), `rust-lsp` (Rust).

## CLI commands

```bash
claude plugin install <plugin>@<marketplace>          # Install
claude plugin install <plugin> --scope project        # Install to project scope
claude plugin uninstall <plugin>                       # Remove
claude plugin enable <plugin>                          # Enable disabled plugin
claude plugin disable <plugin>                         # Disable without uninstall
claude plugin update <plugin>                          # Update to latest
```

## Installation scopes

| Scope     | Settings file                    | Use case                                       |
|-----------|----------------------------------|-------------------------------------------------|
| `user`    | `~/.claude/settings.json`       | Personal, all projects (default)                |
| `project` | `.claude/settings.json`          | Team-shared via version control                 |
| `local`   | `.claude/settings.local.json`    | Project-specific, gitignored                    |
| `managed` | Managed settings                 | Admin-controlled (read-only, update only)       |

## Notes

- Plugins cannot distribute rules (permissions) automatically.
- Review any plugin's hooks and scripts before installation — they run code on your machine.
- Use `${CLAUDE_PLUGIN_ROOT}` in hooks/scripts for plugin-relative paths.
- Components must be at plugin root, not inside `.claude-plugin/`. Only `plugin.json` goes there.
- Use `claude --debug` to see plugin loading details and diagnose issues.
