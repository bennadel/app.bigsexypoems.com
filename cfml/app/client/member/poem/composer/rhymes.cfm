<cfscript>

	// Define properties for dependency-injection.
	wordService = request.ioc.get( "core.lib.util.WordService" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// CAUTION: This provides an explicit pathway in which I can test the global htmx
	// error handling locally.
	if ( request.isLocal && ( url?.word == "test" ) ) {

		throw( type = "App.LocalHtmxTest" );

	}

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.word" type="string";
	param name="url.limit" type="numeric";
	param name="url.groupBy" type="string";

	groups = wordService.getRhyme(
		word = url.word,
		limit = clamp( url.limit, 50, 500 ),
		groupBy = url.groupBy
	);

	request.response.template = "blank";

	// Shared view with synonyms.
	cfmodule(
		template = "./wordGroups.cfm",
		thing = "rhymes",
		groups = groups
	);

</cfscript>
