# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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
│   │                 #   Feature: auth, member, playground, share
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
- Array: `arrayCopy()`, `arrayGroupBy()`, `arrayIndexBy()`, `arrayPluck()`, `arrayPluckPath()`, `arrayPluckUnique()`, `arrayReflect()`, `arraySortByOperators()`
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
	revisionCascade.deleteRevision( revision );
}

// Child cascade deletes one:
public void function deleteRevision( required struct revision ) {
	revisionModel.deleteByFilter( id = revision.id );
}
```

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

Never include a `Co-Authored-By` line in commit messages. Ben is the sole author and owner of all code in this repository.

Don't add arbitrary line breaks within a paragraph in commit messages. Let a single-paragraph body remain on one line. Only use line breaks to separate distinct paragraphs.
