# Product Requirements Document: Poem Revision System

**Document Version:** 1.0  
**Last Updated:** February 11, 2026  
**Author:** Ben  
**Feature Scope:** Schema design + windowing save strategy

---

## Overview

### Problem Statement
The Poems app saves revisions as-you-type, which creates an explosion of revision records during initial authoring. However, poem editing follows a distinct pattern: intense bursts of activity during initial writing, followed by occasional revisits and then permanent stasis. Without a compaction strategy, even a 20-minute initial authoring session could create hundreds of revisions.

### Solution Summary
Implement a simple **3-minute windowing strategy** where consecutive saves within a 3-minute window overwrite the previous revision, rather than creating a new one. Once the window closes (no save for 3+ minutes), the next save creates a new revision. This naturally compacts the bursty authoring phase into a small number of logical checkpoints while preserving the sparse revisit history.

### Business Goals
- Prevent explosion of revisions during initial poem authoring
- Enable users to view and restore previous editing sessions
- Maintain minimal storage footprint with zero cleanup overhead
- Keep implementation simple and predictable

---

## Current State & Assumptions

### Existing Poem Table
- `id`: unique identifier
- `userID`: owner of the poem
- `collectionID`: grouping mechanism
- `name`: poem title
- `content`: full poem text (varchar 3000 max)
- `createdAt` / `updatedAt`: timestamps

### Editing Pattern
- **Initial authoring**: Intense, bursty activity (20-60 minutes of active typing)
- **Occasional revisits**: Light edits 1-3 times over following 2-3 weeks
- **Permanent completion**: No further changes after revisits conclude
- **Save frequency**: On keystroke or regular interval (exact frequency TBD)

---

## Goals & Success Metrics

### Primary Goals
1. Create a simple schema that captures revision checkpoints
2. Implement windowing logic at save time (no post-hoc compaction needed)
3. Naturally group editing activity into logical sessions
4. Support restoration to any checkpoint
5. Keep storage growth minimal with zero maintenance

### Success Metrics
- Storage per poem: < 50KB even with dozens of editing sessions over lifetime
- Save operation latency: < 10ms (minimal overhead from windowing check)
- Revision count per poem: Typically 3-10 revisions total
- Zero background jobs or cleanup required

---

## Data Model: poem_revision Table

### Schema Design

```sql
CREATE TABLE `poem_revision` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `poemID` bigint unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `content` varchar(3000) NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `byPoem` (`poemID`),
  KEY `byPoemTime` (`poemID`, `updatedAt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

### Schema Notes
- **poemID**: Foreign key to poem table (for querying all revisions of a poem)
- **name**: Poem title at this revision (captures if name changed between saves)
- **content**: Full poem text at this checkpoint
- **createdAt**: When this revision window opened (first save in the window)
- **updatedAt**: When this revision was last updated (either initial creation or subsequent UPDATE within window)
- **Indexes**: `byPoemTime` allows efficient querying of revisions for a poem in chronological order
- **Note**: `userID` and `collectionID` are not needed—they're properties of the poem, not the revision. Can query poem table if needed.

### Why This Works
- Extremely simple, no flags or metadata needed
- No compaction logic in schema itself—compaction is handled purely at save time
- Full content stored (3000 char limit makes storage negligible)
- Windowing strategy means revisions are naturally sparse checkpoints, not granular saves

---

## Windowing Strategy

### Core Logic

When a save request comes in:

```
1. Query the most recent revision for this poem: last_rev = SELECT * FROM poem_revision WHERE poemID = ? ORDER BY updatedAt DESC LIMIT 1

2. Calculate time delta: delta = NOW() - last_rev.updatedAt

3. Decision:
   - If delta < 3 minutes:
       UPDATE poem_revision SET name = ?, content = ?, updatedAt = NOW() WHERE id = last_rev.id
   - Else:
       INSERT INTO poem_revision (poemID, name, content, createdAt, updatedAt) VALUES (?, ?, ?, NOW(), NOW())
```

