# Review-of-Review: External References 검토 충분성 평가

Date: 2026-03-07
Target: [review-20260307.md](review-20260307.md)

대상 리뷰가 아래 세 문서의 제안을 충분히 검토했는지 평가한다.

1. Claude Code의 컨텍스트 소비를 98% 줄이는 MCP 서버 (Context Mode)
2. Show GN: clenv – Claude Code 프로필 매니저
3. Making Claude Code Actually Remember Things (QMD + /recall)

---

## 요약

세 문서 모두 리뷰의 "External References Considered" (line 17-19)에서 인지하고, P3 #18-#20에서 각각 판단을 내렸다. 그러나 세 건 모두 **"지금은 필요 없다"는 결론의 근거가 정량적 검증 없이 추정에 의존**하고 있어 보완이 필요하다.

| 문서 | 인지 | 판단 적절성 | 분석 깊이 | 보완 필요 |
|------|------|------------|----------|----------|
| Context Mode MCP | O | 부분적 | 얕음 | **높음** |
| clenv | O | 적절 | 얕음 | 낮음 |
| QMD + /recall | O | 부분적 | 얕음 | **중간** |

---

## 1. Context Mode MCP — 정적/동적 컨텍스트 비용 구분 미흡

### 리뷰의 판단

P3 #18: "Monitor context usage first. Only build if sessions frequently hit context limits. The P0-P2 trimming may eliminate the need."

### 문제점

리뷰가 분석한 컨텍스트 비용(Context Budget Impact Summary, line 102-113)은 `.claude/` 내부 파일의 **정적 비용**(~18,000 tokens)에 한정된다. Context Mode가 해결하는 문제는 이와 성격이 다르다.

**정적 비용** — `.claude/` 규칙, 스킬, 에이전트 정의 등 세션 시작 시 고정 소비되는 토큰. 리뷰의 P0-P2 트리밍으로 ~30% 절감 가능.

**동적 비용** — MCP 도구 호출 결과물이 세션 중 누적되는 토큰. 원문에 따르면 Playwright 스냅샷 56KB, GitHub 이슈 20개 59KB 등 단일 호출만으로도 수만 토큰이 소비된다.

이 프로젝트에는 arxiv, context7, playwright, microsoft-learn 등 다수의 MCP 서버가 연결되어 있다. 리뷰는 line 113에서 "MCP server tool definitions... should be audited separately"라고 적었지만, 실제 측정이나 후속 계획을 제시하지 않았다.

P0-P2 트리밍으로 정적 비용을 5,500 tokens 줄여도, MCP 호출 한두 번이면 그 절감분이 상쇄된다. 두 문제는 독립적이므로 "P0-P2가 충분할 수 있다"는 논리는 성립하지 않는다.

### 보완 방안

- 실제 세션 1-2개에서 MCP 호출 결과물의 누적 토큰을 측정한다.
- 측정 결과가 세션 컨텍스트의 20% 이상을 차지하면 Context Mode 도입을 P1으로 격상한다.
- 측정 결과가 미미하면 현재 P3 유보를 유지하되, 근거 수치를 기록한다.

---

## 2. clenv — 판단은 적절, 근거 보강 필요

### 리뷰의 판단

P3 #20: "skills.nouse/ mechanism is sufficient for 2-profile scenario. Revisit if managing 5+ downstream projects."

### 평가

결론은 적절하다. clenv의 핵심은 `~/.claude`를 심볼릭 링크로 전환해 페르소나를 격리하는 것인데, 이 프로젝트는 템플릿 레포 단독 운영이고 다운스트림 관리는 `template-broadcast` 스킬로 처리하고 있다. 프로필 격리가 필요한 상황이 아니다.

### 보완 방안

판단 근거를 한두 문장 추가한다. 예시:

> 현재 user-level과 project-level 2개 프로필만 사용 중이며, 페르소나 전환 없이 단일 역할(Python 템플릿 관리자)로 운영한다. skills.nouse/ 디렉터리가 비활성 스킬 격리를 충분히 처리하고 있어 심볼릭 링크 기반 프로필 전환은 불필요하다.

---

## 3. QMD + /recall — 세션 재개 효과 미검증

### 리뷰의 판단

P3 #19: "Premature until localdocs corpus exceeds ~20 learn files. Current sequential reads are adequate."

### 문제점

**파일 수 기준의 오류.** QMD가 해결하는 핵심 문제는 "매 세션 시작 시 컨텍스트를 재구성하는 데 시간과 토큰이 낭비된다"는 것이다. 이 문제는 localdocs 파일이 5개든 50개든 발생한다. 파일 수를 도입 기준으로 삼은 것은 문제의 본질을 벗어난다.

**기존 메커니즘 효과 미평가.** 이 프로젝트는 이미 `resume-work` 스킬과 `worklog.doing.md`로 세션 재개를 시도하고 있다. 리뷰는 "현재 순차 읽기로 충분하다"고 했지만, 실제로 `resume-work`가 몇 토큰을 소비하고 얼마나 걸리는지 측정하지 않았다.

**검색 효율성 관점 누락.** 원문은 grep이 200개 파일에서 노이즈를 만드는 반면 BM25는 즉시 관련 결과를 반환한다고 비교했다. 이 관점은 Claude가 `Grep`/`Glob`으로 localdocs를 탐색할 때도 동일하게 적용되지만, 리뷰에서 다루지 않았다.

### 보완 방안

- `resume-work` 스킬 실행 시 소요 시간과 토큰 소비를 1-2회 측정한다.
- 세션 재개가 1분 이내, 토큰 2,000 이하로 완료되면 현재 방식을 유지한다.
- 세션 재개가 반복적으로 비효율적이면 BM25 기반 검색(QMD 또는 유사 도구) 도입을 검토한다.
- 도입 기준을 파일 수가 아닌 **세션 재개 비용**으로 변경한다.

---

## Action Items

| # | Action | 우선순위 | 예상 소요 |
|---|--------|---------|----------|
| R1 | MCP 호출 결과물의 세션 내 토큰 소비 측정 | **P1** | 30분 |
| R2 | 측정 결과에 따라 Context Mode 도입 여부 재판단 | P1 | 10분 |
| R3 | `resume-work` 스킬의 소요 시간/토큰 측정 | P2 | 15분 |
| R4 | clenv 유보 판단에 근거 문장 추가 | P2 | 5분 |
| R5 | QMD 도입 기준을 파일 수 → 세션 재개 비용으로 변경 | P2 | 5분 |

---

*Review-of-review conducted on 2026-03-07.*
*Source documents: TIL/300 Resource/Readwise/Full Document Contents/Articles/*
