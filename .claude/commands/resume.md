Resume the current work session by loading active context from localdocs/.

Steps:
1. Read `localdocs/worklog.doing.md` — identify the active task and last recorded state.
2. Read `localdocs/worklog.todo.md` — list what's queued next.
3. Find and read the active plan file: glob `localdocs/plan.*.md`, read the most recently modified one.
4. Find and read the most recently modified `localdocs/learn.*.md` — recall recent discoveries.

Then summarize in this format:

**Active task:** [task name from worklog.doing.md]
**Last state:** [last bullet or checkpoint recorded]
**Plan phase:** [current phase from plan file, e.g. "Phase 2 — Step 3"]
**Up next (todo):** [first 2–3 items from worklog.todo.md]
**Recent learning:** [one-line summary of most recent learn file]

End with: "Ready to continue. What's the next step?"
