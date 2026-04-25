# Markdown Reading Guidelines

When reading a markdown file, apply a two-step pattern for files longer than ~100 lines where only a specific section is needed.

**Step 1 — scan headings:**

```bash
grep -n "^#" <file.md>
```

**Step 2 — read the target section:**

Use the `Read` tool with `offset` and `limit` to load only the relevant lines.

For short files or when full context is needed, skip Step 1 and read directly.
