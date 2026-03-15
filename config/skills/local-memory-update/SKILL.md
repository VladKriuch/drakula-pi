---
name: local-memory-update
description: Save a significant project decision, technical choice, or status snapshot as a project memory file.
---

# Local Memory Update

Save something significant from the current session as a project memory file.

## File location

`.pi/memory/` in the current project root. Create the directory if it doesn't exist.

## File naming

`YYYY-MM-DD-short-title.md`

- Date = today's date
- Title = 2-5 word slug describing what this memory is about, lowercase, hyphens
- Example: `2026-03-15-auth-architecture-decided.md`

## What to save

Anything that would be useful context in a future session on this project:
- Architecture decisions and the reasoning behind them
- Technical choices (why library X over Y, why this pattern)
- What was tried and didn't work, and why
- Project status snapshots — what's done, what's next
- Conventions established during the session
- Bugs found and how they were resolved
- Dependencies or constraints discovered

## What NOT to save

- Things already in the project's AGENTS.md or README
- Generic knowledge not specific to this project
- Temporary debugging notes

## Format

```markdown
# [Title]
Date: YYYY-MM-DD

## What happened
Brief factual summary — what was worked on, what was decided.

## Key decisions
The choices made and why. Include what was considered and rejected.

## What to remember
Context a future session should know — current state, gotchas, next steps.
```

Write one file per significant topic. If the session covered multiple distinct things, write multiple files.
