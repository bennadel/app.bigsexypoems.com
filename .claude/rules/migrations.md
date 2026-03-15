---
paths:
  - "cfml/app/db/**"
---

# Database Migrations

There's no database migration framework. All migration files need to be run manually. When the database structure needs to change, write a file to `/cfml/app/db/` and prompt me to run it manually.

Migrations are lexicographically named. SQL files use tabs for indentation.

`YYYY-MM-DD-{counter}-{description}.sql`

Examples:
- `2026-02-03-001-adding-new-table.sql`
- `2026-02-03-002-dropping-user-default.sql`
- `2026-02-03-003-adding-uniqueness-constraint.sql`
