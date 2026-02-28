# Manage Template Synchronization with Skills

이 문서는 템플릿과 하위 프로젝트 사이의 양방향 동기화 skill을 설명합니다.

## Skill 목록

| Skill | 방향 | 설명 |
|-------|------|------|
| `template-upstream` | 프로젝트 → 템플릿 | 하위 프로젝트에서 발견한 좋은 패턴을 `proposals/draft/`에 제안서로 올립니다. 제안서에는 `localdocs/`의 learn 파일, ADR, worklog 항목 같은 근거를 포함해야 합니다. 근거 없는 제안서는 약한 후보로 취급됩니다. |
| `template-proposal-review` | 템플릿 내부 | `proposals/draft/`에 쌓인 제안서를 검토합니다. "모든 하위 프로젝트에 도움이 되는가", "프로젝트 고유 값이 제거되었는가", "실제 채택 근거가 있는가" 같은 기준으로 판단한 뒤 `accepted/`, `rejected/`, 또는 보류로 분류합니다. |
| `template-downstream` | 템플릿 → 프로젝트 | 템플릿의 최신 `.claude/`, `.mcp.json`, `.pre-commit-config.yaml`을 하위 프로젝트에 반영합니다. 업스트림에 있는 파일만 갱신하고, 하위 프로젝트에만 있는 파일은 건드리지 않습니다. |
| `template-broadcast` | 템플릿 → 전체 프로젝트 | `template-downstream`을 등록된 모든 하위 프로젝트에 일괄 적용합니다. 프로젝트 목록은 `.claude/skills/template-broadcast/references/projects.md`에서 관리합니다. 한 프로젝트에서 실패해도 나머지는 계속 진행합니다. |

## 흐름

```
┌───────────────────────────────────┐
│           템플릿 레포                │
│                                   │
│   제안 접수 ──> 검토 ──> 승인 / 반려    │
│                                   │
└──────┬────────────────────▲───────┘
       │                    │
  downstream           upstream
  broadcast            (제안서)
       │                    │
┌──────▼────────────────────┴───────┐
│          하위 프로젝트(들)            │
└───────────────────────────────────┘
```
