---
name: security-review
description: Security-focused code review of the CFML codebase that checks for SQL injection, XSS, XSRF, access control, input validation, error translation, HTML sanitization, debug output, and unsafe evaluation issues.
context: fork
agent: Explore
allowed-tools: Read, Grep, Glob
---

# Security Review

You are performing a security-focused code review of this ColdFusion (CFML) application. Your goal is to catch **drift from established security patterns** — places where new or modified code doesn't follow the conventions that the rest of the codebase uses consistently.

Read `patterns.md` (in this skill directory) before scanning. It contains concrete good/bad code examples for each check category that will help you distinguish true findings from false positives.

## Scan Procedure

Execute these 9 checks in order. For each check, scan the specified files, apply the criteria, and record findings.

---

### Check 1: SQL Injection

**Severity: CRITICAL**

Scan all `*Gateway.cfc` files under `cfml/app/core/lib/model/`.

These files are tag-based CFML and use `<cfquery>` blocks for database access. Look for any `#variable#` interpolation inside `<cfquery>` that is **not** wrapped in a `<cfqueryparam>` tag.

**What to flag:**
- Any `#variable#` directly in SQL text (e.g., `WHERE id = #userID#`)
- String concatenation used to build SQL fragments with user-controlled values

**What is safe (do NOT flag):**
- `<cfqueryparam value="#variable#" cfsqltype="..." />` — this is the correct pattern
- `#tableName#` or `#columnName#` where the value comes from a hardcoded constant, not user input

---

### Check 2: XSS Output Encoding

**Severity: HIGH (definite) / MEDIUM (uncertain)**

Scan all `.view.cfm` files under `cfml/app/client/`.

In CFML templates, `#expression#` inside `<cfoutput>` blocks renders values into HTML. All user-controlled values must be encoded using the context-appropriate function:

- **HTML content:** `#e( value )#` (calls `encodeForHtml()`)
- **HTML attributes:** `#e4a( value )#` (calls `encodeForHtmlAttribute()`)
- **JavaScript:** `#e4j( value )#` (calls `encodeForJavaScript()`)
- **URLs:** `#e4u( value )#` (calls `encodeForUrl()`)
- **JSON in HTML:** `#e4json( value )#` (JSON-serializes and JS-encodes)

**What to flag:**
- Any `#variable#` rendered in HTML content without `e()` wrapping
- Any `#variable#` in an HTML attribute value without `e4a()` wrapping
- Any `#variable#` in a JavaScript context without `e4j()` wrapping

**Known safe patterns (do NOT flag):**

These produce internally-generated or pre-encoded output:

| Pattern | Reason |
|---------|--------|
| `ui.fieldId()`, `ui.nextFieldId()` | Internally generated sequential IDs |
| `ui.attrHref(...)` | Produces complete pre-encoded `href="..."` attribute |
| `ui.attrAction(...)` | Produces complete pre-encoded `action="..."` attribute |
| `ui.attrSrc(...)` | Produces complete pre-encoded `src="..."` attribute |
| `ui.attrChecked(...)` | Outputs literal `checked` or empty string |
| `ui.attrSelected(...)` | Outputs literal `selected` or empty string |
| `ui.attrClass(...)` | Produces complete `class="..."` attribute |
| `ui.userDate(...)`, `ui.userTime(...)`, `ui.userDateTime(...)` | Formatted date/time values (no user content) |
| `request.postBackAction` | Built by `Router.buildPostBackAction()`, URL-safe |
| `router.urlForParts(...)` | URL builder, produces safe URLs |
| Numeric IDs (`*.id`, `poemID`, `collectionID`, `shareID`, `userID`) | Integer values |
| Boolean expressions | `true`/`false` |
| `*.noteHtml`, `*.descriptionHtml` | Pre-sanitized HTML (rendered unescaped intentionally) |
| Values passed as `cfmodule` attributes (e.g., `response="#errorResponse#"`) | Passed as CFML variables, not rendered to HTML |
| `*.len()`, `*.count`, array length expressions | Numeric results |
| Struct/query literal keys | Internal identifiers |

**Confidence guidance:**
- Mark as **DEFINITE** when an unencoded variable clearly contains user-supplied text (names, content, descriptions, notes, emails)
- Mark as **POSSIBLE** when you're unsure of the data source or whether encoding is needed

---

### Check 3: XSRF Token Protection

**Severity: HIGH**

Scan all `.view.cfm` files under `cfml/app/client/`.

Every `<form>` with `method="post"` must include the XSRF token via:
```
<cfmodule template="/client/_shared/tag/xsrf.cfm" />
```

Also check `<form>` elements (or any element) that use `hx-post` — if the `hx-post` element is inside a `<form>` that already has the XSRF module, it inherits the token. But a standalone `hx-post` form (i.e., a `<form>` element with `hx-post` but no `method="post"`) also needs the XSRF module.

**What to flag:**
- `<form method="post" ...>` without a `<cfmodule template="/client/_shared/tag/xsrf.cfm" />` inside it
- `<form hx-post="..." ...>` (form-level hx-post acting as the submission) without the XSRF module inside it

**What is safe (do NOT flag):**
- `hx-post` on a `<div>`, `<button>`, or other non-form element **inside** a `<form>` that already contains the XSRF module
- GET-method forms (no XSRF needed)

---

### Check 4: Access Control

**Severity: HIGH**

Scan controller `.cfm` files (NOT `.view.cfm`) in `cfml/app/client/member/`.

