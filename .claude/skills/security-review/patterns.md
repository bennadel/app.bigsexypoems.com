# Security Patterns Reference

Concrete good/bad code examples for each security check. Use these to calibrate your findings and reduce false positives.

---

## 1. SQL Injection

### Bad — raw interpolation in SQL

```cfml
<cfquery name="local.results" datasource="#variables.datasource#">
    SELECT *
    FROM poem
    WHERE id = #arguments.poemID#
</cfquery>
```

The `#arguments.poemID#` is interpolated directly into the SQL string. An attacker who controls `poemID` can inject arbitrary SQL.

### Good — parameterized query

```cfml
<cfquery name="local.results" datasource="#variables.datasource#">
    SELECT *
    FROM poem
    WHERE id = <cfqueryparam value="#arguments.poemID#" cfsqltype="cf_sql_bigint" />
</cfquery>
```

Every dynamic value is wrapped in `<cfqueryparam>` with an explicit `cfsqltype`.

### Edge case — safe dynamic table/column names

```cfml
<cfquery name="local.results" datasource="#variables.datasource#">
    SELECT *
    FROM #variables.tableName#
    WHERE id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_bigint" />
</cfquery>
```

If `variables.tableName` is a hardcoded property set in the component's init (not from user input), this is safe. Check the data source before flagging.

---

## 2. XSS Output Encoding

### Bad — unencoded user text in HTML content

```cfml
<h1>#title#</h1>
<p>#poem.content#</p>
```

If `title` or `poem.content` contain user input, this allows XSS.

### Good — encoded output

```cfml
<h1>#e( title )#</h1>
<p>#e( poem.content )#</p>
```

### Bad — unencoded value in HTML attribute

```cfml
<input type="text" value="#form.name#" />
```

### Good — attribute-encoded value

```cfml
<input type="text" value="#e4a( form.name )#" />
```

### Safe — UI helper methods (do NOT flag)

```cfml
<!--- These produce pre-encoded or internally-generated output --->
<label for="#ui.nextFieldId()#">Name:</label>
<input id="#ui.fieldId()#" type="text" />

<a #ui.attrHref( "member.poem.view", "poemID", poem.id )#>View</a>
<form action="#request.postBackAction#">
<img #ui.attrSrc( "/static/logo.png" )# />

<input type="checkbox" #ui.attrChecked( form.isPublic )# />
<option #ui.attrSelected( form.sortBy == "name" )#>Name</option>

<span>#ui.userDate( poem.createdAt )#</span>
```

### Safe — pre-sanitized HTML (do NOT flag)

```cfml
<!--- noteHtml has been sanitized by ShareNoteSanitizer --->
#share.noteHtml#

<!--- descriptionHtml has been sanitized by CollectionDescriptionSanitizer --->
#collection.descriptionHtml#
```

### Safe — numeric/boolean values (do NOT flag)

```cfml
<span>#poem.id#</span>
<span>#arrayLen( poems )#</span>
<cfif share.isActive>
```

### Safe — cfmodule attribute passing (do NOT flag)

```cfml
<!--- errorResponse is passed as a CFML variable, not rendered to HTML --->
<cfmodule
    template="/client/_shared/tag/errorMessage.cfm"
    response="#errorResponse#">
</cfmodule>
```

### Safe — URL builder (do NOT flag)

```cfml
<div hx-post="#router.urlForParts( 'member.poem.composer.syllables' )#">
```

---

## 3. XSRF Token Protection

### Bad — POST form without XSRF token

```cfml
<form method="post" action="#request.postBackAction#">
    <input type="text" name="name" value="#e4a( form.name )#" />
    <button type="submit">Save</button>
</form>
```

Missing `<cfmodule template="/client/_shared/tag/xsrf.cfm" />`.

### Good — POST form with XSRF token

```cfml
<form method="post" action="#request.postBackAction#">
    <cfmodule template="/client/_shared/tag/xsrf.cfm" />
    <input type="text" name="name" value="#e4a( form.name )#" />
    <button type="submit">Save</button>
</form>
```

### Good — hx-post inside a form that has XSRF

