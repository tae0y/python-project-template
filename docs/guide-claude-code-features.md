# Understand Claude Code Building Blocks

이 문서는 템플릿을 구성하는 Claude Code의 네 가지 빌딩 블록을 설명합니다. 상세 내용은 [.claude/claude-code-features.md](../.claude/claude-code-features.md)를 참고하세요.

- **Commands** — `.claude/commands/`에 저장하는 재사용 가능한 프롬프트 템플릿입니다. `/project:<name>`으로 호출합니다.
- **Hooks** — 도구 호출 전후에 자동 실행되는 셸 스크립트입니다. `PreToolUse`에서 non-zero로 나가면 해당 동작이 차단됩니다.
- **Skills** — 도메인별 지식 정의입니다. 명시적으로 호출하지 않아도 관련 맥락이 감지되면 자동으로 적용됩니다.
- **Agent Teams** — 여러 Claude Code 세션이 메시징과 공유 태스크 리스트로 협업하는 실험적 오케스트레이션 모드입니다.
