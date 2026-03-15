---
paths:
  - "**/*.cfc"
  - "**/*.cfm"
---

# CFML Coding Style

## ColdFusion Component (.cfc) Section Structure

`.cfc` are structured in sections delimited by comment-blocks (`LIFE-CYCLE METHODS`, `PUBLIC METHODS`, `PRIVATE METHODS`). Life-cycle methods are listed in execution order; public and private methods are listed alphabetically. All `.cfc` files are script-based except `*Gateway.cfc` (tag-based for `cfquery`).

## Validation Method Comments

All validation methods use the same generic comment: `I validate and return the normalized value.` The method name itself (e.g., `nameFrom`, `contentFrom`) indicates which field is being validated.

## Coding Conventions

**Parentheses in compound conditions**: When a condition has multiple operands joined by `&&` or `||`, wrap each operand in parentheses: `if ( (a == b) && (c == d) )`. Not needed for single-operand conditions — `if ( a == b )` is fine as-is.

**Struct shorthand**: When a struct key matches the variable name, use shorthand: `{ passCount, failCount }` instead of `{ passCount: passCount, failCount: failCount }`.

**Truthy length checks**: Use `.len()` as a boolean directly rather than comparing to zero (e.g., `if ( value.len() )` not `if ( value.len() > 0 )`).

**String interpolation over concatenation**: For simple string assembly, prefer interpolation (`"#name# #createUUID()#"`) over concatenation (`name & " " & createUUID()`). Concatenation is fine for complex expressions or multi-line building.

**Named arguments on built-in functions**: Prefer named arguments over positional when a built-in function takes 3+ parameters (e.g., `directoryList( path = ..., recurse = false, listInfo = "name", filter = "*.cfc" )`).

## .cfc Code Example

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
