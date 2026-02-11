# Tech Demo Session: Poem Revision System (Phase 1)

## What Was Implemented

A **poem revision system** with a 2-minute windowing strategy. Consecutive saves within a 2-minute window overwrite the previous revision (UPDATE) rather than creating a new one (INSERT). Once the window closes (no save for 2+ minutes), the next save creates a new revision. This compacts bursty authoring into a small number of logical checkpoints.

Phase 1 scope: schema, migration, model/service layer, windowing logic, and integration into existing save flow. No revision history UI.

---

## New Files Created

### Database Migration
- `cfml/app/db/2026-02-11-001-poem-revision.sql` - CREATE TABLE for `poem_revision` (id, poemID, name, content, createdAt, updatedAt)

### Model Layer (`cfml/app/core/lib/model/poem/revision/`)
- **RevisionGateway.cfc** - Tag-based gateway (extends BaseGateway). Methods: `create`, `getByFilter`, `getMostRecentByPoemID`, `update`, `deleteByFilter`. Index prefixes: `["id", "poemID"]`.
- **RevisionValidation.cfc** - Script-based (extends BaseValidation). Minimal - just `throwNotFoundError()` for `App.Model.Poem.Revision.NotFound`.
- **RevisionModel.cfc** - Script-based. Wraps gateway. `getMostRecentByPoemID()` returns a struct (or empty struct if none). `create()` passes `createdAt` as both `createdAt` and `updatedAt`.

### Service Layer (`cfml/app/core/lib/service/poem/revision/`)
- **RevisionService.cfc** - Contains the **windowing logic** in `saveRevision(poemID, name, content)`:
  1. Get most recent revision via `revisionModel.getMostRecentByPoemID(poemID)`
  2. If no previous revision exists OR `dateDiff("s", lastRevision.updatedAt, utcNow()) >= 120` -> INSERT new revision
  3. Else -> UPDATE existing revision (overwrite name, content, updatedAt)
  - Also has `get(id, poemID)` and `getByPoemID(poemID)` for future UI use.
- **RevisionCascade.cfc** - Bulk deletes revisions by poemID.

---

## Modified Files

### Cascade Delete
- **`cfml/app/core/lib/service/poem/PoemCascade.cfc`** - Added `revisionCascade` property and `deleteRevisions(poem)` private method. Called before share deletion and poem deletion.

### Save Flow Integration (4 save paths)
- **`cfml/app/client/member/poem/composer/saveInBackground.cfm`** - Added `revisionService.saveRevision()` after `poemService.update()` inside try/catch (composer auto-save on 1s debounce).
- **`cfml/app/client/member/poem/composer/editor.cfm`** - Added `revisionService.saveRevision()` after `poemService.update()` (composer "Save and Exit" form submit). *This was initially missed and added during debugging.*
- **`cfml/app/client/member/poem/edit/edit.cfm`** - Added `revisionService.saveRevision()` after `poemService.update()` (edit form submit).
- **`cfml/app/client/member/poem/add/add.cfm`** - Added `revisionService.saveRevision()` after `poemService.create()` (first revision when poem is born).

### Error Translator
- **`cfml/app/core/lib/web/ErrorTranslator.cfc`** - Added `App.Model.Poem.Revision.NotFound` case between `App.Model.Poem.NotFound` and `App.Model.Poem.Share.*`.

---

## Debugging Notes

- Initially revisions were not appearing in the table after updates. The issue resolved after reinitializing the app (`?init=1`). The IoC container lazily creates components, but a reinit was needed to pick up the new components properly.
- The `editor.cfm` save path in the composer was initially missed (only `saveInBackground.cfm` was covered). Found by grepping for `poemService.update` and `poemService.create` across the client directory - revealed 4 save paths, not 3.
- The `saveInBackground.view.cfm` shows "Saved." or "An error occurred." - errors from the revision save are caught by the same try/catch as the poem update, meaning the poem update commits but the error message reflects the revision failure.

---

## Verification Steps

1. Run the SQL migration manually
2. Reinitialize the app (`?init=1`)
3. Create a new poem via "Add Poem" - verify a revision row is created
4. Open in composer, type content - verify revisions are created/updated with 2-minute windowing:
   - Rapid saves within 2 min should UPDATE the same revision row (same `id`, new `updatedAt`)
   - Waiting 2+ min then saving should INSERT a new revision row
5. Delete a poem - verify its revisions are also deleted
6. `SELECT * FROM poem_revision WHERE poemID = [id] ORDER BY updatedAt DESC`

---

## What's NOT Done (Future Phases)

- Revision history UI (viewing past revisions)
- Revision restore functionality
- Revision diff/comparison view
