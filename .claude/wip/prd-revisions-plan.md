# Plan: Poem Revision Viewing, Restore, and Delete

## Context

The revision model layer already exists (RevisionModel, RevisionGateway, RevisionValidation, RevisionCascade) and revisions are automatically created when poems are created/updated via `PoemService.saveRevision()`. What's missing is the **user-facing UI** to browse revisions, view diffs against the live poem, restore old revisions, and delete unwanted revisions.

## Files to Create (11 new files)

### 1. RevisionAccess.cfc
**Path**: `/cfml/app/core/lib/service/poem/RevisionAccess.cfc`

Mirrors `ShareAccess.cfc` exactly. Two context methods:
- `getContext(authContext, revisionID, assertion)` - loads revision, delegates to `getContextForParent`
- `getContextForParent(authContext, poemID, assertion)` - loads poem + user, checks ownership

Assertion methods: `canViewAny`, `canView`, `canDelete` (all delegate to ownership check). No `canMakeCurrent` needed - the makeCurrent operation verifies poem update permission via `poemAccess` instead. Private helpers `throwNotFoundError` / `throwForbiddenError` delegate to `revisionValidation`.

### 2. RevisionService.cfc
**Path**: `/cfml/app/core/lib/service/poem/RevisionService.cfc`

Two public methods:

- **`delete(authContext, id)`** - Authorizes via `revisionAccess.getContext(... "canDelete")`, then calls `revisionCascade.deleteRevision(revision)`. Follows the `ShareService.delete` pattern.

- **`makeCurrent(authContext, revisionID)`** - Loads revision via `revisionAccess.getContext(... "canView")`, then verifies poem update permission by passing the context (which contains `authContext` and `user`) to `poemAccess.canUpdate()`. Updates poem via `poemModel.update()` with the revision's name/content, then **always** creates a new revision (bypasses 120-second window). Re-reads poem after update to snapshot from persisted state.

### 3. Revision Router
**Path**: `/cfml/app/client/member/poem/revision/revision.cfm`

Switch cases: `list`, `view`, `delete`, `makeCurrent`. Breadcrumb helpers: `breadcrumbForRevision(revision)` (displays formatted date), `breadcrumbForRevisions(poem)` (displays "Revisions"). Pattern mirrors `share/share.cfm`.

### 4. Revision List Page
**Controller**: `/cfml/app/client/member/poem/revision/list/list.cfm`
**View**: `/cfml/app/client/member/poem/revision/list/list.view.cfm`

Loads poem via `revisionAccess.getContextForParent(... "canViewAny")` and all revisions via `revisionModel.getByFilter(poemID)`. View renders a `uiTable` with columns: Date (linked to detail, with `fromNow` subtext), Name, and Content (using `poemPreviewInTable` shared tag).

### 5. Revision Detail Page
**Controller**: `/cfml/app/client/member/poem/revision/view/view.cfm`
**View**: `/cfml/app/client/member/poem/revision/view/view.view.cfm`

Loads revision via `revisionAccess.getContext(... "canView")`, fetches all sibling revisions to compute prev/next using `maybeNew()`. Generates diff via `poemDiff` shared tag (revision = original/left, live poem = modified/right).

Nav links: Older, Newer (conditionally shown via `maybe.exists`), Delete, Make Current (hidden when `!compare(revision.name, poem.name) && !compare(revision.content, poem.content)`).

### 6. Delete Confirmation Page
**Controller**: `/cfml/app/client/member/poem/revision/delete/delete.cfm`
**View**: `/cfml/app/client/member/poem/revision/delete/delete.view.cfm`

Follows `share/delete/` pattern exactly. Checkbox confirmation, calls `revisionService.delete()`, redirects to revision list with flash `your.poem.revision.deleted`.

### 7. Make Current Confirmation Page
**Controller**: `/cfml/app/client/member/poem/revision/makeCurrent/makeCurrent.cfm`
**View**: `/cfml/app/client/member/poem/revision/makeCurrent/makeCurrent.view.cfm`

Follows `share/delete/` pattern. Checkbox confirmation explaining content will be overwritten, calls `revisionService.makeCurrent()`, redirects to poem view with flash `your.poem.revision.restored`.

## Files to Modify (5 existing files)

