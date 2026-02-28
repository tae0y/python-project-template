# README

Claude Code Python 프로젝트의 `.claude/` 설정을 재사용할 수 있도록 만든 템플릿입니다. 코드 품질 검사, TDD 워크플로우, 커밋 가드레일이 적용되어 있습니다.

- **양방향 템플릿 동기화** — 하위 프로젝트에서 발견한 좋은 패턴을 템플릿 프로젝트에 제안서로 올리고(upstream), 템플릿에 변경된 사항을 전체 프로젝트에 일괄로 반영할 수 있습니다(downstream/broadcast).

- **자동화된 워크플로우** — 계획 수립, TDD 구현, 지식 보존, 커밋 전 품질 검사까지 skill이 작업 흐름에 따라 자동으로 적용됩니다.

> 이 워크플로우는 [citypaul/.dotfiles](https://github.com/citypaul/.dotfiles)에서 출발했습니다.

## Getting Started

1. 이 레포를 복제합니다.

    ```bash
    git clone https://github.com/tae0y/python-project-template.git my-project
    cd my-project
    ```

1. Python 환경을 설정합니다.

    ```bash
    uv sync
    ```

1. pre-commit 훅을 설치합니다.

    ```bash
    pre-commit install --hook-type commit-msg
    ```

1. 로컬 문서 디렉토리를 초기화합니다.

    ```bash
    mkdir -p localdocs/adr
    touch localdocs/worklog.todo.md localdocs/worklog.doing.md localdocs/worklog.done.md
    ```

    > **참고:** 필요시 `.claude/skills.nouse/localdocs-til-link` Skill을 `.claude/skills` 폴더로 이동시키고 localdocs를 통합 문서 저장 폴더와 연결합니다.

1. `CLAUDE.md`를 프로젝트에 맞게 수정합니다.
   `CLAUDE.sample.md`를 참고하면 됩니다.

## Project Structure

```
.claude/
├── WORKFLOW.md              # 워크플로우 트리거 맵
├── claude-code-features.md  # ".claude" 관리를 위한 .claude 기능 설명
├── settings.json            # 전역 설정
├── rules/                   # 모든 응답에 적용되는 행동 규칙
├── commands/                # 재사용 프롬프트 템플릿
├── hooks/                   # 라이프사이클 쉘 스크립트
├── skills/                  # 도메인별 capability 정의
│   ├── tdd/                 # TDD 워크플로우
│   ├── planning/            # 계획 수립
│   ├── check/               # 코드 품질 검사
│   ├── auto-fix/            # 린트/포맷 자동 수정
│   ├── template-upstream/   # 패턴 제안 (프로젝트 -> 템플릿)
│   ├── template-downstream/ # 설정 동기화 (템플릿 -> 프로젝트)
│   ├── template-broadcast/  # 일괄 배포
│   └── ...
└── agents/                  # 전문 서브에이전트 정의
```

더 자세한 내용은 다음 문서를 참고하세요.

- [워크플로우: 계획-구현-문서화-가드](docs/guide-workflow.md)
- [템플릿 관리 skill](docs/guide-template-management.md)
