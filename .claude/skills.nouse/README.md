# skills.nouse — Disabled Skills

Skills here are disabled. To enable a skill, move its directory into `.claude/skills/`.

## Why each skill is disabled

| Skill | Disabled reason |
|-------|----------------|
| `status` | Absorbed by `progress-guardian` agent. Overlaps with worklog state summary. |
| `next` | Absorbed by `progress-guardian` agent. Next-task logic lives in the agent's plan execution loop. |
| `localdocs-til-link` | Project-setup utility. Rarely needed; activate per-project when linking `localdocs/` to a TIL repo. |
| `skill-creator` | Meta-skill for generating new skills. Low frequency; activate only during `.claude/` development sessions. |
| `codex` | Codex-specific patterns. Activate only when working in a Codex environment. |
| `expectations` | Speculative; not validated against actual project patterns. Needs review before enabling. |
| `microsoft-agent-framework-python` | Domain-specific to Azure AI Agent Framework. Not applicable to general Python projects. |
| `mutation-testing` | Advanced testing pattern. Consider enabling after TDD baseline is stable. |
| `openapi-to-application` | Architecture-level OpenAPI scaffold. Activate only for API-first projects. |
| `openapi-to-application-code` | Code generation from OpenAPI spec. Activate only for API-first projects. |
| `playwright-python` | Playwright test automation for Python. Activate for projects with browser/UI testing. |
| `python-mcp-server` | MCP server scaffolding. Superseded by `python-mcp-expert` skill (currently active). |
| `python-mcp-server-generator` | Code generation for MCP servers. Superseded by `python-mcp-expert` skill (currently active). |
| `repo-architect` | High-level repository architecture guidance. Activate only during project setup. |
| `api-architect` | API design patterns. Activate only for projects with public API surface. |
| `technical-writer` | Documentation authoring. Superseded by `docs-guardian` agent + `md-janitor` skill (both active). |
| `test-design-reviewer` | Test design review. Partially absorbed by `tdd-guardian` agent. Evaluate overlap before re-enabling. |
| `testing` | General testing patterns. Absorbed by `tdd` skill + `tdd-guardian` agent. |