### 8. RevisionValidation.cfc
**Path**: `/cfml/app/core/lib/model/poem/RevisionValidation.cfc`

Add `throwForbiddenError()` method (throws `App.Model.Poem.Revision.Forbidden`).

### 9. ErrorTranslator.cfc
**Path**: `/cfml/app/core/lib/web/ErrorTranslator.cfc`

Add case for `App.Model.Poem.Revision.Forbidden` -> `as403()`. Insert alphabetically between `App.Model.Poem.NotFound` (line 96) and `App.Model.Poem.Revision.NotFound` (line 97).

### 10. FlashTranslator.cfc
**Path**: `/cfml/app/core/lib/web/FlashTranslator.cfc`

Add two cases between `your.poem.deleted` and `your.poem.share.created`:
- `your.poem.revision.deleted` -> "Your poem revision has been deleted."
- `your.poem.revision.restored` -> "Your poem has been restored from the selected revision."

### 11. Poem Router
**Path**: `/cfml/app/client/member/poem/poem.cfm`

Add `case "revision":` to switch statement, alphabetically between `case "list":` and `case "share":`.

### 12. Poem Detail View
**Path**: `/cfml/app/client/member/poem/view/view.view.cfm`

Add "Revisions" link to the `uiPageNav` nav, after "Share Links":
```cfm
<li>
    <a #ui.attrHref( "member.poem.revision", "poemID", poem.id )#>Revisions</a>
</li>
```

## Key Patterns and Reuse

| What | Where |
|------|-------|
| PoemAccess.canUpdate (for makeCurrent auth) | `/cfml/app/core/lib/service/poem/PoemAccess.cfc` |
| ShareAccess.cfc (pattern template) | `/cfml/app/core/lib/service/poem/share/ShareAccess.cfc` |
| ShareService.delete (pattern template) | `/cfml/app/core/lib/service/poem/share/ShareService.cfc:87` |
| share/delete/ (confirmation page pattern) | `/cfml/app/client/member/poem/share/delete/` |
| share/share.cfm (router pattern) | `/cfml/app/client/member/poem/share/share.cfm` |
| poemDiff shared tag | `/cfml/app/client/member/_shared/tag/poemDiff.cfm` |
| poemPreviewInTable shared tag | `/cfml/app/client/_shared/tag/poemPreviewInTable.cfm` |
| RevisionCascade.deleteRevision | `/cfml/app/core/lib/service/poem/RevisionCascade.cfc` |
| maybeNew() for prev/next | `/cfml/app/core/cfmlx.cfm:579` |
| compare() for exact match check | ColdFusion built-in (case-sensitive) |

## Build Sequence

1. RevisionValidation.cfc - add `throwForbiddenError`
2. ErrorTranslator.cfc - add Forbidden case
3. RevisionAccess.cfc - create (depends on step 1)
4. RevisionService.cfc - create (depends on step 3)
5. FlashTranslator.cfc - add flash cases
6. poem.cfm router - add `case "revision":`
7. revision/revision.cfm - create sub-router
8. revision/list/ - create list controller + view
9. revision/view/ - create detail controller + view
10. revision/delete/ - create delete controller + view
11. revision/makeCurrent/ - create make-current controller + view
12. poem view.view.cfm - add "Revisions" nav link

## Notes

- No `.view.js` or `.view.less` files needed - all views use existing global CSS utilities and the poemDiff tag has its own scoped styles.
- No database migrations needed - `poem_revision` table already exists with the required schema.
- No new shared tag imports needed - poemDiff and poemPreviewInTable are already imported in `member.js`.
- New view files under `member/poem/revision/` are auto-discovered by the `member.js` glob import.

## Verification

1. Re-init the app: `http://app.local.bigsexypoems.com/index.cfm?init=1`
2. Navigate to a poem detail page - verify "Revisions" link appears in nav
3. Click "Revisions" - verify list shows with dates, names, and content previews
4. Click a date link - verify detail page shows diff (revision left, live poem right)
5. Verify prev/next navigation works and hides at boundaries
6. Verify "Make Current" link is hidden when revision matches live poem
7. Click "Make Current" on a non-matching revision - verify confirmation page, submit, verify poem updated and new revision created
8. Click "Delete" on a revision - verify confirmation page, submit, verify revision removed from list
