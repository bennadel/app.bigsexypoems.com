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

## Architecture

**Stack**: ColdFusion (CFML) backend + HTMX 2.0 + Alpine.js 3.15 frontend, Parcel for asset bundling, MySQL database, Docker Compose for orchestration.

**Collocated Controllers & Views**: Controller `.cfm` files and their corresponding View `.view.cfm`/`.view.less`/`.view.js` files live side-by-side in `/cfml/app/client/` subsystem directories. This tight coupling means changes to a feature typically involve adjacent files.

**Routing Flow**: URL `/index.cfm?event=member.poems&poemID=123` → `/wwwroot/index.cfm` → Router.next() determines subsystem → nested routing via cfmodule within subsystem. The dot-delimited segments of the `event` search parameter map (roughly) to nested folders within the `client` directory.

**IoC Container**: Custom `Injector` component provides lazy-loaded dependencies. Components use `ioc:type` attribute for property injection. Application scope caches instances; request scope holds request-specific data.

**Model/Gateway/Validation Pattern**: Each entity has three components:
- `*Model.cfc` - Public API
- `*Gateway.cfc` - Database CRUD (extends BaseGateway)
- `*Validation.cfc` - Input validation (extends BaseValidation)

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

`/cfml/app/core/cfmlx.cfm` provides polyfills and shortcuts included in every execution context (component, template, custom tag). Function in this file should be pure and decoupled from the application:
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

All `.cfc` files are script-based. Except for database access components, which are tag-based so that we can use the `cfquery` tags to execute SQL statements against MySQL.

### ColdFusion Templates (`.cfm`)

`.cfm` templates can be either script-based (they don't generate output) or tag-based (they do generate output).

Script-based template generally have 2-3 sections:
- IoC / `cfmlx.cfm` inclusion at the top.
- Processing logic in the middle.
- Private methods at the bottom (optional).

Each of these three sections is separated by a comment-block:

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

If there are Less CSS or JavaScript files associated with these templates, they use the `.less` and `.js` file extensions:
- `thing.cfm` (script-based)
- `thing.view.cfm` (tag-based)
- `thing.view.less` (Less CSS)
- `thing.view.js` (JavaScript)

## Associating JavaScript / Less CSS Files With `.cfm` Templates

Each major section of application has a root `.js` file, example:

`/client/member/member.js`

This file performs auto-discovery of all view-specific Less/JavaScript files within the section using path globbing:

`import "./**/*.view.{js,less}";`

This means that as we add new leaf-nodes to our router, Less CSS and JavaScript changes will be automatically included in next build.

This file also explicitly imports the relevant Less/JavaScript files for globally-shared modules that cannot be auto-discovered. Many globally-shared modules have both `.js` and `.less` aspects, so minor globbing is used there as well, example:

```
import "../_shared/tag/errorMessage.view.{js,less}";
```
