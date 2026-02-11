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

**Model/Gateway/Validation Pattern**: Each entity has three components:
- `*Model.cfc` - Public API
- `*Gateway.cfc` - Database CRUD (extends BaseGateway)
- `*Validation.cfc` - Input validation (extends BaseValidation)

**Validation Method Comments**: All validation methods use the same generic comment: `I validate and return the normalized value.` The method name itself (e.g., `nameFrom`, `contentFrom`) indicates which field is being validated.

## Key Directories

```
cfml/app/
├── client/           # Controllers & Views by subsystem (auth, member, playground, share, system)
│   └── _shared/      # Shared layouts & components
├── core/lib/
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
- Array utilities: `arrayCopy()`, `arrayGroupBy()`, `arrayIndexBy()`, `arrayPluck()`
- Shorthand: `e()`, `echo()`, `dump()`, `utcNow()`

## CFML Settings

- `searchImplicitScopes = false` - All variables must be explicitly scoped
- Arrays passed by reference
- Case-preserving struct keys and query columns

## Code Formatting Examples

### ColdFusion Components (`.cfc`)

`.cfc` are structures in sections. Each section is delimited by a comment-block (`LIFE-CYCLE METHODS`, `PUBLIC METHODS`, `PRIVATE METHODS`). Within the `LIFE-CYCLE METHODS` section, methods are listed in order of life-cycle execution. Within the `PUBLIC METHODS` and `PRIVATE METHODS` section, methods are listed alphabetically.

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


	/**
	* I ....
	*/
	private struct function buildThisOtherThing() {

	}

}
```

All `.cfc` files are script-based. Except for database access components (`*Gateway.cfc`), which are tag-based so that we can use the `cfquery` tags to execute SQL statements against MySQL.

### ColdFusion Templates (`.cfm`)