```cfml
<form method="post" action="#request.postBackAction#">
    <cfmodule template="/client/_shared/tag/xsrf.cfm" />
    <textarea name="content">#e( form.content )#</textarea>
    <div
        hx-post="#router.urlForParts( 'member.poem.composer.syllables' )#"
        hx-trigger="load">
    </div>
</form>
```

The `hx-post` on the `<div>` is inside the form, so it inherits the XSRF hidden input. This is safe.

### Bad — standalone hx-post form without XSRF

```cfml
<form
    hx-post="#router.urlForParts( 'share.poem.logViewing' )#"
    hx-trigger="load delay:2s"
    hx-swap="none">
    <!--- Missing XSRF module! --->
</form>
```

### Good — standalone hx-post form with XSRF

```cfml
<form
    hx-post="#router.urlForParts( 'share.poem.logViewing' )#"
    hx-trigger="load delay:2s"
    hx-swap="none">
    <cfmodule template="/client/_shared/tag/xsrf.cfm" />
</form>
```

---

## 4. Access Control

### Bad — accepts entity ID but no access check

```cfml
param name="url.poemID" type="numeric";

var poem = poemModel.getByID( url.poemID );
// Directly uses the poem without verifying the current user has access
```

### Good — access check before use

```cfml
param name="url.poemID" type="numeric";

var context = poemAccess.getContext( authContext, url.poemID, "canView" );
// context.poem is now the verified entity
```

### Good — parent-level access check

```cfml
param name="url.poemID" type="numeric";

var context = shareAccess.getContextForParent( authContext, url.poemID, "canViewAny" );
```

---

## 5. Input Validation — assertUniformEncoding

### Bad — string validation without encoding check

```cfml
public string function nameFrom( required string input ) {
    return pipeline(
        normalizeString( input ),
        [
            assertNotEmpty: [ "App.Model.Thing.Name.Empty" ],
            assertMaxLength: [ 255, "App.Model.Thing.Name.TooLong" ]
        ]
    );
}
```

Missing `assertUniformEncoding`. A double-encoded attack string could pass validation but decode to something malicious later.

### Good — string validation with encoding check

```cfml
public string function nameFrom( required string input ) {
    return pipeline(
        normalizeString( input ),
        [
            assertNotEmpty: [ "App.Model.Thing.Name.Empty" ],
            assertMaxLength: [ 255, "App.Model.Thing.Name.TooLong" ],
            assertUniformEncoding: [ "App.Model.Thing.Name.SuspiciousEncoding" ]
        ]
    );
}
```

### Safe — non-string validators (do NOT flag)

```cfml
public numeric function idFrom( required numeric input ) {
    // Numeric validation doesn't need encoding checks
    return val( input );
}
```

### Safe — \*Html validators (do NOT flag)

```cfml
public string function noteHtmlFrom( required string input ) {
    // This receives pre-sanitized HTML, not raw user input
    return input;
}
```

---

## 6. Error and Flash Translation Coverage

### Bad — thrown error with no translator case

In a model/service:
```cfml
throw( type = "App.Model.Thing.Name.TooLong", extendedInfo = serializeJson({ maxLength: 100 }) );
```

But `ErrorTranslator.cfc` has no `case "App.Model.Thing.Name.TooLong":` — the error will fall through to the generic 500 handler, exposing implementation details.

### Good — thrown error with translator case

ErrorTranslator.cfc:
```cfml
case "App.Model.Thing.Name.TooLong":
    return asModelStringTooLong( error, "thing name", metadata );
break;
```

### Bad — flash token with no translator case

In a controller:
```cfml
router.goto( url = "...", flash = "your.thing.created" );
```

But `FlashTranslator.cfc` has no `case "your.thing.created":` — the success message won't display.

### Good — flash token with translator case

FlashTranslator.cfc:
```cfml
case "your.thing.created":
    return asResponse( "Your thing has been created." );
break;
```

---

## 7. HTML Sanitization

### Bad — raw markdown rendered unescaped

```cfml
<!--- Rendering the raw markdown directly is an XSS vector --->
#share.noteMarkdown#
```

