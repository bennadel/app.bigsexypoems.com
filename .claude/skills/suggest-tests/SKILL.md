---
name: suggest-tests
description: Scan recent commits for service-layer changes and report which services and methods lack test coverage.
context: fork
agent: Explore
allowed-tools: Read, Grep, Glob, Bash
---

# Suggest Tests

Scan service-layer files and cross-reference against existing test suites. Output a prioritized list of suggested tests — do NOT generate test code.

## Modes

- **Default** — Scan the last N commits (default 20) for changed services. Example: `/suggest-tests` or `/suggest-tests last 50 commits`.
- **Deep dive** — Scan ALL services regardless of git history. Triggered when the user's prompt contains "deep" (e.g., `/suggest-tests deep`, `/suggest-tests deep dive`).
- **Single service** — Analyze one specific service. Triggered when the user names a service (e.g., `/suggest-tests PoemService`, `/suggest-tests CollectionService`). Match by name — the user doesn't need to provide the full path.

## Step 1: Find Services to Analyze

### Default mode

Run these git commands to identify which service files were touched in the last N commits:

```bash
# Get the commit range
git log --oneline -N

# Find changed service files
git diff HEAD~N --name-only -- '*/service/**/*Service.cfc'
```

If `HEAD~N` extends beyond the repo's history, use `$(git rev-list --max-parents=0 HEAD)` as the base instead.

Collect the list of changed `*Service.cfc` file paths.

### Deep-dive mode

Glob for all `*Service.cfc` files under `cfml/app/core/lib/service/`. Every service is in scope.

### Single-service mode

Glob for `*Service.cfc` files under `cfml/app/core/lib/service/` and find the one matching the user's input. If no match is found, list the available services and exit.

## Step 2: Inventory Existing Test Suites

Glob for `/cfml/app/spec/suite/*Test.cfc` to get all existing test suites.

Build a mapping of service name to test suite:
- `PoemService.cfc` → `PoemServiceTest.cfc`
- `CollectionService.cfc` → `CollectionServiceTest.cfc`
- etc.

## Step 3: Analyze Each Changed Service

For each changed service file:

### If no test suite exists:

1. Read the service file
2. Extract all **public** method names (look for `public ... function methodName`)
3. Record the service path, all public methods, and note that no test suite exists

### If a test suite exists:

1. Read both the service file and the test suite
2. Extract public method names from the service
3. Extract test method names from the test suite (functions starting with `test`)
4. Match test methods to service methods using naming conventions:
   - `testCreate*` covers `create()`
   - `testDelete*` covers `delete()` or `deleteByFilter()`
   - `testUpdate*` covers `update()`
   - A test method covers a service method if the service method name appears in the test method name (case-insensitive)
5. Record any service methods that have no corresponding test methods

## Step 4: Analyze Error Paths

For each service in scope, trace through the call chain to find all possible error types:

### Untested validation errors

Most errors originate in `*Validation.cfc` files, not in the service itself. To find them:

1. Read the service file and identify which `*Model` methods each public service method calls (e.g., `poemModel.create()`, `poemModel.update()`)
2. Read the corresponding `*Model.cfc` to see which `*Validation` methods it calls for each operation (e.g., `poemValidation.nameFrom()`, `poemValidation.contentFrom()`)
3. Read the `*Validation.cfc` to extract the actual error types from each validation method's pipeline
4. Map each error type back to the service operation(s) that can trigger it — `create()` and `update()` often validate the same fields but not always (e.g., `update()` may accept optional fields that `create()` requires)

For each error type found, check whether the test suite has a corresponding `assertThrows` call. Report any that lack coverage.

Note on `SuspiciousEncoding` errors: All validation components share the same `assertUniformEncoding` check from `BaseValidation`, which compares the input against `canonicalize( input, true, true )`. A double-encoded percent string like `"%2525"` reliably triggers this across all fields.

### Untested cross-entity errors

Service methods may call into other entities' access or validation layers. For example, `PoemService.create()` calls `collectionAccess.getContext()` internally, which can throw `App.Model.Collection.NotFound`. Look for calls to other entities' access/validation components within the service and check whether those error types are tested.

