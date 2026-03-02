# Proposal: Fix check-new-test-file hook unconditionally blocking file creation

**Date:** 2026-03-02
**Source project:** TIL (Obsidian vault)
**Category:** hook
**Status:** applied

## Summary

`check-new-test-file.sh` hook은 새 `test_*.py` 파일 생성 시 경고를 출력하고 `exit 2`로 무조건 차단한다. 경고 메시지는 "확인 후 진행하세요"라는 톤이지만 실제로는 통과할 수 없어, Claude Code가 Write 도구로 테스트 파일을 생성할 수 없는 교착 상태가 발생한다. `exit 0`으로 변경하여 경고만 출력하고 통과시키는 방식으로 개선한다.

## Motivation

vault-dashboard v2 프로젝트에서 `vault-dashboard/tests/test_data.py`를 Write 도구로 생성하려 할 때, hook이 4회 연속 차단했다. 메시지를 읽고 3개 체크리스트를 모두 충족하는지 확인·설명했지만, exit code가 2이므로 승인 방법이 없었다.

hook의 원래 의도는 "테스트가 실제 함수를 호출하는지 한 번 생각하게 만드는 것"인데, 현재 구현은 경고가 아니라 금지이다. Claude Code의 hook 시스템에서 `exit 2`는 "도구 실행 거부"를 의미하며, 재시도해도 동일하게 차단된다.

### Evidence from localdocs

No localdocs evidence — 이 프로젝트(TIL vault)에는 localdocs/learn, adr, worklog 파일이 없다. 대신 실제 세션에서 4회 연속 블로킹된 직접 경험이 근거이다.

| Artifact | Location | What it shows |
|----------|----------|---------------|
| 세션 기록 | 현재 대화 | Write 도구로 test_data.py 생성 시 4회 연속 exit 2로 차단됨 |

## Proposed Change

### Target path(s) in template

`.claude/hooks/check-new-test-file.sh`

### Content

```diff
--- a/.claude/hooks/check-new-test-file.sh
+++ b/.claude/hooks/check-new-test-file.sh
@@ -1,5 +1,6 @@
 #!/bin/bash
-# Hook: PreToolUse — Warn when writing a new test_*.py file
+# Hook: PreToolUse — Warn (non-blocking) when writing a new test_*.py file
+# Prints a reminder checklist but allows file creation to proceed.
 # Pattern 2: No indirect solutions — never bypass the real function under test

 INPUT=$(cat)
@@ -32,4 +33,5 @@
 it passes while hiding actual bugs.
 EOF

-exit 2
+# exit 0: warn but allow — Claude Code treats exit 2 as hard block
+exit 0
```

## Caveats

- `exit 0`으로 바꾸면 경고 메시지가 stderr로 출력되지만 파일 생성은 진행된다. Claude Code는 이 stderr 출력을 컨텍스트에 표시하므로 경고 효과는 유지된다.
- 만약 hard block이 의도였다면 메시지를 "이 파일은 생성할 수 없습니다"로 변경하는 것이 더 정직하다. 현재 메시지("확인하세요")와 동작(차단)이 불일치한다.

## Review checklist

- [x] No conflict with existing template files
- [x] All project-specific values removed (paths, domains, secrets)
- [ ] Downstream sync test needed after applying via template-downstream
- [x] localdocs evidence cited (or absence explicitly noted)
