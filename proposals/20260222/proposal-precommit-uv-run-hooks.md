# Proposal: Use `uv run` for bandit and pip-audit pre-commit hooks

**Date:** 2026-02-22
**Source project:** that-night-sky
**Category:** config
**Status:** rejected

## Summary

Replace the external-repo-based `bandit` and `pip-audit` pre-commit hooks with `local` hooks that invoke `uv run bandit` and `uv run pip-audit`. This aligns with the project's dependency management convention (uv) and avoids the version drift between the pinned pre-commit rev and the version installed in the project's virtual environment.

## Motivation

The template currently uses `repo: https://github.com/PyCQA/bandit` and `repo: https://github.com/pypa/pip-audit` to run these checks. This causes two problems:

1. **Version mismatch** — pre-commit manages its own isolated env with a pinned rev. If the project also pins bandit/pip-audit via uv, two separate versions exist and may produce different results.
2. **Inconsistency with project convention** — the template already uses `uv run pyright` as a local hook. bandit and pip-audit should follow the same pattern for uniformity.

Using `uv run` ensures checks run against the exact version installed in the project's venv, which is what developers see locally and what CI will use.

### Evidence from localdocs

No localdocs evidence — pattern is theoretical.

The rationale is consistency: `pyright` already uses `uv run` as a local hook in the template. Extending this to `bandit` and `pip-audit` completes the pattern.

## Proposed Change

### Target path(s) in template

- `.pre-commit-config.yaml`

### Content

Replace the external repo hooks for bandit and pip-audit:

```yaml
# BEFORE
  - repo: https://github.com/PyCQA/bandit
    rev: 1.9.3
    hooks:
      - id: bandit
        args: ["-c", "pyproject.toml"]

  - repo: https://github.com/pypa/pip-audit
    rev: v2.10.0
    hooks:
      - id: pip-audit
        stages: [manual]
```

With local hooks using `uv run`:

```yaml
# AFTER
      - id: bandit
        name: bandit
        entry: uv run bandit
        args: ["-r", "src/", "-c", "pyproject.toml"]
        language: system
        types: [python]
        pass_filenames: false

      - id: pip-audit
        name: pip-audit
        entry: uv run pip-audit
        language: system
        stages: [manual]
        pass_filenames: false
```

Both hooks go under the existing `repo: local` block alongside `pyright`.

Full `.pre-commit-config.yaml` after change:

```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.14.14
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: local
    hooks:
      - id: commit-msg-convention
        name: commit message convention
        entry: bash -c 'echo "$(<"$1")" | grep -qE "^\[(MAINTENANCE|NEW FEATURE|BREAKING CHANGES)\]" || { echo "Commit message must start with [MAINTENANCE], [NEW FEATURE], or [BREAKING CHANGES]"; exit 1; }'
        language: system
        stages: [commit-msg]
        always_run: true
        pass_filenames: false
        args: ["--"]

      - id: pyright
        name: pyright
        entry: uv run pyright
        language: system
        types: [python]
        pass_filenames: false

      - id: bandit
        name: bandit
        entry: uv run bandit
        args: ["-r", "src/", "-c", "pyproject.toml"]
        language: system
        types: [python]
        pass_filenames: false

      - id: pip-audit
        name: pip-audit
        entry: uv run pip-audit
        language: system
        stages: [manual]
        pass_filenames: false
```

## Caveats

- Downstream projects must have `bandit` and `pip-audit` in their `uv` dependencies (dev group). If not installed, hooks will fail at install time.
- The `bandit` args (`-r src/ -c pyproject.toml`) are a reasonable default but may need adjustment per project. Projects without a `src/` layout should update the path.
- Removes automatic rev pinning for bandit and pip-audit — version is now controlled by the project's `pyproject.toml` / `uv.lock`.

## Review checklist

- [ ] No conflict with existing template files
- [ ] All project-specific values removed (paths, domains, secrets)
- [ ] Downstream sync test needed after applying via template-downstream
- [ ] localdocs evidence cited (or absence explicitly noted)

**Rejection reason:** localdocs evidence 없음(theoretical only). Downstream이 bandit/pip-audit을 dev dep에 추가하지 않으면 hook install 단계에서 실패하는 숨은 전제가 있음. template 기본 pyproject.toml에 해당 패키지가 포함되는 시점 또는 실제 version mismatch 문제가 관찰된 이후 재검토.
