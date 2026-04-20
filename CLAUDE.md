# CLAUDE.md

## Build & Development Commands

```bash
# Client-side build (from cfml/app/build/main/)
npm run build          # Clean and build with Parcel
npm run watch          # Watch mode with live rebuild

# Docker orchestration (from repository root)
docker compose up                  # Start all services
docker compose --profile dev up    # Start with client-dev watcher
docker compose run --rm client sh  # Shell for npm package management

# Re-initialize application
# Visit: http://app.local.bigsexypoems.com/index.cfm?init=1
```

**Important**: Never run `npm` directly on the host machine. All `npm` commands must be executed inside the Docker client container (e.g., `docker compose up client` for builds, `docker compose run --rm client sh` for package management).

## Architecture

**Stack**: ColdFusion (CFML) backend + HTMX 2.0 + Alpine.js 3.15 frontend, Parcel for asset bundling, MySQL database, Docker Compose for orchestration.

**Collocated Controllers & Views**: Controller `.cfm` files and their corresponding View `.view.cfm`/`.view.less`/`.view.js` files live side-by-side in `/cfml/app/client/` subsystem directories. This tight coupling means changes to a feature typically involve adjacent files.

**Routing Flow**: URL `/index.cfm?event=member.poems&poemID=123` → `/wwwroot/index.cfm` → Router.next() determines subsystem → nested routing via cfmodule within subsystem. The dot-delimited segments of the `event` search parameter map (roughly) to nested folders within the `client` directory.

**IoC Container**: Custom `Injector` component provides lazy-loaded dependencies. Components use `ioc:type` attribute for property injection. Application scope caches instances; request scope holds request-specific data.

**Model/Gateway/Validation Pattern**: Each entity has three model-layer components:
- `*Model.cfc` - Public API
- `*Gateway.cfc` - Database CRUD (extends BaseGateway)
- `*Validation.cfc` - Input validation (extends BaseValidation)

**Service-Layer Components**: Entities with business logic typically also have service-layer components:
- `*Service.cfc` - Orchestration layer invoked by controllers; the internal public API for business logic
- `*Access.cfc` - Gathers data with permission checks, throwing access errors on unauthorized use
- `*Cascade.cfc` - Coordinates deletion of an entity and its nested children

**Validation Method Comments**: All validation methods use the same generic comment: `I validate and return the normalized value.` The method name itself (e.g., `nameFrom`, `contentFrom`) indicates which field is being validated.

## Key Directories

```
cfml/app/
├── client/           # Controllers & Views by subsystem
│   │                 #   Feature: auth, marketing, member, share
│   │                 #   Infrastructure: dev, error, go, system
│   └── _shared/      # Shared layouts & components
├── core/lib/
│   ├── classLoader/  # Java library bootstrapping
│   ├── integration/  # External service integrations
│   ├── model/        # Entity models, gateways, validation
│   ├── service/      # Business logic orchestration
│   ├── util/         # Utilities (Injector, etc.)
│   └── web/          # Router, RequestMetadata, UI, XSRF
├── config/           # config.json (git-ignored), config.template.json (structure docs)
├── db/               # SQL migrations (execute alphabetically on startup)
└── wwwroot/static/   # Parcel-built assets
```

## Configuration

- Runtime config: `/cfml/app/config/config.json` (git-ignored, contains secrets)
- Template: `/cfml/app/config/config.template.json` documents required structure
- Local hosts entry required: `127.0.0.1  app.local.bigsexypoems.com`

## Global Extensions

`/cfml/app/core/cfmlx.cfm` provides polyfills and shortcuts included in every execution context (component, template, custom tag). Functions in this file should be pure and decoupled from the application:
- Array: `arrayCopy()`, `arrayFlatten()`, `arrayGroupBy()`, `arrayIndexBy()`, `arrayPluck()`, `arrayPluckPath()`, `arrayPluckUnique()`, `arrayReflect()`, `arraySortByOperators()`
- Encoding: `e()` (HTML), `e4a()` (HTML attribute), `e4j()` (JavaScript), `e4json()` (JSON-in-JS), `e4u()` (URL)
- Maybe: `maybeNew()`, `maybeArrayFirst()`, `maybeSet()` — returns `{ exists, value }` structs
- Type checks: `isFalsy()`, `isTruthy()`, `isString()`, `isComponent()`, `isNotDate()`, `isInThread()`
- Coalesce: `coalesce()` (first non-null), `coalesceTruthy()` (first truthy)
- Date: `dateGetTime()`
- String: `stringAppendIf()`
- Safe ops: `safeDirectoryCreate()`, `safeFileDelete()`, `safeInsertAt()`
- Misc: `clamp()`, `methodBind()`, `nullValue()`, `rangeNew()`, `structPick()`, `toEntries()`, `truncate()`, `ucFirst()`
- Polyfills: `echo()`, `dump()`, `dumpN()`, `systemOutput()`, `utcNow()`