`.cfm` templates can be either script-based (they don't generate output) or tag-based (they do generate output).

Script-based templates generally have 2-3 sections:
- IoC / `cfmlx.cfm` inclusion at the top.
- Processing logic in the middle.
- Private methods at the bottom (optional).

Each of these three sections is separated by a comment-hrule:

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

When script-based and tag-based templates work as a pair (such as with a view-module or a layout-module), the file naming convention is:
- `thing.cfm` (script-based)
- `thing.view.cfm` (tag-based)

The script-based tag will `include` the tag-based tag; often as the last part of the processing section.

### View Templates (`.view.cfm` / `.view.less` / `.view.js`)

A view may have a `.view.less` file, a `.view.js` file, both, or neither — they are independent and optional:

- `thing.cfm` (script-based CFML)
- `thing.view.cfm` (tag-based CFML)
- `thing.view.less` (Less CSS — optional)
- `thing.view.js` (JavaScript — optional)

Since the asset build system has no automatic scoping of JavaScript or CSS, we must simulate scoping through the use of a random 6-character lowercase alphanumeric slug that **MUST** begin with a letter (so it can be used as a valid JavaScript identifier). Examples:

- `ijzl5y`
- `mq9evq`

This slug is used as an HTML attribute, a CSS attribute selector, a class name, and a JavaScript global variable name — all sharing the same value.

#### CSS scoping in `.view.less`

All CSS rules in a `.view.less` file are nested under an attribute selector using the slug:

```less
[mq9evq] {
	// ...
}
```

Within this block, there are two patterns for targeting elements:

**Direct match (`&.className`)** — targets elements that have both the slug attribute AND the class. Use this when the slug attribute is applied directly to the styled element in the `.view.cfm`:

```less
[mq9evq] {
	&.mq9evq {
		// Root element: compiles to [mq9evq].mq9evq
	}

	&.title {
		// Direct element: compiles to [mq9evq].title
	}
}
```

```cfml
<div mq9evq class="mq9evq">
	<h2 mq9evq class="title">
		This is a title with scoped styling
	</h2>
</div>
```

**Descendant match (`.className`)** — targets child elements that are descendants of an element with the slug attribute. Use this when only an ancestor has the slug attribute:

```less
[mq9evq] {
	&.mq9evq {
		// Root element: compiles to [mq9evq].mq9evq
	}

	.item {
		// Descendant: compiles to [mq9evq] .item
	}
}
```

```cfml
<div mq9evq class="mq9evq">
	<div class="item">
		No slug attribute needed on this child.
	</div>
</div>
```

Both patterns can be mixed within the same `.view.less` file. The root element typically uses `&.slug` for its own styles.

**Note**: CSS keyframe animations don't nest well inside attribute selectors. Define them outside the top-level `[slug]` block, prefixed with the slug for scoping:

```less
@keyframes mq9evq-enter-blink {
	// animations specific to this view.
}
```

#### Alpine.js components in `.view.js`

If a `.view.js` file exists, it defines one or more Alpine.js components using the same slug as a global namespace. Components use a revealing module pattern with section comments matching the `.cfc` convention:

```js
window.mq9evq = {
	ComponentOne,
	ComponentTwo,
};

function ComponentOne() {

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

function ComponentTwo() {

	return {
		// return public API for Alpine.js component.
	};

}
```

These Alpine.js components are then bound to elements in the `.view.cfm` using `x-data` attributes:

```cfml
<div x-data="mq9evq.ComponentOne"> ... </div>
<div x-data="mq9evq.ComponentTwo"> ... </div>
```

## Form Field Patterns

When creating form fields in `.view.cfm` templates:

- Use `<label for="#ui.nextFieldId()#" class="uiField_label">` (not `<span>`) for field labels
- Add `id="#ui.fieldId()#"` to the corresponding input element
- Use `ui.attrChecked()` helper for checkbox/radio checked state instead of inline `<cfif>` conditionals
- Use `ui.attrSelected()` helper for select option selected state

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

There's no database migration framework. All of the database migration files need to be run manually. As such, when the database structure needs to be changed, you must write a file to the `/cfml/app/db/` directory and then prompt me to run it manually.

Database migrations must be lexicographically named so that when a new environment spins up, all the `.sql` files are executed in a predictable order. Database migrations scripts are named in the form of:

SQL files use tabs for indentation (consistent with the rest of the codebase).

`YYYY-MM-DD-{counter}-{description}.sql`

Examples:
- `2026-02-03-001-adding-new-table.sql`
- `2026-02-03-002-dropping-user-default.sql`
- `2026-02-03-003-adding-uniqueness-constraint.sql`

## Architecture Preferences

**Consistency across patterns matters more than local optimization**: When the codebase has an established pattern (cascade style, optional-return convention, etc.), follow it uniformly — even if a shortcut would work in a specific case. Consistent patterns make the codebase easier to reason about and reduce cognitive load.

**Flat entity organization**: Tightly coupled entities (e.g., poem and revision) live as siblings in the same directory, not in nested subfolders. Only use subfolders when entities have genuine independence.

**Side-effects in the service layer, not controllers**: If an operation (like creating a revision) should happen every time an entity is created/updated, put it in the service method — not in each controller that calls the service. Controllers should not orchestrate cross-cutting concerns.

**Services are ingress points**: Services exist as entry points from the controller layer into business logic. Services should not call other services laterally. A service can directly use sibling models (e.g., `PoemService` using `revisionModel`) when the entities are tightly coupled.

**Cascade delete pattern**: The parent entity owns the collection relationship and iterates over children. Each child's cascade component handles deleting a single record (and any of its own children). The cascade component should never bulk-delete siblings — that's the parent's job.

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

**Snapshot from persisted state**: When creating a snapshot or revision of an entity, re-read the entity from the database rather than passing through the submitted input values. This ensures the snapshot reflects the actual persisted state (after any validation/normalization).

**Use the entity's own timestamps**: When an operation is semantically tied to an entity mutation (like a revision snapshot), use the entity's own `updatedAt`/`createdAt` timestamp rather than generating a new `utcNow()`.

**Prefer simplicity over conditional optimization**: Don't add guards or conditionals to skip work that's cheap and harmless. Prefer always executing a simple path over branching to avoid redundant-but-safe operations.

**Keep constants local when single-use**: If a value (like a timeout or threshold) is only used in one method, declare it as a local variable in that method. Don't promote it to an instance property with `ioc:skip` and an `init()` method.

**Order by `id` instead of date columns**: Auto-increment IDs are inserted in chronological order, and every index implicitly contains the primary key. Prefer `ORDER BY id DESC` over `ORDER BY updatedAt DESC` (or similar date columns) to leverage existing indexes and avoid needing composite indexes on date columns.

**Don't build for future use**: Don't pre-build service methods, components, or APIs for anticipated future needs. Build them when they're actually needed. Delete dead code rather than keeping it around "for later."

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

## Git Commits

Never include a `Co-Authored-By` line in commit messages. Ben is the sole author and owner of all code in this repository.