### Why 3 Minutes?

A 3-minute window naturally groups related edits together. For a typical typing speed:
- User pauses to think: < 30 seconds → still in same window
- User goes for coffee: > 3 minutes → new checkpoint
- User returns next day: > 3 minutes → separate session

This matches how users conceptually experience their own editing: "I wrote this stanza", then later "I came back and rewrote the ending."

**Open Question**: Is 3 minutes the right window? Could be 2-5 minutes depending on your preference.

### Effect on Revision Count

**Example: Initial Authoring Burst**
```
0:00  - User starts editing, saves (INSERT) → Revision 1
5:30  - 5 minutes of typing, last save was 5:30 ago (> 3 min)
       → New save (INSERT) → Revision 2
10:15 - User rewrites stanza, saves 4m45s after Revision 2 (> 3 min)
       → New save (INSERT) → Revision 3
14:00 - User saves final version 3m45s later (> 3 min)
       → New save (INSERT) → Revision 4
20:00 - User takes a break (no more saves)
```
Result: 20 minutes of active editing → **4 revisions** (instead of 40-60 if saving every 30 seconds)

**Example: Revisit Session (2 weeks later)**
```
Day 14, 10:00 - User re-opens poem, makes small edits (3m45s after last save)
              → New save (INSERT) → Revision 5
Day 14, 10:05 - Makes one more tweak (5m since Revision 5)
              → New save (INSERT) → Revision 6
Day 14, 10:30 - Done editing, no more saves
```
Result: **2 new revisions** for the entire revisit session

**Final State**: Total of ~6 revisions across the poem's entire lifetime.

---

## Save Implementation

### Pseudocode

```
function savePoem(poemID, name, newContent):
    // Get last revision
    lastRevision = query:
        SELECT id, updatedAt FROM poem_revision 
        WHERE poemID = poemID 
        ORDER BY updatedAt DESC 
        LIMIT 1
    
    // Calculate time since last save
    if lastRevision exists:
        timeSinceLastSave = NOW() - lastRevision.updatedAt
    else:
        timeSinceLastSave = INFINITY  // First save
    
    // Apply windowing logic
    if lastRevision exists AND timeSinceLastSave < 3 minutes:
        // Update last revision (overwrite within window)
        UPDATE poem_revision 
        SET name = name,
            content = newContent, 
            updatedAt = NOW() 
        WHERE id = lastRevision.id
        
        return { action: "updated", revisionId: lastRevision.id }
    else:
        // Create new revision (window closed or first save)
        INSERT INTO poem_revision 
        (poemID, name, content, createdAt, updatedAt) 
        VALUES (poemID, name, newContent, NOW(), NOW())
        
        return { action: "created", revisionId: [new ID] }
```

### Query for Revision History

```sql
SELECT id, userID, savedAt 
FROM poem_revision 
WHERE poemID = ? 
ORDER BY savedAt DESC;
```

### Query to Restore to a Specific Revision

```sql
SELECT content 
FROM poem_revision 
WHERE id = ? AND poemID = ?;
```

---

## Use Cases & Queries

### Use Case 1: Show Revision Timeline
Display all revision checkpoints for a poem in reverse chronological order.

```sql
SELECT id, updatedAt 
FROM poem_revision 
WHERE poemID = ? 
ORDER BY updatedAt DESC;
```

Expected result: 3-10 revisions typically.

### Use Case 2: Restore to a Previous Version
User clicks "restore to this version", fetch and apply that revision's content.

```sql
SELECT content 
FROM poem_revision 
WHERE id = ? AND poemID = ?;
```

### Use Case 3: Show What Changed Between Two Versions
User wants to see diff between revision A and B. Fetch both contents and compare.

```sql
SELECT content FROM poem_revision WHERE id = ? AND poemID = ?;
SELECT content FROM poem_revision WHERE id = ? AND poemID = ?;
-- Client-side diff
```

---

## Implementation Strategy