## CFML Settings

- `searchImplicitScopes = false` - All variables must be explicitly scoped
- Arrays passed by reference
- Case-preserving struct keys and query columns

## Code Formatting Examples

### ColdFusion Components (`.cfc`)

`.cfc` are structured in sections delimited by comment-blocks (`LIFE-CYCLE METHODS`, `PUBLIC METHODS`, `PRIVATE METHODS`). Life-cycle methods are listed in execution order; public and private methods are listed alphabetically. All `.cfc` files are script-based except `*Gateway.cfc` (tag-based for `cfquery`).

```cfc
component {

	// Define properties for dependency-injection.
	property name="..." ioc:type="...";
	property name="..." ioc:type="...";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I ....
	*/
	public numeric function findByKey() {

	}


	/**
	* I ....
	*/
	public numeric function getSomething() {

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I ....
	*/
	private struct function buildThat() {

	}

}
```

### ColdFusion Templates (`.cfm`)

`.cfm` templates are either script-based (no output) or tag-based (generates output). Script-based templates have 2-3 sections separated by comment-hrules:

```
<cfscript>

	// Define properties for dependency-injection.
	collectionModel = request.ioc.get( "core.lib.model.collection.CollectionModel" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url...." type="string" default="";
	param name="form...." type="string" default="";
	param name="form...." type="string" default="";

	// ... processing logic here ....

	include "./add.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial( required struct authContext ) {

		return {};

	}

</cfscript>
```

When a controller has a `getPartial()` method, all data-fetching for the view should be centralized there rather than scattered in the main control flow section. The control flow section should only handle param declarations, request metadata, GET/POST branching, and the view include.

When script-based and tag-based templates work as a pair, the naming convention is `thing.cfm` (script) + `thing.view.cfm` (tags). The script template `include`s the tag template as the last part of its processing section.

### View Templates (`.view.cfm` / `.view.less` / `.view.js`)

A view may optionally include `.view.less` (Less CSS) and/or `.view.js` (Alpine.js) alongside the `.cfm` / `.view.cfm` pair.

Since the asset build system has no automatic scoping, we simulate it with a random 6-character lowercase alphanumeric slug that **MUST** begin with a letter (e.g., `mq9evq`). This slug is used as an HTML attribute, CSS attribute selector, class name, and JavaScript global variable — all sharing the same value.

#### CSS scoping in `.view.less`

All CSS rules are nested under an attribute selector using the slug. Two patterns target elements:

- **Direct match (`&.className`)** — element has both the slug attribute AND the class. Compiles to `[slug].className`.
- **Descendant match (`.className`)** — element is a descendant of a slug-attributed ancestor. Compiles to `[slug] .className`.

```less
[mq9evq] {
	&.mq9evq {
		// Root element: compiles to [mq9evq].mq9evq
	}

	&.title {
		// Direct match: compiles to [mq9evq].title
	}

	.item {
		// Descendant: compiles to [mq9evq] .item
	}
}
```

```cfml
<div mq9evq class="mq9evq">
	<h2 mq9evq class="title">
		Direct-matched element (has slug attribute)
	</h2>
	<div class="item">
		Descendant-matched element (no slug attribute needed)
	</div>
</div>
```

Both patterns can be mixed. The root element typically uses `&.slug` for its own styles. Define CSS keyframe animations outside the `[slug]` block, prefixed with the slug:

```less
@keyframes mq9evq-enter-blink {
	// animations specific to this view.
}
```

#### Alpine.js components in `.view.js`