### Untested access/permission checks

Service methods that call `*Access.getContext( authContext, id, "canSomething" )` or `*Access.getContextForParent(...)` enforce ownership — accessing another user's entity should throw a not-found error. Check whether the test suite has a single consolidated test (e.g., `testOtherUserEntityThrowsNotFound`) that:

1. Provisions a second auth context via `provisionAuthContext()` (inherited from `BaseTest`)
2. Creates the entity using that other auth context
3. Asserts that **both** update and delete throw `App.Model.*.NotFound` when accessed by the primary test user

The key insight: the entity must actually exist (created by user A) so that the error is a permission-denied-as-not-found, not a legitimate not-found. Report any access-gated services that lack this cross-user test.

## Step 5: Output Report

```
## Test Coverage Suggestions

**Mode**: Last N commits (since <oldest commit hash>) | Deep dive (all services)
**Services scanned**: X
**With test suites**: Y
**Needing attention**: Z

### <ServiceName> — No test suite exists
- **Path**: `cfml/app/core/lib/service/.../ServiceName.cfc`
- **Suggested suite**: `spec.suite.ServiceNameTest`
- **Public methods**:
  - `create` — brief description
  - `delete` — brief description
- **Suggested test methods**:
  - Happy path: `testCreate` (include related side-effects like revision creation)
  - Happy path: `testDelete`
  - Sad path: `testCreateWithInvalidInputThrows` (all create validation errors in one method)
  - Sad path: `testUpdateWithInvalidInputThrows` (all update validation errors in one method)
  - Sad path: `testOtherUserEntityThrowsNotFound` (assert both update and delete)

### <ServiceName> — Partial coverage
- **Path**: `cfml/app/core/lib/service/.../ServiceName.cfc`
- **Existing suite**: `spec.suite.ServiceNameTest`
- **Uncovered methods**:
  - `newMethod` — brief description
- **Untested error paths**:
  - `throw( type = "App.Model.Thing.Name.Empty" )` in `create()` — no `assertThrows` for this type
- **Missing permission tests**:
  - No `testOtherUserThingThrowsNotFound` — service has access-gated methods
- **Suggested test methods**:
  - Happy path: `testNewMethod`
  - Sad path: `testCreateWithInvalidInputThrows` (consolidate all untested create validations)
  - Sad path: `testOtherUserThingThrowsNotFound`
```

If all scanned services have full test coverage, state: "All scanned services have test coverage."

## Rules

- Do NOT generate test code — only report gaps and suggest test method names.
- Do NOT modify any files.
- In default mode, if no service files were changed in the commit range, state that and exit.
- When listing methods, include a brief note about what the method does (inferred from its name and body).
- **Test naming**: Happy-path methods use short names matching the operation: `testCreate`, `testUpdate`, `testDelete`. Sad-path validation methods consolidate by operation: `testCreateWithInvalidInputThrows`, `testUpdateWithInvalidInputThrows`. Sad-path permission methods use: `testOtherUser<Entity>ThrowsNotFound`.
- **Test sections**: Suggested methods should be grouped into `HAPPY PATH TESTS` and `SAD PATH TESTS` sections (see examples above).
- **Consolidate aggressively.** Minimize the number of test methods. If two assertions share setup, combine them (e.g., `testCreate` should verify both persistence and side-effects like revision creation). Don't suggest separate methods when one method with multiple assertions covers the same ground.
- **Consolidate validation errors by operation.** Multiple validation failures for the same operation belong in one test method. For example, if `create()` can throw `Name.Empty`, `Content.TooLong`, and `Name.SuspiciousEncoding`, suggest a single `testCreateWithInvalidInputThrows` — not three separate methods. Similarly for `update()`. Name the method after the operation and the broad category (e.g., `testCreateWithInvalidInputThrows`, `testUpdateWithInvalidInputThrows`).
- **One permissions test per service.** Suggest a single `testOtherUser<Entity>ThrowsNotFound` method that asserts both update and delete fail — not separate methods per operation.
