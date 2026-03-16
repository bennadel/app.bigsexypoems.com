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

## Architecture Preferences

**Consistency across patterns matters more than local optimization**: When the codebase has an established pattern, follow it uniformly — even if a shortcut would work in a specific case.

**Flat entity organization**: Tightly coupled entities (e.g., poem and revision) live as siblings in the same directory, not in nested subfolders. Only use subfolders when entities have genuine independence.

**Simplicity over abstraction**:
- Don't add guards or conditionals to skip work that's cheap and harmless.
- Keep single-use constants as local variables rather than promoting to instance properties with `ioc:skip`.
- Don't pre-build service methods or APIs for anticipated future needs. Delete dead code.

**Let errors bubble up**: Never add try/catch blocks unless there is explicit recovery logic for a specific, anticipated failure. Errors should propagate to the application boundary where they are logged and translated for the user. Swallowing or wrapping exceptions "just in case" hides bugs and makes debugging harder. The only valid reasons for a try/catch are: performing a rollback or cleanup side-effect, retrying with a fallback strategy, or converting a thrown type into a different domain-specific error with added context. If the catch block would just rethrow, log, or return a generic default — don't catch.

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