If a `.view.js` file exists, it defines one or more Alpine.js components using the slug as a global namespace. Components use a revealing module pattern with section comments matching the `.cfc` convention:

```js
window.mq9evq = {
	MyComponent,
};

function MyComponent() {

	return {
		// Life-Cycle Methods.
		init,

		// Public Methods.
		doSomething,
	};

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I initialize the component.
	*/
	function init() {

		// ...

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I do something.
	*/
	function doSomething() {

		// ...

	}

}
```

Components are bound in `.view.cfm` via `x-data` attributes: `<div x-data="mq9evq.MyComponent">`.

## Form Field Patterns

When creating form fields in `.view.cfm` templates:

- Use `<label for="#ui.nextFieldId()#" class="uiField_label">` (not `<span>`) for field labels
- Add `id="#ui.fieldId()#"` to the corresponding input element
- Use `ui.attrChecked()` helper for checkbox/radio checked state instead of inline `<cfif>` conditionals
- Use `ui.attrSelected()` helper for select option selected state
- Add the `x-keyed-focus` directive to the first visible form element within a form so it receives focus on page load

Example checkbox field:

```cfm
<div class="uiField">
	<label for="#ui.nextFieldId()#" class="uiField_label">
		Field Label:
	</label>
	<div class="uiField_content">
		<label class="uiHstack">
			<input
				id="#ui.fieldId()#"
				type="checkbox"
				name="fieldName"
				value="true"
				#ui.attrChecked( form.fieldName )#
				class="uiCheckbox"
			/>
			<span>Checkbox description</span>
		</label>
	</div>
</div>
```

## Associating JavaScript / Less CSS Files With `.cfm` Templates

Each major subsystem has a root `.js` entry point (e.g., `/client/member/member.js`) that auto-discovers all `.view.js` and `.view.less` files within its directory tree via a glob import:

```js
import "./**/*.view.{js,less}";
```

This means adding a new view with `.view.js` or `.view.less` files requires no manual import — they are automatically included in the next build.

