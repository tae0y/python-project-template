Use Agent Teams with 5 teammates to review and debate the .claude/ directory files over 3 rounds.
Set --max-turns 15 for each teammate.

Before starting, all teammates must read:
- .claude/ (all files in current project)
- /Users/bachtaeyeong/10_SrcHub/real-estate-mcp/localdocs/worklog.done.md
- /Users/bachtaeyeong/10_SrcHub/real-estate-mcp/localdocs/adr/*.md
- /Users/bachtaeyeong/10_SrcHub/real-estate-mcp/localdocs/learn/*.md
- /Users/bachtaeyeong/10_SrcHub/that-night-sky/localdocs/worklog.done.md
- /Users/bachtaeyeong/10_SrcHub/that-night-sky/localdocs/adr/*.md
- /Users/bachtaeyeong/10_SrcHub/that-night-sky/localdocs/learn/*.md

Teammates:
1. Prompt Engineer – evaluates instruction quality, clarity, and prompt failure patterns visible in worklogs
2. Agent Harness Evangelist – identifies automation and parallelization opportunities in current workflows
3. Token CFO – challenges every proposal with token cost and ROI; pushes back on over-engineering
4. Code Quality Lead – cross-references .claude rules against actual patterns in ADRs and worklogs
5. Onboarding New Member – reads everything as a first-timer; flags assumptions and missing context

Round 1: Each teammate posts their independent analysis to the shared task list.
Round 2: Teammates respond directly to each other. CFO must challenge Evangelist. Prompt Engineer must respond to New Member's confusion points.
Round 3: Converge. Each teammate proposes exactly one highest-priority fix. Resolve conflicts through direct messaging.

Final output: Lead synthesizes findings and saves the full report to .claude/review-YYYYMMDD.md (use today's date).
The report must include:
- Prioritized action list (with owner persona per item)
- Unresolved disagreements with explicit trade-off statements
- One-paragraph verdict on whether the current .claude setup is helping or hindering this developer's workflow
