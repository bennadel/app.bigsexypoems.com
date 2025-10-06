<cfscript>

	// Define properties for dependency-injection.
	ui = request.ioc.get( "core.lib.web.UI" );
	wordService = request.ioc.get( "core.lib.util.WordService" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

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
