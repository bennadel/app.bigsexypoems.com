---
name: reflect
description: Review CLAUDE.md, auto-memory, WIP docs, and skills against recent development activity for accuracy, compaction, drift, and cross-file consistency.
---

# Reflect on Application Context

Perform a comprehensive review of the project's context files — CLAUDE.md, auto-memory, WIP documents, and skill definitions — against recent development activity. The goal is to keep these files accurate, concise, and aligned with how the codebase actually works today.

Read `rubric.md` (in this skill directory) before analyzing. It defines what makes a CLAUDE.md entry worth adding or keeping, and helps distinguish high-value findings from noise.

## Step 1: Gather Context

1. Read `CLAUDE.md` at the project root.
2. Read `rubric.md` in this skill directory.
3. Read all auto-memory files in the `.claude/projects/` memory directory (if any exist).
4. Read all `.claude/wip/*.md` files (if any exist).
5. Read all `.claude/skills/*/SKILL.md` and companion files (e.g., `patterns.md`).
6. Check for a last-reflect marker at `.claude/last-reflect`. If it exists, read the commit hash and scope the git history: `git log --oneline <hash>..HEAD`. If it doesn't exist, fall back to `git log --oneline -30`.
7. For commits that match the signals below, run `git show --stat <hash>` to understand what files were touched.

### Signals that indicate context-relevant changes

Look for these specific patterns in commit subjects and touched files:

| Signal | What it means |
|--------|---------------|
| New `*Cascade.cfc`, `*Access.cfc`, `*Service.cfc` | New entity lifecycle patterns |
| Commits touching `cfmlx.cfm` | New or changed global utility functions |
| Commits touching `_shared/tag/` | New shared tags (may need entry-point imports) |
| Commits modifying `CLAUDE.md` | Recent context updates — check for completeness |
| Merge commits | Completed feature branches — check for stale WIP docs |
| Commit messages with "pattern", "convention", "refactor", "restructure" | Architecture decisions |
| New directories under `cfml/app/client/` | New subsystem routes |
| New `.sql` files in `cfml/app/db/` | Database conventions |
| New `*Sanitizer.cfc` files | HTML sanitization patterns |
| Commits touching `UI.cfc` | New UI helper methods |

## Step 2: Scan for Undocumented Patterns

Use structured searches — Grep and Glob first, Read to confirm — rather than browsing.

### Entity component inventory

Glob for `*Model.cfc`, `*Gateway.cfc`, `*Validation.cfc`, `*Service.cfc`, `*Access.cfc`, `*Cascade.cfc`, `*Sanitizer.cfc` under `cfml/app/core/lib/model/` and `cfml/app/core/lib/service/`. Cross-reference with what CLAUDE.md documents:

- Are there new entity types not mentioned in CLAUDE.md?
- Have new component types (e.g., `*Sanitizer.cfc`) become a recurring convention worth documenting?
- Have entities gained or lost Service/Access/Cascade components since CLAUDE.md was last updated?

### Shared component inventory

Glob for `cfml/app/client/_shared/tag/*.cfm`. Check whether recently added tags need:
- Mention in CLAUDE.md
- Explicit import statements in subsystem entry points (e.g., `member.js`, `share.js`)

### Utility function inventory

Read `cfml/app/core/cfmlx.cfm` and compare the actual function list against the "Global Extensions" section in CLAUDE.md. Flag additions, removals, and category mismatches.

### UI helper inventory

Grep for public methods in `UI.cfc`. Compare against any UI helper lists in CLAUDE.md or in the security-review skill's safe-pattern list. New helpers that aren't listed will cause false positives in security reviews.

## Step 3: Check for Drift

Verify specific CLAUDE.md claims against the actual codebase. Apply the severity labels below — they determine finding priority in the final report.

| Check | Severity | How to verify |
|-------|----------|---------------|
| Key Directories tree | HIGH | `ls` the actual directories and compare |
| `cfmlx.cfm` function list | HIGH | Read the file, diff against documented list |
| Client subsystem names | MEDIUM | Glob `cfml/app/client/*/` |
| Build commands | MEDIUM | Read `package.json` and `docker-compose.yml` |
| Entity pattern description | MEDIUM | Spot-check 2-3 entity directories for Model/Gateway/Validation |
| Form field patterns | LOW | Spot-check 2-3 `.view.cfm` files for `ui.nextFieldId()` usage |
| Code formatting examples | LOW | Spot-check 2-3 `.cfc` files for section comment style |

