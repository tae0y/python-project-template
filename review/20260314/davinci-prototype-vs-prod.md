# Da Vinci Define: 빠른 프로토타입 vs 정식 구현 구분

> 2026-03-14 세션 패턴 분석(`review-20260314.md`) 기반 문제 정의

**Situation**: "초반 단순 구현 → API 명세 불일치/스키마 문제 → 재설계 사이클"이 반복됨. 이를 막기 위해 작업 단계 선언(SPIKE/MVP/PROD) 규칙을 제안했으나, 구분 기준 자체를 먼저 정의해야 할 시점.

**Tension**: 언제 "이건 프로토타입이다"라고 선언해야 하는지 불명확. 결과적으로 매번 무의식적으로 프로토타입을 정식 구현처럼 다듬게 됨.

**Mode**: Sample (Dimostrazione + Sfumato + Connessione)

---

## Dimostrazione — 경험을 통한 검증

재설계가 필요했던 이유는 단일하지 않다. 두 가지 가능성이 공존한다.

- **가설 A**: PROD 의도인데 SPIKE로 시작한 것 → `real-estate-mcp` OAuth 구현이 해당
- **가설 B**: 프로토타입임을 선언하지 않아 Claude가 과도하게 polish함 → `that-night-sky` 레이아웃 수정이 해당

단일한 "단계 선언" 규칙 하나로는 두 케이스를 모두 커버하지 못한다.

**Self-check:**
- 재설계가 필요했던 마지막 케이스의 원인은 "잘못된 설계"였나, "잘못된 기대치 설정"이었나?
- "단계 선언" 없이도 자연스럽게 SPIKE 모드로 돌아갔던 적이 있나? 그때는 무엇이 달랐나?

**Experiment**: 다음 신규 작업 시작 시 세션 첫 메시지에 "이건 SPIKE / 이건 MVP"를 명시하고, Claude의 응답 방식이 달라지는지 2~3 세션 관찰.

---

## Sfumato — 모호함과 불확실성 포용

SPIKE→MVP→PROD는 연속적 스펙트럼이지, 이분법이 아니다. 지나치게 명확하게 선언하려 할 때 역설이 생긴다.

- "프로토타입이니 품질을 낮춰도 된다" → 기술 부채를 의도적으로 만드는 허가증이 될 수 있다.
- "정식 구현은 처음부터 완벽해야 한다" → 설계 단계의 과도한 지연이나 분석 마비를 낳을 수 있다.

**Self-check:**
- SPIKE로 시작해서 PROD까지 간 코드가 있나? 그 코드의 품질은?
- "완벽한 설계 후 구현"이 실제로 재설계를 줄여주었다는 증거가 있나?

**Experiment**: 다음 SPIKE 코드에 `# SPIKE: 검증 후 삭제 예정` 주석을 달고, 실제로 지웠는지 추적.

---

## Connessione — 시스템 사고

작업 스타일에서 두 가지 패턴이 충돌하고 있다.

- **점진적 개선 선호** → SPIKE→MVP→PROD 흐름을 자연스럽게 타는 방식
- **설계 문서 선행** → PROD 수준의 설계를 먼저 확정하려는 경향

이 두 패턴이 충돌하는 지점에서 재설계 사이클이 발생했을 가능성이 높다. 실제 문제는 단계 선언 부재가 아니라, **plan 문서의 추상화 수준과 실제 코딩 의도의 불일치**일 수 있다.

**Self-check:**
- `localdocs/plan.*.md`를 SPIKE 단계에서도 작성하고 있나? 그 plan의 깊이가 SPIKE에 적합했나?
- SPIKE의 목표를 명시하는 란(예: "이 SPIKE로 검증할 가설")이 plan 템플릿에 있나?

**Experiment**: CLAUDE.md 단계 선언 규칙에 단계별 plan 문서 요구 깊이를 달리 명시.

---

## Synthesis

**Core insight**: 같은 `localdocs/plan` 형식이 모든 단계에 사용되면서, SPIKE 수준의 코드에 PROD 수준의 기대치가 자연스럽게 붙어버린다.

**Redefined problem**: "작업 단계를 어떻게 선언할까?"가 아니라 → **단계별로 plan 깊이와 코드 품질 기대치를 어떻게 다르게 설정할까?**

---

## 제안: CLAUDE.md 추가 규칙

```markdown
## 작업 단계 선언 (SPIKE / MVP / PROD)

세션 시작 시 단계를 선언한다. 선언이 없으면 PROD로 간주한다.

| 단계 | Plan 깊이 | 코드 품질 | 완료 기준 |
|------|-----------|-----------|-----------|
| SPIKE | 가설 + 검증 기준만 | 동작 확인만 | 가설 검증 여부 |
| MVP | 핵심 흐름 + 주요 엣지 케이스 | 기본 테스트 커버리지 | 핵심 사용자 시나리오 통과 |
| PROD | 전체 명세 | TDD + 문서화 | 배포 가능 품질 |
```

---

## 과거 재설계 사이클 역추적 (플랜 파일 분석)

### 케이스 1 — that-night-sky 모바일 레이아웃 (eager-coalescing-toucan + curious-fluttering-parnas)