### Phase 1: Foundation
- [ ] Create `poem_revision` table
- [ ] Implement `savePoem()` function with windowing logic
- [ ] Add endpoint: `GET /poem/{id}/revisions` (list all revisions)
- [ ] Add endpoint: `GET /poem/{id}/revision/{revisionId}` (fetch specific revision)
- [ ] Add endpoint: `POST /poem/{id}/restore/{revisionId}` (restore to version)

### Phase 2: UI Integration
- [ ] Display revision history sidebar/modal in editor
- [ ] Show timestamps for each revision
- [ ] Add restore button per revision
- [ ] (Optional) Add side-by-side diff view

### Phase 3: Polish
- [ ] Add tests for windowing logic (boundary cases at 2:59, 3:00, 3:01)
- [ ] Monitor revision counts in production (ensure they stay small)
- [ ] Consider pagination if revision list ever gets large (shouldn't happen)

---

## Edge Cases & Considerations

### Edge Cases
1. **First save**: No previous revision exists → Always INSERT (not UPDATE)
2. **Very rapid saves**: Browser crashes and recovers, two saves in 1 second → Second save UPDATEs first (expected behavior)
3. **Poem deletion**: Orphaned revisions in table (probably fine—they reference a non-existent poemID)
4. **User changing mind**: User overwrites content in current window, then wants old version back → Lost to UPDATE (but still have previous window's checkpoint)

**Question**: Is losing content within a 3-minute window acceptable? (You can always extend window if not.)

### Storage Analysis
- Per poem: ~5 KB per revision × avg 6 revisions = 30 KB
- 1000 poems: 30 MB
- Even with aggressive usage, per-poem storage is negligible
- No archival or garbage collection strategy needed

### Performance
- Save operation: 1 query (SELECT last revision) + 1 query (UPDATE or INSERT) = O(1), < 10ms
- Revision list query: O(log n) with index on `(poemID, savedAt)`, < 50ms for 1000 revisions
- No background jobs, no locking issues, no compaction overhead

---

## Open Questions & Decisions Needed

- [ ] **Window Size**: Is 3 minutes right, or should it be 2 / 5 / 10 minutes?
- [ ] **Content Loss in Window**: Is it acceptable that content changes within a single window are overwritten (not preserved)?
- [ ] **Save Frequency**: How often is the app currently saving? (Every keystroke, debounced, periodic?)
- [ ] **Revision Metadata**: Do we ever want to track what the user was doing (e.g., "edited stanza 2")? (Not required for MVP)
- [ ] **UI Strategy**: Should revision history be always visible, or in a modal/sidebar?
- [ ] **Retention Policy**: Keep all revisions forever, or delete after N months? (Probably forever given storage impact)

---

## Technical Considerations

### Database Indexes
The `byPoemTime` composite index on `(poemID, savedAt)` is critical:
- Enables efficient "get all revisions for a poem" queries
- Enables efficient "get most recent revision" (with DESC + LIMIT 1)

### Concurrency
- If two saves happen simultaneously on the same poem:
  - Both query last revision (get same result)
  - One INSERTs, one UPDATEs (or both UPDATE different aspects)
  - Window logic handles this naturally—later save just UPDATEs the earlier one
  - No coordination needed

### Migration (if adding to existing app)
- Create `poem_revision` table
- Populate with current content of all poems (one "initial" revision per poem)
- Start saving new revisions going forward

---

## Appendix

### Comparison to Alternative Approaches
- **Time-based tiers** (7 days recent, 30 days sparse, etc.): More complex, requires background job, unnecessary for bursty pattern
- **Delta storage** (store only diffs): More space-efficient but added complexity for minimal gain (you're already at ~30KB per poem)
- **Session-based deletion**: Aggressively deleting after 30 days loses history; windowing keeps everything forever without penalty

### Why This Works for Your Pattern
Your actual editing behavior is already sparse—windowing just makes it explicit in the database. You're not fighting against the system; you're working with it.
