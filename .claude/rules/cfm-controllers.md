---
paths:
  - "cfml/app/client/**/*.cfm"
---

# ColdFusion Controller Templates (.cfm)

`.cfm` templates are either script-based (no output) or tag-based (generates output). Script-based templates have 2-3 sections separated by comment-hrules:

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

When a controller has a `getPartial()` method, all data-fetching for the view should be centralized there rather than scattered in the main control flow section. The control flow section should only handle param declarations, request metadata, GET/POST branching, and the view include.

When script-based and tag-based templates work as a pair, the naming convention is `thing.cfm` (script) + `thing.view.cfm` (tags). The script template `include`s the tag template as the last part of its processing section.

Controllers should delegate business logic and side-effects to service-layer methods rather than implementing them inline.
