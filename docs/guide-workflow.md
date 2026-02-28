# 워크플로우: 계획 - 구현 - 문서화 - 가드

```
[새 작업]              [세션 재개]
    |                      |
    v                      v
 prd (선택)          /project:resume-work
    |                      |
    v                      v
 planning ─────────> execution loop
    |                      |
    |   worklog (자동)      |
    v                      v
 implementation ──────> commit gate
 (tdd 자동 적용)       (check -> auto-fix -> approval)
    |
    v
 documentation (md-janitor, 선택)
```

작업이 시작되면 네 단계를 거칩니다.

## 계획

`planning` skill이 작업을 "알려진 좋은 단위(known-good increment)"로 쪼갭니다. 각 단위는 테스트가 통과하고, 한 커밋으로 들어가고, 한 문장으로 설명할 수 있어야 합니다. PRD가 필요하면 `prd` skill이 먼저 동작합니다.

## 구현

코드를 쓰는 동안 세 가지 skill이 항상 켜져 있습니다.

- `tdd` — RED-GREEN-REFACTOR 사이클을 강제합니다.
- `python-conventions` — PEP 8과 타입 힌트를 적용합니다.
- `refactoring` — 테스트가 GREEN이 되는 순간 리팩토링 기회를 평가합니다.

작업 진행 상황은 `worklog` skill이 자동으로 `localdocs/worklog.doing.md`와 `worklog.done.md`에 기록합니다. 구현 중에 발견한 gotcha나 패턴은 `localdocs/learn.<topic>.md`에 즉시 메모합니다.

## 지식 보존

피처가 완료되면 `localdocs/learn.<topic>.md`에 쌓인 내용을 두 곳으로 머지합니다.

- `learn` 에이전트 — gotcha와 반복 패턴을 CLAUDE.md에 반영합니다.
- `adr` 에이전트 — 아키텍처 결정을 `localdocs/adr/`에 ADR로 남깁니다.

## 문서화

문서를 쓸 일이 생기면 `md-janitor` skill이 일관된 마크다운 스타일을 적용합니다.

## 가드

커밋 전에 Pre-Commit Quality Gate가 순서대로 실행됩니다.

1. `check` — ruff lint, format, pyright, bandit으로 이슈를 탐지합니다 (read-only).
1. `auto-fix` — ruff가 고칠 수 있는 것은 자동으로 고칩니다.
1. `check` 재실행 — 깨끗한지 확인합니다.
1. Secrets scan — API 키, 토큰, `.env` 값이 코드에 들어가지 않았는지 검사합니다.

이 게이트를 통과해야 커밋 승인을 요청합니다.
