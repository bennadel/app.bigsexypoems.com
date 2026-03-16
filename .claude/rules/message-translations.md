---
paths:
  - "**/*.cfc"
  - "**/*.cfm"
---

# Error and Flash Message Translations

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