**Severity definitions:**

- **HIGH** — Will actively mislead Claude into generating incorrect code or structure
- **MEDIUM** — Could cause confusion or suboptimal output, but won't break things
- **LOW** — Minor inaccuracy or style drift, unlikely to cause real problems

## Step 4: Analyze for Compaction

Review CLAUDE.md for opportunities to tighten without losing information. Apply the rubric from `rubric.md` to assess whether each section earns its space.

- **Redundancy**: Are any concepts explained in multiple sections? (Common between "Architecture" and code formatting sections.)
- **Verbosity**: Could prose be replaced with a bullet or shorter phrasing?
- **Stale content**: Do any sections describe something that no longer matches reality? (Cross-reference with Step 3.)
- **Code examples**: Are any examples longer than needed to illustrate the point? Could an example be trimmed by a few lines and still convey the pattern?
- **Section organization**: Could sections be merged or reordered for better flow?
- **Low-value entries**: Do any sections document patterns that are single-use, obvious, or unstable? (Apply the rubric's "Three File Test.")

## Step 5: Reconcile Auto-Memory

If auto-memory files exist (in `.claude/projects/*/memory/`), evaluate each entry:

| Action | Criteria |
|--------|----------|
| **Promote** | Pattern confirmed across multiple interactions, not yet in CLAUDE.md. Recommend adding to CLAUDE.md and removing from auto-memory. |
| **Deduplicate** | Entry already covered by CLAUDE.md. Recommend removing from auto-memory. |
| **Contradict** | Entry conflicts with CLAUDE.md. Flag for resolution — which source is correct? |
| **Keep** | Valid but too narrow or session-specific for CLAUDE.md. Leave in auto-memory. |

If `MEMORY.md` says "No additional notes beyond what's documented in the project's CLAUDE.md" and no other memory files exist, note this step as clean and move on.

## Step 6: Review WIP Documents

For each file in `.claude/wip/`:

1. Read the document to understand what feature it describes.
2. Search git history for evidence the feature has shipped — look for merge commits, related file additions, or keywords from the PRD.
3. Classify and recommend:

| Status | Evidence | Recommendation |
|--------|----------|----------------|
| **Shipped** | Merge commit exists, feature files are in the codebase | Flag for removal. Note which commits completed the feature. |
| **In progress** | Feature branch exists or partial implementation found | Check whether the PRD still reflects current plans (it may have drifted during implementation). |
| **Abandoned** | No recent activity, no related branch | Flag for removal if the feature appears shelved. |

If `.claude/wip/` doesn't exist or is empty, note this step as clean and move on.

## Step 7: Cross-Skill Consistency

Check whether recent CLAUDE.md or codebase changes need to be reflected in skill definitions.

### Security-review safe patterns

The security-review skill's `patterns.md` lists safe patterns that should NOT be flagged (e.g., `ui.*` helpers, encoding functions, pre-sanitized `*Html` fields). Check for:

- New `ui.*` methods in `UI.cfc` not listed in the security-review's safe-pattern table
- New encoding functions in `cfmlx.cfm` not listed as safe
- New `*Html` fields (from new Sanitizer components) not listed as safe pre-sanitized output
- New subsystems or directories that should be in the security-review's scan scope

### Skill-to-CLAUDE.md references

If a skill references a CLAUDE.md concept by name (e.g., "the maybe pattern", "the cascade delete pattern"), verify that CLAUDE.md still describes it with that name and meaning.

### Skill scope alignment

If new entity types, subsystems, or component categories were added, check whether skills that scan specific directories need their scope expanded.

## Step 8: Present Findings

Organize findings by severity (HIGH first), then by category.

### Report format

```
## Summary

HIGH:   [count]
MEDIUM: [count]
LOW:    [count]
CLEAN:  [count of steps with no findings]
```

### Findings

For each finding:

```
### [Category] — [SEVERITY]

**What**: The specific change recommended.
**Why**: The reasoning (drift, compaction, missing pattern, cross-skill gap, etc.).
**Where**: The file and section affected.
```

Group related findings under the same category header when they affect the same file or section.

### Rules

- Do NOT make any edits automatically. Present findings and let the user decide which changes to make.
- The user may want to discuss, adjust, or reject individual suggestions before anything is changed.
- After presenting findings, offer to update the last-reflect marker at `.claude/last-reflect` with the current HEAD commit hash so the next `/reflect` run can scope its analysis to only new commits.
- Keep the tone collaborative — this is a maintenance review, not a critique.