### Good — sanitized HTML rendered

```cfml
<!--- noteHtml was produced by ShareNoteSanitizer --->
#share.noteHtml#
```

### Bad — markdown-to-HTML without sanitizer

```cfml
// In a service:
var noteHtml = markdownParser.toHtml( noteMarkdown );
// No sanitizer! The markdown parser may produce unsafe HTML
gateway.update( noteHtml = noteHtml );
```

### Good — markdown-to-HTML with sanitizer

```cfml
// In a service:
var unsafeHtml = markdownParser.toHtml( noteMarkdown );
var sanitizedResults = shareNoteSanitizer.sanitize( unsafeHtml );

if ( sanitizedResults.unsafeMarkup.tags.len() ) {
    shareValidation.throwUnsafeNoteError( sanitizedResults.unsafeMarkup );
}

var noteHtml = sanitizedResults.safeHtml;
gateway.update( noteHtml = noteHtml );
```

### What to verify for each \*Markdown field

1. A `*Sanitizer.cfc` component exists (e.g., `ShareNoteSanitizer.cfc`, `CollectionDescriptionSanitizer.cfc`)
2. The service layer calls the sanitizer during markdown-to-HTML conversion
3. Views render `*Html` (not `*Markdown`) when outputting unescaped content

---

## 8. Debug Output in Production Code

### Bad — dump in a controller

```cfml
param name="url.poemID" type="numeric";

var context = poemAccess.getContext( authContext, url.poemID, "canView" );
dump( context ); // Exposes internal state to the browser
include "./view.view.cfm";
```

### Bad — writeDump in a service

```cfc
public void function updatePoem( required struct authContext, required numeric poemID ) {

    var poem = poemModel.getByID( poemID );
    writeDump( var = poem, abort = true ); // Debug output left in production code

}
```

### Bad — cfdump in a view

```cfml
<cfdump var="#poems#" />
<cfloop array="#poems#" item="poem">
    <div>#e( poem.title )#</div>
</cfloop>
```

### Bad — systemOutput in a model

```cfc
public struct function getByID( required numeric id ) {

    systemOutput( "getByID called with: #id#" ); // Debug logging in model code
    // ...

}
```

### Safe — infrastructure files (do NOT flag)

```cfml
<!--- cfmlx.cfm: polyfill definition --->
private void function dump( required any data ) {
    writeDump( argumentCollection = arguments );
}

<!--- Application.cfc: error handler --->
dump( label = "Unhandled Error", var = error );

<!--- Logger.cfc: dedicated logging utility --->
writeDump( var = message, output = logFile );

<!--- localDevelopment.view.cfm: local dev only --->
<cfset dump( error ) />
```

These are all infrastructure/utility files that legitimately use debug output. The check should only flag debug calls in controllers, views, models, and services.

---

## 9. Unsafe Dynamic Evaluation

### Bad — evaluate with user input

```cfc
var result = evaluate( "form.#fieldName#" );
```

If `fieldName` comes from user input, this executes arbitrary CFML expressions.

### Bad — evaluate for dynamic method dispatch

```cfc
var value = evaluate( "model.get#arguments.property#()" );
```

Even if `arguments.property` is constrained, `evaluate()` should never be used. Use bracket notation or a switch statement instead.

### Bad — iif for conditional output

```cfml
var label = iif( isActive, de( "Active" ), de( "Inactive" ) );
```

`iif()` calls `evaluate()` internally. Use a standard ternary or `if/else` instead:

```cfml
var label = ( isActive ) ? "Active" : "Inactive";
```

### Safe — deserializeJson on trusted data (do NOT flag)

```cfc
// Config file — trusted, not user input
var config = deserializeJson( fileRead( "#this.appRoot#/config/config.json" ) );

// HTTP API response — trusted external service
return deserializeJson( fileContent );

// Internal error metadata — framework-generated
return deserializeJson( extendedInfo.right( -causePrefix.len() ) );

// Gateway column hydration — database values
row[ key ] = deserializeJson( row[ key ] );
```

`deserializeJson()` parses JSON into CFML data structures — it does not execute code and is safe on trusted data sources.
