# Claude Code Python Template

![](resources/to_mars.png)
> A repo built on this template, heading to Mars.

A reusable `.claude/` configuration template for Claude Code Python projects. It enables fast, accurate prototyping and establishes a self-improvement loop grounded in documentation and evidence.

## Core Features

**Bidirectional template sync** — Keep downstream projects and this template in sync. When a downstream project discovers a useful pattern, it can propose changes upstream; the template consolidates and broadcasts updates back to all projects.

**Automated workflow** — An end-to-end workflow that covers planning, implementation, and verification. At each stage it autonomously produces feature specs, technical trade-off analyses, and lessons-learned documents.

> This workflow originated from [citypaul/.dotfiles](https://github.com/citypaul/.dotfiles).
> For details, see [Workflow: Plan-Implement-Document-Guard](docs/guide-workflow.md) and [Template Management Skill](docs/guide-template-management.md).

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
    ├── claude-code-features.md  # .claude feature reference
    ├── settings.json            # Global settings
    ├── rules/                   # Behavioral rules applied to every response
    ├── commands/                # Reusable prompt templates
    ├── hooks/                   # Lifecycle shell scripts
    ├── skills/                  # Domain-specific capability definitions
    │   ├── tdd/                 # TDD workflow
    │   ├── planning/            # Planning
    │   ├── check/               # Code quality checks
    │   ├── auto-fix/            # Lint & format auto-fix
    │   ├── template-upstream/   # Propose patterns (project → template)
    │   ├── template-downstream/ # Sync settings (template → project)
    │   ├── template-broadcast/  # Batch rollout
    │   └── ...
    └── agents/                  # Specialized sub-agent definitions
    ```
