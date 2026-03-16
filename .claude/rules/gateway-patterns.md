---
paths:
  - "**/*Gateway.cfc"
---

# Gateway Component Patterns

- **`withSort` preset for `getByFilter`**: Gateways that return multi-row result sets accept a `withSort` argument with domain-level preset names (e.g., `"name"`, `"newest"`). The gateway maps presets to SQL `ORDER BY` clauses via `cfswitch`, keeping sort logic in the data-access layer instead of re-sorting arrays in controllers. The default is `"id"` (or the table's natural key). Skip `withSort` for gateways that only ever return a single row (e.g., AccountGateway, TimezoneGateway, PresenceGateway).
- **Order by `id` instead of date columns**: Auto-increment IDs are inserted chronologically. Prefer `ORDER BY id DESC` over date columns to leverage existing indexes.
