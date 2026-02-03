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

**Collocated Controllers & Views**: Controller `.cfm` files and their corresponding View `.view.cfm`/`.view.less` files live side-by-side in `/cfml/app/client/` subsystem directories. This tight coupling means changes to a feature typically involve adjacent files.

**Routing Flow**: URL `/member/poems/123` → `/wwwroot/index.cfm` → Router.next() determines subsystem → nested routing via cfmodule within subsystem.

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

`/cfml/app/core/cfmlx.cfm` provides polyfills and shortcuts included on every request:
- Array utilities: `arrayCopy()`, `arrayGroupBy()`, `arrayIndexBy()`, `arrayPluck()`
- Shorthand: `e()`, `echo()`, `dump()`, `utcNow()`

## CFML Settings

- `searchImplicitScopes = false` - All variables must be explicitly scoped
- Arrays passed by reference
- Case-preserving struct keys and query columns