When a controller accepts entity IDs via URL parameters (`param name="url.poemID"`, `param name="url.collectionID"`, `param name="url.shareID"`), it must verify access using a `*Access.getContext()` or `*Access.getContextForParent()` call before operating on the entity.

**What to flag:**
- A controller that has `param name="url.*ID"` but never calls an Access component's `getContext()` or `getContextForParent()` method

**What is safe (do NOT flag):**
- Controllers that call `poemAccess.getContext(...)`, `collectionAccess.getContext(...)`, `shareAccess.getContext(...)`, or similar
- Controllers that don't accept entity IDs via URL params

---

### Check 5: Input Validation

**Severity: MEDIUM**

Scan all `*Validation.cfc` files under `cfml/app/core/lib/model/`.

Every public validation method that processes **string** input should include `assertUniformEncoding` in its pipeline. This catches double-encoding attacks via OWASP's `canonicalize()` function.

**What to flag:**
- A public method returning `string` that calls `pipeline()` with `assertMaxLength` or `assertNotEmpty` but **without** `assertUniformEncoding`

**What is safe (do NOT flag):**
- Methods that validate non-string types (numeric, boolean, date)
- Methods that call `assertUniformEncoding` in their pipeline
- Private helper methods
- Methods in `BaseValidation.cfc` (these are infrastructure, not field validators)
- Methods that validate `*Html` fields (these receive pre-sanitized HTML, not raw user input)

---

### Check 6: Error and Flash Translation Coverage

**Severity: LOW**

**Error types:** Grep for `throw( type = "App.` across the entire `cfml/app/` directory. Then read `cfml/app/core/lib/web/ErrorTranslator.cfc` and check that every thrown error type has a corresponding `case` statement.

**Flash tokens:** Grep for `flash:` or `flash =` in router.goto() calls across `cfml/app/`. Then read `cfml/app/core/lib/web/FlashTranslator.cfc` and check that every flash token has a corresponding `case` statement.

**What to flag:**
- Any `throw( type = "App.*" )` type that has no case in ErrorTranslator
- Any flash token that has no case in FlashTranslator

**What is safe (do NOT flag):**
- Error types that are caught and handled locally (try/catch in the same file) without propagating to the error translator
- `App.Xsrf.*` errors (these are handled as a group in the translator)

---

### Check 7: HTML Sanitization

**Severity: HIGH**

For fields that store Markdown (column names ending in `Markdown`), verify:

1. A corresponding `*Sanitizer.cfc` component exists that processes the markdown-to-HTML conversion
2. The service layer calls the sanitizer when converting markdown to HTML
3. Views output the `*Html` version (pre-sanitized), NOT the raw `*Markdown` version, when rendering unescaped HTML

**What to flag:**
- A `*Markdown` field that has no corresponding sanitizer
- A view that outputs `#*.noteMarkdown#` or `#*.descriptionMarkdown#` unescaped (should use `*Html` instead)
- A service that converts markdown to HTML without calling a sanitizer

---

### Check 8: Debug Output in Production Code

**Severity: MEDIUM**

Scan all `.cfm` and `.cfc` files under `cfml/app/client/` and `cfml/app/core/lib/model/` and `cfml/app/core/lib/service/`.

Look for calls to `dump()`, `writeDump()`, `<cfdump>`, or `systemOutput()` that appear in controllers, views, models, or services. These functions expose internal state and should not appear in production code paths.

**What to flag:**
- `dump(...)` or `writeDump(...)` in any controller `.cfm`, view `.view.cfm`, model `.cfc`, or service `.cfc`
- `<cfdump var="...">` in any view or controller template
- `systemOutput(...)` in any model or service component (outside of dedicated logging/diagnostic utilities)

**What is safe (do NOT flag):**
- `cfmlx.cfm` — polyfill definitions for `dump()` and `systemOutput()`
- `Application.cfc` — error handler infrastructure
- `Logger.cfc`, `MemoryLeakDetector.cfc` — dedicated diagnostic utilities
- `localDevelopment.view.cfm` — explicitly scoped to local development
- Any file under `cfml/app/core/lib/util/` — utility/infrastructure layer

---

### Check 9: Unsafe Dynamic Evaluation

**Severity: HIGH**

Scan all `.cfm` and `.cfc` files under `cfml/app/`.

Look for uses of `evaluate()` or `iif()`, which execute arbitrary CFML expressions at runtime. These are classic injection vectors when any part of the evaluated expression originates from user input.

**What to flag:**
- Any call to `evaluate(...)` anywhere in application code
- Any call to `iif(...)` anywhere in application code

**What is safe (do NOT flag):**
- `deserializeJson()` on trusted internal data (config files, HTTP API responses, internal error metadata, gateway column hydration) — these do not execute code
- Standard CFML expressions and conditionals (these are not dynamic evaluation)

---

## Report Format

After completing all 9 checks, produce a report with this structure:

### Summary

```
CRITICAL: [count]
HIGH:     [count]
MEDIUM:   [count]
LOW:      [count]
CLEAN:    [count of checks with no findings]
```

### Findings by Category

For each check that has findings:

```
## [Check Name] ([Severity])

- **[DEFINITE/POSSIBLE]** `file/path.cfm` ~line [N]: [Brief description of the issue]
```

For checks with no findings:

```
## [Check Name] ([Severity])

No issues found.
```

If there are zero findings across all categories, state: "All 9 security checks passed with no findings."
