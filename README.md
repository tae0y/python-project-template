# Claude Code Python Template

![https://youtu.be/qMQ-y9dHE2k?si=Uau0_ezqGpwATL6m](resources/to_mars.png)
> A repo built on this template, heading to Mars.

A reusable `.claude/` configuration template for Claude Code Python projects. It enables fast, accurate prototyping and establishes a self-improvement loop grounded in documentation and evidence.

## Core Features

🔄 **Bidirectional template sync** — Keep downstream projects and this template in sync. When a downstream project discovers a useful pattern, it can propose changes upstream; the template consolidates and broadcasts updates back to all projects.

📝 **Documentation-driven self-improvement loop** — Every stage of development — planning, implementation, review, and retrospective — produces structured documents (ADRs, lessons-learned, trade-off analyses). These documents serve as the shared memory that lets both the human and the AI agent improve their own workflow over time: revisiting past decisions, correcting recurring mistakes, and refining the process itself based on evidence rather than intuition.

💡 **Creative and analytical thinking skills** — Beyond code generation, the template ships skills that reframe hard problems through structured thinking frameworks: `rethink-unblock` breaks circular reasoning with targeted reframing, `davinci-define` applies the seven Da Vincian principles to clarify goals and life choices, and `sparks-create` uses the 13 tools from *Sparks of Genius* to generate cross-disciplinary creative angles. Use these when conventional analysis stalls.

🛡️ **Python quality pipeline** — A pre-commit pipeline enforces Python conventions on every commit: `ruff` for linting and formatting, `bandit` for security scanning, and `pip-audit` for dependency vulnerability checks. The `check` skill runs all gates in read-only mode for inspection; `auto-fix` applies safe automated fixes.

> This workflow originated from [citypaul/.dotfiles](https://github.com/citypaul/.dotfiles).
> For details, see [Workflow: Plan-Implement-Document-Guard](docs/guide-development-workflow.md) and [Template Management Skill](docs/guide-template-management.md).

## Getting Started

1. Clone this repository.

    ```bash
    git clone https://github.com/tae0y/python-project-template.git my-project
    cd my-project
    ```

2. Set up the Python environment.

    ```bash
    uv sync
    ```

3. Install the pre-commit hook.

    ```bash
    pre-commit install --hook-type commit-msg
    ```

4. Initialize the local docs directory.

    ```bash
    mkdir -p localdocs/adr
    touch localdocs/worklog.todo.md localdocs/worklog.doing.md localdocs/worklog.done.md
    ```

    > **Note:** If needed, move the `.claude/skills.nouse/localdocs-til-link` skill into `.claude/skills/` and link `localdocs/` to your shared documentation folder.

5. Customize `CLAUDE.md` for your project. See `CLAUDE.sample.md` for reference.

6. The full directory structure looks like this:

    ```
    .claude/
    ├── WORKFLOW.md              # Workflow trigger map
    ├── settings.json            # Global settings
    ├── rules/                   # Behavioral rules applied to every response
    ├── commands/                # Reusable prompt templates
    ├── hooks/                   # Lifecycle shell scripts (pre-commit gate, convention checks)
    ├── skills/                  # Domain-specific capability definitions
    │   ├── tdd/                 # TDD workflow
    │   ├── planning/            # Task breakdown into known-good increments
    │   ├── check/               # Code quality inspection (ruff, pyright, bandit)
    │   ├── auto-fix/            # Lint & format auto-fix
    │   ├── rethink-unblock/     # Reframe stuck problems
    │   ├── davinci-define/      # Da Vincian principles for goal clarity
    │   ├── sparks-create/       # Cross-disciplinary creative thinking
    │   ├── template-broadcast/  # Batch rollout to all downstream projects
    │   └── ...
    ├── skills.nouse/            # Disabled skills (preserved for re-activation)
    └── agents/                  # Specialized sub-agent definitions
    ```