The root entry point also explicitly imports shared modules from `_shared/tag/` (which are outside the subsystem directory and can't be auto-discovered):

```js
import "../_shared/tag/errorMessage.view.{js,less}";
import "../_shared/tag/toaster.view.{js,less}";
```

When creating a new shared tag in `_shared/tag/`, you must add an explicit import for it in each root entry point that uses it.

## Testing

Integration tests live in `/cfml/app/spec/suite/` and run against the live dev database. Each test suite extends `spec.BaseTest`, which provisions a fresh auth context (including a test user) via `provisionAuthContext()`. The auth context is stored in `variables.authContext`; the test user is accessed as `variables.authContext.user`.

```bash
# Run all tests (JSON output for Claude Code)
curl -s -H "Accept: application/json" "http://app.local.bigsexypoems.com/index.cfm?event=dev.test.spec.run&init=1" | jq .

# Run a single suite
curl -s -H "Accept: application/json" "http://app.local.bigsexypoems.com/index.cfm?event=dev.test.spec.run&init=1&suite=spec.suite.PoemServiceTest" | jq .

# Run a single test method
curl -s -H "Accept: application/json" "http://app.local.bigsexypoems.com/index.cfm?event=dev.test.spec.run&init=1&suite=spec.suite.PoemServiceTest&test=testDelete" | jq .
```

- **Naming**: Suites are `*Test.cfc`, test methods are public functions starting with `test`.
- **Runner**: `spec.TestRunner` auto-discovers all `*Test.cfc` files in `/spec/suite/`.
- **Assertions**: `assertEqual()`, `assertTrue()`, `assertThrows()`, `fail()` — all throw `TestRunner.Assertion`.
- **Independence**: Every test creates its own data. No shared fixtures, no teardown.
- **Browser view**: Visit the same URL in a browser (without the `Accept` header) for HTML-formatted results.
- **Sections**: Test methods are organized into comment-delimited sections: `HAPPY PATH TESTS` (normal operations succeed) and `SAD PATH TESTS` (validation errors, not-found errors, permission errors).
- **Condensing**: Minimize the number of test methods. If two assertions share the same setup, combine them into one test (e.g., test create + verify revision in a single method). Don't create separate tests for things that can be checked together.
- **Permissions**: Every service test suite should include a sad-path test that provisions a second auth context via `provisionAuthContext()`, creates an entity owned by that other user, and asserts that update and delete throw a not-found error when accessed by the primary test user.

## Database Migrations

There's no database migration framework. All migration files need to be run manually. When the database structure needs to change, write a file to `/cfml/app/db/` and prompt me to run it manually.

Migrations are lexicographically named. SQL files use tabs for indentation.

`YYYY-MM-DD-{counter}-{description}.sql`

Examples:
- `2026-02-03-001-adding-new-table.sql`
- `2026-02-03-002-dropping-user-default.sql`
- `2026-02-03-003-adding-uniqueness-constraint.sql`

## Architecture Preferences

**Consistency across patterns matters more than local optimization**: When the codebase has an established pattern, follow it uniformly — even if a shortcut would work in a specific case.

**Flat entity organization**: Tightly coupled entities (e.g., poem and revision) live as siblings in the same directory, not in nested subfolders. Only use subfolders when entities have genuine independence.

**Side-effects in the service layer, not controllers**: If an operation (like creating a revision) should happen every time an entity is created/updated, put it in the service method — not in each controller that calls the service.

**Services are ingress points**: Services exist as entry points from the controller layer into business logic. Services should not call other services laterally. A service can directly use sibling models (e.g., `PoemService` using `revisionModel`) when the entities are tightly coupled.

**Access components are self-contained**: Each Access component owns all authorization checks for its entity and should never call other Access components laterally. Implement cross-entity permission checks inline. Name assertion methods after the action (`canMakeCurrent`, `canDelete`).

**Pass context structs with `argumentCollection`**: Access context structs flow directly into assertion methods via `argumentCollection` (e.g., `poemAccess.canUpdate( argumentCollection = context )`) rather than destructuring arguments. Extra keys are ignored by ColdFusion.

**Cascade delete pattern**: The parent entity owns the collection relationship and iterates over children. Each child's cascade component handles deleting a single record. The cascade should never bulk-delete siblings.

```cfc
// Parent cascade iterates:
var revisions = revisionModel.getByFilter( poemID = poem.id );
for ( var revision in revisions ) {
	revisionCascade.delete( user, poem, revision );
}

// Child cascade deletes one:
public void function delete( required struct revision ) {
	revisionModel.deleteByFilter( id = revision.id );
}
```

**Transactions live in the service layer**: All `transaction {}` blocks belong in service components — never in models, gateways, or cascade components. This makes transaction boundaries predictable and discoverable. Cascade components and other helpers (e.g., `UserProvisioner`) are shared logic that runs inside a service-initiated transaction, not transaction owners themselves.

**Row-level locking with `withLock`**: Gateways accept a `withLock` argument (`"exclusive"` → `FOR UPDATE`, `"readonly"` → `FOR SHARE`) on `getByFilter`. Models expose it on `get` and `getByFilter`. The default is no lock. Locks are only meaningful inside a `transaction {}` block.

**Three reasons to lock, two lock types**: (1) FK integrity — lock a referenced parent row `withLock = "readonly"` so it can't be deleted mid-operation; multiple writes proceed in parallel. (2) Serialize a partial-update read-modify-write — lock the row being updated `withLock = "exclusive"` before calling `*Model.update`, because the model fills in omitted fields via an internal read. (3) Serialize a state-dependent read-modify-write across multiple rows — lock the aggregate root `withLock = "exclusive"` when one row's write depends on prior reads of related rows. The same row can serve multiple purposes.

**Lock FKs readonly on create/update**: When inserting or updating a row with foreign-key references, acquire a readonly lock on each referenced parent that could be concurrently deleted. Skip this when the write path already holds an exclusive lock on a row that the cascade delete also acquires (e.g., `PoemService.update`'s exclusive poem lock already participates in the user cascade delete's lock chain — no user lock needed there).

**Every update locks its target row exclusive**: `*Model.update` methods fill in omitted fields by reading the existing row, then writing the full column set back — a read-modify-write. Without an exclusive lock, concurrent partial updates silently lose each other's changes: T1 reads `{name:A, content:X}` to change name, T2 reads the same snapshot to change content, last writer wins and drops the other's edit. Every `*Service.update` wraps in `transaction {}` and calls `*Model.get( id, withLock = "exclusive" )` before `*Model.update`. There is no "simple last-write-wins update" exception. Narrow escape hatch: a gateway method that issues a single atomic SQL statement with column-level operators (`SET count = count + 1`, `SET lastAt = GREATEST( lastAt, ? )`) doesn't need a lock — e.g., `PresenceGateway.logRequest`. If you find yourself adding such a gateway method, call it out in the gateway (not a model) so it's obvious the call site is bypassing the model-layer read-modify-write.

**Lock aggregate roots exclusive for state-dependent writes**: Beyond the baseline update-lock rule above, use `transaction` + `withLock = "exclusive"` on the *aggregate root* when a write depends on a prior read of a different (usually child) row — aggregate recalculations against child counts, conditional create-or-update logic, multi-step workflows where reads inform writes. Don't apply this to cascade delete children that are just being removed.

**Lock the aggregate root, not the dependent rows**: When serializing work on child entities (e.g., revisions under a poem), lock the parent row that always exists rather than the child rows that may not. The parent row acts as a mutex — every code path that touches those children must acquire the same lock.

**Cascades don't mutate ancestors**: Cascade components handle the full delete semantics for their entity — deletion of the row and unlinking of FK references from surviving dependents. They do NOT mutate ancestor state (user-level aggregates, audit logs, etc.). Context-dependent side-effects correlated with the delete belong in the service layer alongside the cascade invocation, where the caller has full awareness of whether ancestors are surviving the operation.

**Cascade components lock child rows before descending**: When a cascade iterates over child entities and calls a nested cascade, it reads the children with `withLock = "exclusive"` to prevent contention with other workflows that lock those same rows (e.g., `logShareViewing` locking a share row). The outermost transaction is owned by the service layer; the cascade just acquires child locks within it.

**Cascade caller lock levels**: When calling into a cascade, lock each passed-in entity at the level the cascade will need for that specific entity. Ancestor entities that the cascade reads but doesn't mutate → **readonly** (FK integrity only). The entity being deleted → **exclusive** (required for the final DELETE statement, and starting exclusive avoids readonly-to-exclusive upgrade deadlocks). Dependent entities that the cascade discovers through iteration are locked exclusive *internally by the cascade*, not by the caller. Only `UserService.delete` locks the user exclusive — every other cascade caller (`PoemService.delete`, `ShareService.delete`, etc.) locks ancestors readonly.

**Cascade component preconditions**: Every public cascade method starts with a "Caution: must be called inside a transaction with locked entities" docblock. This is a load-bearing invariant, not a pattern-reminder — the file can't see its caller, and a silent contract violation is possible without the comment.

**`WithLock` variable naming convention**: Variables holding rows fetched with `withLock` are named with a `WithLock` suffix (`userWithLock`, `poemWithLock`). This acts as a lightweight type hint at call sites — `cascade.delete( userWithLock, poemWithLock )` visually signals the caller has honored the locking contract. Use plain names (`user`, `poem`) only for unlocked rows.

**`maybe*` methods don't accept `withLock`**: `FOR UPDATE` on an empty result set locks nothing. If a `maybe` read is subordinate to a locked aggregate root, it's already serialized. If it's a top-level upsert, use unique constraints instead of row locking.

**Use the `maybe` pattern for optional lookups**: When a query might return zero results, use `maybeGet*` methods that return `{ exists, value }` via `maybeArrayFirst()`. Never return empty structs `{}` as a "not found" sentinel.

**Snapshot from persisted state**: When creating a snapshot or revision, re-read the entity from the database rather than passing through submitted input values.

**Use the entity's own timestamps**: When an operation is semantically tied to an entity mutation (like a revision snapshot), use the entity's own `updatedAt`/`createdAt` rather than generating a new `utcNow()`.

**Simplicity over abstraction**:
- Don't add guards or conditionals to skip work that's cheap and harmless.
- Keep single-use constants as local variables rather than promoting to instance properties with `ioc:skip`.
- Don't pre-build service methods or APIs for anticipated future needs. Delete dead code.

**Let errors bubble up**: Never add try/catch blocks unless there is explicit recovery logic for a specific, anticipated failure. Errors should propagate to the application boundary where they are logged and translated for the user. Swallowing or wrapping exceptions "just in case" hides bugs and makes debugging harder. The only valid reasons for a try/catch are: performing a rollback or cleanup side-effect, retrying with a fallback strategy, or converting a thrown type into a different domain-specific error with added context. If the catch block would just rethrow, log, or return a generic default — don't catch.

**Order by `id` instead of date columns**: Auto-increment IDs are inserted chronologically. Prefer `ORDER BY id DESC` over date columns to leverage existing indexes.

**`withSort` preset for `getByFilter`**: Gateways that return multi-row result sets accept a `withSort` argument with domain-level preset names (e.g., `"name"`, `"newest"`). The gateway maps presets to SQL `ORDER BY` clauses via `cfswitch`, keeping sort logic in the data-access layer instead of re-sorting arrays in controllers. The default is `"id"` (or the table's natural key). Skip `withSort` for gateways that only ever return a single row (e.g., AccountGateway, TimezoneGateway, PresenceGateway).

**Parentheses in compound conditions**: When a condition has multiple operands joined by `&&` or `||`, wrap each operand in parentheses: `if ( (a == b) && (c == d) )`. Not needed for single-operand conditions — `if ( a == b )` is fine as-is.

**Struct shorthand**: When a struct key matches the variable name, use shorthand: `{ passCount, failCount }` instead of `{ passCount: passCount, failCount: failCount }`.

**Truthy length checks**: Use `.len()` as a boolean directly rather than comparing to zero (e.g., `if ( value.len() )` not `if ( value.len() > 0 )`).

**String interpolation over concatenation**: For simple string assembly, prefer interpolation (`"#name# #createUUID()#"`) over concatenation (`name & " " & createUUID()`). Concatenation is fine for complex expressions or multi-line building.

**Named arguments on built-in functions**: Prefer named arguments over positional when a built-in function takes 3+ parameters (e.g., `directoryList( path = ..., recurse = false, listInfo = "name", filter = "*.cfc" )`).

**CSS custom properties over hardcoded colors**: Never hardcode hex colors in Less files. Use the design system's CSS variables (e.g., `var( --error-fill )`, `var( --success-text )`).

## Error and Flash Message Translations

When adding `throw()` statements or flash messages, corresponding translations must be added:

**ErrorTranslator.cfc** (`/cfml/app/core/lib/web/ErrorTranslator.cfc`):
- Translates `throw( type = "App.Model...." )` error types into user-friendly messages
- Add a `case` statement for each new error type that may be triggered by user input
- Cases are organized alphabetically by error type
- Use helper methods like `asModelStringTooLong()`, `asModelStringSuspiciousEncoding()`, `asModelNotFound()` for common patterns

**FlashTranslator.cfc** (`/cfml/app/core/lib/web/FlashTranslator.cfc`):
- Translates flash tokens (e.g., `flash: "your.poem.created"`) into user-friendly success messages
- Add a `case` statement for each new flash token used in `router.goto()` calls
- Cases are organized alphabetically by flash token
- Flash tokens follow the pattern `your.{entity}.{action}` (e.g., `your.poem.share.updated`)

## Claude Code Skills

When creating a new skill, always ask the user whether it should be a **project-level skill** (`.claude/skills/<skill-name>/SKILL.md` — committed to the repo, shared with all developers) or a **global user skill** (`~/.claude/skills/<skill-name>/SKILL.md` — personal, available across all projects). Don't assume either location.

## Git Commits

The vast majority of commits should include a subject line (less than 80-characters); and a longer description of the commit contents. If the entire commit can be described in less than 80-character, a subject-line-only commit is ok.

Don't add arbitrary line breaks within a paragraph in commit messages. Let a single-paragraph body remain on one line. Only use line breaks to separate distinct paragraphs.

Never include a `Co-Authored-By` line in commit messages. Ben is the sole author and owner of all code in this repository.

## Agent Behavior

- Be concise in your responses (favor bullet points over prose).
- Never flatter me.
- Push back on decisions when it's warranted.
- Never make up an answer — say you don't know when you don't know.

### Plans & Plan Mode

- Keep plans as concise as possible without losing fidelity. Sacrifice grammatical correctness for brevity.
- End each plan with a list of unanswered questions, if any.
