---
paths:
  - "cfml/app/core/lib/service/**"
---

# Service-Layer Components

## Services

- Services are ingress points from the controller layer into business logic
- Services should not call other services laterally
- A service can directly use sibling models (e.g., `PoemService` using `revisionModel`) when the entities are tightly coupled
- Side-effects belong in the service layer, not controllers — if an operation (like creating a revision) should happen every time an entity is created/updated, put it in the service method

## Access Components

- Each Access component owns all authorization checks for its entity
- Never call other Access components laterally — implement cross-entity permission checks inline
- Name assertion methods after the action (`canMakeCurrent`, `canDelete`)
- Pass context structs with `argumentCollection` (e.g., `poemAccess.canUpdate( argumentCollection = context )`) rather than destructuring arguments — extra keys are ignored by ColdFusion

## Cascade Delete Pattern

The parent entity owns the collection relationship and iterates over children. Each child's cascade component handles deleting a single record. The cascade should never bulk-delete siblings.

```cfc
// Parent cascade iterates:
var revisions = revisionModel.getByFilter( poemID = poem.id );
for ( var revision in revisions ) {
	revisionCascade.deleteRevision( revision );
}

// Child cascade deletes one:
public void function deleteRevision( required struct revision ) {
	revisionModel.deleteByFilter( id = revision.id );
}
```

## Data Patterns

- **Use the `maybe` pattern for optional lookups**: When a query might return zero results, use `maybeGet*` methods that return `{ exists, value }` via `maybeArrayFirst()`. Never return empty structs `{}` as a "not found" sentinel.
- **Snapshot from persisted state**: When creating a snapshot or revision, re-read the entity from the database rather than passing through submitted input values.
- **Use the entity's own timestamps**: When an operation is semantically tied to an entity mutation (like a revision snapshot), use the entity's own `updatedAt`/`createdAt` rather than generating a new `utcNow()`.
