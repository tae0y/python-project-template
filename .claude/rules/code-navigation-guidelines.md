# Code Navigation Guidelines

When exploring the codebase — locating symbols, tracing call hierarchies, finding definitions — use **jcodemunch-mcp** before reading files directly.

Prefer in this order:
1. `jcodemunch` symbol/semantic search → get precise location
2. Read only the targeted file/range

Do not read entire files to find a symbol when jcodemunch can return it directly.

Start each session by calling `jcodemunch_guide` to load agent instructions.
