---
paths:
  - "cfml/app/spec/**"
---

# Testing

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
