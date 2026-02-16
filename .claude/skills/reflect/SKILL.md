---
name: reflect
description: Review CLAUDE.md and recent git history for maintenance opportunities — compaction, missing patterns, outdated guidance, and reconciliation.
---

# Reflect on CLAUDE.md

Perform a careful review of the project's `CLAUDE.md` file in the context of recent development activity. The goal is to keep the file accurate, concise, and aligned with how the codebase actually works today.

## Step 1: Read the current state

1. Read `CLAUDE.md` at the project root.
2. Run `git log --oneline -30` to see recent commits.
3. For any commits that look like they introduced new patterns, conventions, or architectural changes, run `git show --stat <hash>` to understand what files were touched.
4. Read the auto-memory files in `.claude/projects/` if they exist (these may contain session-learned patterns that haven't been promoted to CLAUDE.md yet).

## Step 2: Analyze for compaction

Look for opportunities to tighten the CLAUDE.md without losing information:

- **Redundancy**: Are any concepts explained more than once in different sections?
- **Verbosity**: Are any explanations longer than they need to be? Could prose be replaced with a bullet list or a shorter phrasing?
- **Stale content**: Do any sections describe something that no longer matches the actual codebase? (Cross-reference with the files on disk if uncertain.)
- **Code examples**: Are any code examples longer than necessary to illustrate the point? Could they be trimmed?
- **Section organization**: Are there sections that could be merged or reordered for better flow?

## Step 3: Analyze git history for undocumented patterns

Review the recent commits for patterns or conventions that should be reflected in CLAUDE.md but aren't:

- **New entity types**: Were new Model/Gateway/Validation/Service/Access/Cascade components added that suggest patterns not yet documented?
- **New UI patterns**: Were new `.view.cfm` / `.view.less` / `.view.js` patterns introduced?
- **New shared components**: Were new shared tags or layouts added to `_shared/`?
- **Architecture decisions**: Do commit messages or code changes reveal architectural preferences not captured in the "Architecture Preferences" section?
- **New utilities or helpers**: Were new functions added to `cfmlx.cfm` or new utility components created?
- **Database patterns**: Do recent migrations reveal SQL conventions not documented?
- **Repeated commit patterns**: Are there recurring themes in commit messages that suggest a workflow or convention worth documenting?

## Step 4: Check for drift between CLAUDE.md and reality

Spot-check a few claims in CLAUDE.md against the actual codebase:

- Does the Key Directories tree still match the actual directory structure?
- Are the listed `cfmlx.cfm` utilities still accurate?
- Do the subsystem names in the client directory match what's listed?
- Are the build commands still correct?

## Step 5: Present findings

Organize your findings into clear categories and present them as actionable suggestions. For each suggestion, explain:

- **What**: The specific change you'd recommend.
- **Why**: The reasoning (compaction, accuracy, missing pattern, etc.).
- **Where**: The section of CLAUDE.md affected.

Do NOT make any edits to CLAUDE.md automatically. Present the findings and let the user decide which changes to make. The user may want to discuss, adjust, or reject individual suggestions before anything is changed.

Keep the tone collaborative — this is a maintenance review, not a critique.
