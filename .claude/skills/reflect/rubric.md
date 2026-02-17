# CLAUDE.md Entry Rubric

Use this rubric to evaluate whether a pattern deserves a CLAUDE.md entry and whether existing entries earn their space.

## What Makes a High-Value Entry

A pattern belongs in CLAUDE.md when it meets **two or more** of these criteria:

| Criterion | Question to ask |
|-----------|-----------------|
| **Cross-cutting** | Does it appear in 3+ files or apply across multiple subsystems? |
| **Non-obvious** | Would a developer (or Claude) guess wrong without being told? |
| **Consequential** | Does getting it wrong cause bugs, security issues, or significant rework? |
| **Stable** | Has it survived the last several features without changing? |

### Examples of high-value entries

- "All `.cfc` files are script-based except `*Gateway.cfc`" — cross-cutting, non-obvious, consequential
- "Never run `npm` directly on the host machine" — consequential, non-obvious
- "Services should not call other services laterally" — cross-cutting, consequential, non-obvious
- "Use `ORDER BY id DESC` instead of date columns" — non-obvious, consequential
- "The XSRF module must be inside every POST form" — cross-cutting, security-consequential

## What Makes a Low-Value Entry

Avoid adding entries that have these characteristics:

| Characteristic | Why it's low-value |
|----------------|-------------------|
| **Single-use** | Only relevant to one file or component — document in that file's comments instead |
| **Obvious** | Standard language features or framework behavior any CFML developer would know |
| **Volatile** | Likely to change with the next feature — will become stale quickly |
| **Redundant** | Already enforced by tooling, linting, or compiler errors |
| **Over-specific** | Describes implementation details rather than a reusable pattern |

### Examples of low-value entries

- "The login form posts to /auth/login" — too specific, only one file
- "Use `var` to scope local variables" — obvious CFML practice
- "Alpine.js version is 3.15" — volatile, changes with upgrades
- "The poem table has columns id, name, content" — schema belongs in migrations

## The "Three File" Test

When considering a new CLAUDE.md entry, search the codebase for at least 3 files that follow the pattern. If fewer than 3 exist, the pattern is likely:

- **Too new** — wait for it to stabilize across more features
- **One-off** — document inline in the relevant file
- **Aspirational** — an intended convention, not an established one

**Exception**: Constraints and prohibitions ("never do X") are worth documenting even without 3 file examples. A single footgun that would cause real damage justifies a CLAUDE.md entry.

## Compaction Heuristics

When reviewing existing entries for trimming:

- **Can it be a bullet instead of a paragraph?** Most architectural preferences work better as a bold label + one-sentence explanation. The current CLAUDE.md already uses this style well.
- **Is the code example earning its space?** An example should illustrate something prose alone can't convey. If the prose is sufficient, cut the example. If the example is sufficient, cut the prose. Don't keep both when one will do.
- **Is the same concept explained twice?** Check across sections — a pattern sometimes appears in "Architecture Preferences" and also in a formatting or code example section.
- **Would removing this entry cause Claude to generate wrong code?** If the answer is no, the entry is probably low-value. If the answer is "maybe, in edge cases," it's medium-value. If the answer is "yes, definitely," it's high-value.
- **Is this entry growing the file past its useful size?** CLAUDE.md is loaded into every conversation. Every line competes for attention. An entry that adds length without proportional value makes all other entries slightly less effective.