**진행 흐름**:
1. Plotly `use_container_width=True` + CSS `position:fixed` div를 `st.markdown`으로 열고 닫는 패턴으로 구현
2. 모바일(375-390px)에서 3가지 문제 발생: iOS Safari 터치 미동작, 하단 공백, JS 불안정
3. **재설계**: "fixed div를 st.markdown으로 열고 닫는 패턴 완전 제거" 결정

**분류**: **PROD를 SPIKE처럼 시작** — CSS 패턴의 모바일 호환성을 사전 검증하지 않고 구현. 실제 기기에서만 문제가 드러남.

**만약 단계가 선언됐다면**: SPIKE("iOS Safari에서 position:fixed 패턴이 동작하는지 검증") → 실패 확인 → 다른 패턴으로 MVP 설계. 재설계가 아니라 SPIKE 완료 후 방향 전환이 됐을 것.

---

### 케이스 2 — real-estate-mcp OAuth 인증 (cached-puzzling-goblet)

**진행 흐름**:
1. Claude Desktop만 고려 — Caddy CEL expression으로 정적 Bearer token 처리
2. Claude Web / ChatGPT Web의 OAuth 입력란과 호환되지 않음 발견 (Client ID + Client Secret 필요)
3. **재설계**: FastAPI auth 컨테이너 추가, `/oauth/token` 엔드포인트, `AUTH_MODE` 환경변수 3가지 모드

**분류**: **PROD를 SPIKE처럼 시작** — "다양한 클라이언트의 OAuth 호환성"을 사전 조사하지 않고 단일 클라이언트만 지원하도록 구현. 나중에 확장 요구가 생기며 아키텍처 전체를 변경.

**만약 단계가 선언됐다면**: PROD 선언 시 plan 깊이 요구사항("전체 명세")에 따라 "지원할 클라이언트 목록"을 먼저 확정했을 것. 재설계보다 초기 설계 비용이 더 높지만 총 비용은 낮았을 것.

---

### 케이스 3 — TIL 대시보드 v1→v2 (reflective-bubbling-ripple → nested-stargazing-church)

**진행 흐름**:
1. v1: Python CLI가 정적 HTML의 마커 구간을 정규식으로 치환 — 데이터와 뷰가 하나의 HTML에 결합
2. 데이터 갱신마다 CLI 재실행 필요, 유지보수 어려움 발생
3. **재설계**: FastAPI 기반 로컬 웹 서버로 전환 (v2.0 MVP) — 데이터/뷰 분리, Jinja2 SSR

**분류**: **SPIKE를 PROD처럼 다룸** — 임시 CLI 스크립트로 시작했으나, 기능 요구가 점진적으로 추가되며 아키텍처 한계에 도달. SPIKE가 정착해버린 케이스.

**만약 단계가 선언됐다면**: v1에 `# SPIKE: 검증 후 삭제 예정` 주석 + "이 SPIKE로 검증할 가설: 정적 HTML 치환으로 충분한가?" 명시. 가설이 기각되는 시점에 v2 설계가 자연스럽게 시작됐을 것.

---

## 원인 분류 요약

| 케이스 | 프로젝트 | 분류 | 핵심 원인 |
|--------|---------|------|----------|
| 1 | that-night-sky 레이아웃 | PROD를 SPIKE처럼 시작 | CSS 패턴 호환성 검증 없이 구현 |
| 2 | real-estate-mcp OAuth | PROD를 SPIKE처럼 시작 | 클라이언트 요구사항 미조사 |
| 3 | TIL 대시보드 v1→v2 | SPIKE를 PROD처럼 다룸 | 임시 스크립트가 기능 추가되며 정착 |

**패턴**: 케이스 1, 2는 "사전 조사 부재"가 공통 원인. 케이스 3은 "SPIKE 탈출 기준 부재"가 원인. → 단계 선언 규칙은 **시작 시 선언**과 **SPIKE 종료 기준** 두 가지를 모두 포함해야 함.

---

## 개정된 제안: CLAUDE.md 추가 규칙

```markdown
## 작업 단계 선언 (SPIKE / MVP / PROD)

세션 시작 시 단계를 선언한다. 선언이 없으면 PROD로 간주한다.

| 단계 | Plan 깊이 | 코드 품질 | 완료 기준 |
|------|-----------|-----------|-----------|
| SPIKE | 가설 + 검증 기준만 | 동작 확인만 | 가설 검증 여부 (pass/fail) |
| MVP | 핵심 흐름 + 주요 엣지 케이스 | 기본 테스트 커버리지 | 핵심 사용자 시나리오 통과 |
| PROD | 전체 명세 (클라이언트/호환성 포함) | TDD + 문서화 | 배포 가능 품질 |

SPIKE 코드에는 `# SPIKE: [검증할 가설] — 검증 후 삭제 예정` 주석을 달고,
가설이 기각되면 삭제, 통과되면 MVP로 재설계한다 (SPIKE 코드를 PROD에 그대로 올리지 않는다).
```

---

## 다음 액션

- **24시간**: CLAUDE.md에 위 표 포함 단계 선언 규칙 추가 (SPIKE 종료 기준 포함)
- **스킬 설계 연계**: `streamlit-responsive`, `fastapi-scaffold` 스킬에 SPIKE/PROD 모드 파라미터 추가 여부 검토
