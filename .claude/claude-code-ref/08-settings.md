# Settings Hierarchy

Claude Code uses a layered configuration system. Higher-priority scopes override lower ones.
Array-valued settings (permissions.allow, etc.) merge additively across scopes.

## Precedence (highest → lowest)

1. **Managed** (enterprise) — MDM profiles, registry keys, managed-settings.json
2. **Project local** — `.claude/settings.local.json` (gitignored, personal overrides)
3. **Project shared** — `.claude/settings.json` (committed, team-wide)
4. **User global** — `~/.claude/settings.json` (personal defaults)
5. **Legacy** — `~/.claude.json` (deprecated, still read)

## Key settings areas

- `model`: Default model selection (opus, sonnet, haiku)
- `permissions`: allow / ask / deny rules for tools. Deny is checked first.
- `hooks`: Lifecycle event handlers
- `env`: Environment variables applied at session start
- `sandbox`: Filesystem and network isolation settings
- `disallowedTools`: Completely block specific tools
- `enableAllProjectMcpServers`: Default false — prevents malicious MCP from committed repos

## Permission rule evaluation

Deny → Ask → Allow, first match wins. Wildcard patterns match simple prefixes only.
Compound shell operators (`&&`, `||`, `|`, `;`, `>`, `$()`) in Bash commands
require explicit allow or wrapper scripts.
