---
name: tdd
description: Test-Driven Development workflow. Use for ALL code changes - features, bug fixes, refactoring. TDD is non-negotiable.
---

# Test-Driven Development

TDD is the fundamental practice. Every line of production code must be written in response to a failing test.

This skill focuses on the TDD workflow/process.

---

## RED-GREEN-REFACTOR Cycle

### RED: Write Failing Test First
- NO production code until you have a failing test
- Test describes desired behavior, not implementation
- Test should fail for the right reason

### GREEN: Minimum Code to Pass
- Write ONLY enough code to make the test pass
- Resist adding functionality not demanded by a test
- Commit immediately after green

### REFACTOR: Assess Improvements
- Assess AFTER every green (but only refactor if it adds value)
- Commit before refactoring
- All tests must pass after refactoring

---

## TDD Evidence in Commit History

### Default Expectation

Commit history should show clear RED → GREEN → REFACTOR progression.

**Ideal progression:**
```
commit abc123: [MAINTENANCE] Add failing test for user authentication
commit def456: [NEW FEATURE] Implement user authentication to pass test
commit ghi789: [MAINTENANCE] Extract validation logic for clarity
```

### Rare Exceptions

TDD evidence may not be linearly visible in commits in these cases:

**1. Multi-Session Work**
- Feature spans multiple development sessions
- Work done with TDD in each session
- Commits organized for PR clarity rather than strict TDD phases
- **Evidence**: Tests exist, all passing, implementation matches test requirements

**2. Context Continuation**
- Resuming from previous work
- Original RED phase done in previous session/commit
- Current work continues from that point
- **Evidence**: Reference to RED commit in PR description

**3. Refactoring Commits**
- Large refactors after GREEN
- Multiple small refactors combined into single commit
- All tests remained green throughout
- **Evidence**: Commit message notes "refactor only, no behavior change"

### Documenting Exceptions in PRs

When exception applies, document in PR description:

```markdown
## TDD Evidence

RED phase: commit c925187 (added failing tests for shopping cart)
GREEN phase: commits 5e0055b, 9a246d0 (implementation + bug fixes)
REFACTOR: commit 11dbd1a (test isolation improvements)

Test Evidence:
✅ 4/4 tests passing (7.7s with 4 workers)
```

**Important**: Exception is for EVIDENCE presentation, not TDD practice. TDD process must still be followed - these are cases where commit history doesn't perfectly reflect the process that was actually followed.

---

## Coverage Verification - CRITICAL

### NEVER Trust Coverage Claims Without Verification

**Always run coverage yourself before approving PRs.**

### Verification Process

**Before approving any PR claiming "100% coverage":**

1. Check out the branch
   ```bash
   git checkout feature-branch
   ```

2. Run coverage verification:
   ```bash
   uv run pytest --cov --cov-report=term-missing
   ```

3. Verify ALL metrics hit 100%:
   - Lines: 100% ✅
   - Statements: 100% ✅
   - Branches: 100% ✅
   - Functions: 100% ✅

4. Check that tests are behavior-driven (not testing implementation details)

**Watch for anti-patterns that create fake coverage (coverage theater).**

### Reading Coverage Output

Look for the "All files" line in coverage summary:

```
Name              Stmts   Miss  Cover   Missing
-------------------------------------------------
src/models.py        42      0   100%
src/services.py      38      0   100%
src/utils.py         15      0   100%
-------------------------------------------------
TOTAL               95      0   100%
```

✅ This is 100% coverage.

### Red Flags

Watch for these signs of incomplete coverage:

❌ **PR claims "100% coverage" but you haven't verified**
- Never trust claims without running coverage yourself

❌ **Coverage summary shows <100%**
```
TOTAL               95      8    92%
```
- This is NOT 100% coverage

❌ **"Missing" column shows line numbers**
```
src/services.py      38      5    87%   45-48, 52
```
- Lines 45-48 and 52 are not covered

❌ **Coverage gaps without exception documentation**
- If coverage <100%, document the reason and get approval

### When Coverage Drops, Ask

**"What business behavior am I not testing?"** — not "What line am I missing?"

---

## Development Workflow

### Adding a New Feature

1. **Write failing test** — describe expected behavior
2. **Run test** — confirm it fails (`uv run pytest`)
3. **Implement minimum** — just enough to pass
4. **Run test** — confirm it passes
5. **Refactor if valuable** — improve code structure
6. **Commit** — following project commit convention

### Workflow Example

```python
# 1. Write failing test
def test_reject_empty_user_names():
    result = create_user(id="user-123", name="")
    assert result.success is False  # ❌ Test fails (no implementation)

# 2. Implement minimum code
def create_user(id: str, name: str) -> CreateUserResult:
    if not name:
        return CreateUserResult(success=False, error="Name required")
    ...  # ✅ Test passes

# 3. Refactor if needed (extract validation, improve naming)

# 4. Commit
# git add . && git commit -m "[NEW FEATURE] Reject empty user names"
```

---

## Pull Request Requirements

Before submitting PR:

- [ ] All tests must pass
- [ ] All linting and type checks must pass
- [ ] **Coverage verification REQUIRED** - claims must be verified before review/approval
- [ ] PRs focused on single feature or fix
- [ ] Include behavior description (not implementation details)

---

## Refactoring Priority

After green, classify any issues:

| Priority | Action | Examples |
|----------|--------|----------|
| Critical | Fix now | Mutations, knowledge duplication, >3 levels nesting |
| High | This session | Magic numbers, unclear names, >30 line functions |
| Nice | Later | Minor naming, single-use helpers |
| Skip | Don't change | Already clean code |

For detailed refactoring methodology, load the `refactoring` skill.

---

## Anti-Patterns to Avoid

- ❌ Writing production code without failing test
- ❌ Testing implementation details (spies on internal methods)
- ❌ 1:1 mapping between test files and implementation files
- ❌ Using mutable module-level state or fixtures for shared test data
- ❌ Trusting coverage claims without verification
- ❌ Mocking the function being tested
- ❌ Redefining schemas in test files
- ❌ Factories returning partial/incomplete objects
- ❌ Speculative code ("just in case" logic without tests)


---

## Summary Checklist

Before marking work complete:

- [ ] Every production code line has a failing test that demanded it
- [ ] Commit history shows TDD evidence (or documented exception)
- [ ] All tests pass
- [ ] Coverage verified at 100% (or exception documented)
- [ ] Test factories used (no shared mutable state)
- [ ] Tests verify behavior (not implementation details)
- [ ] Refactoring assessed and applied if valuable
- [ ] Commit messages follow project convention (see `commit-convention.md`)
