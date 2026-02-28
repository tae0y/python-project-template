# 템플릿 관리 skill

이 레포지토리가 단순한 boilerplate와 다른 점은 템플릿과 하위 프로젝트 사이의 양방향 동기화를 skill로 지원한다는 것입니다.

## skill 목록

**template-upstream** — 하위 프로젝트에서 발견한 좋은 패턴을 `proposals/draft/`에 제안서로 올립니다. 제안서에는 `localdocs/`의 learn 파일, ADR, worklog 항목 같은 근거를 포함해야 합니다. 근거 없는 제안서는 약한 후보로 취급됩니다.

**template-proposal-review** — `proposals/draft/`에 쌓인 제안서를 검토합니다. "모든 하위 프로젝트에 도움이 되는가", "프로젝트 고유 값이 제거되었는가", "실제 채택 근거가 있는가" 같은 기준으로 판단한 뒤 `accepted/`, `rejected/`, 또는 보류로 분류합니다.

**template-downstream** — 템플릿의 최신 `.claude/`, `.mcp.json`, `.pre-commit-config.yaml`을 하위 프로젝트에 반영합니다. 전략은 diff-aware update입니다. 업스트림에 있는 파일만 갱신하고, 하위 프로젝트에만 있는 파일은 건드리지 않습니다.

**template-broadcast** — `template-downstream`을 등록된 모든 하위 프로젝트에 일괄 적용합니다. 프로젝트 목록은 `.claude/skills/template-broadcast/references/projects.md`에서 관리합니다. 한 프로젝트에서 실패해도 나머지는 계속 진행합니다.

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
