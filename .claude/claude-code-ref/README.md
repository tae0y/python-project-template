# Claude Code Reference

Claude Code의 기능과 아키텍처 구성 요소를 설명하는 레퍼런스 문서 모음.
공식 문서(https://code.claude.com/docs)를 기반으로 정리.

## 목차

| #  | 파일                                          | 주제                  |
|----|-----------------------------------------------|----------------------|
| 01 | [claude-md](01-claude-md.md)                  | CLAUDE.md 프로젝트 메모리 |
| 02 | [skills](02-skills.md)                        | Skills (커맨드 포함)  |
| 03 | [hooks](03-hooks.md)                          | Hooks 라이프사이클 이벤트 |
| 04 | [subagents](04-subagents.md)                  | Subagents (서브에이전트) |
| 05 | [agent-teams](05-agent-teams.md)              | Agent Teams (멀티세션) |
| 06 | [mcp](06-mcp.md)                              | MCP 외부 도구 연동    |
| 07 | [plugins](07-plugins.md)                      | Plugins 배포 번들     |
| 08 | [settings](08-settings.md)                    | Settings 계층 구조    |
| 09 | [context](09-context.md)                      | Context 관리 전략     |
| 10 | [checkpointing](10-checkpointing.md)          | Checkpointing 되감기  |
| 11 | [interactive-mode](11-interactive-mode.md)     | 단축키, 명령어, Vim   |
| 12 | [cli-reference](12-cli-reference.md)          | CLI 명령어와 플래그    |
| 13 | [sandbox](13-sandbox.md)                      | Sandbox OS 격리      |

## 구조 요약

```
확장 (extend)     : Skills, Plugins, MCP
자동화 (automate)  : Hooks
위임 (delegate)    : Subagents, Agent Teams
보호 (protect)     : Sandbox, Settings (permissions)
관리 (manage)      : Context, Checkpointing, CLAUDE.md
조작 (operate)     : Interactive Mode, CLI
```
