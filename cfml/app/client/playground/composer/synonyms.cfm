<cfscript>

	// Define properties for dependency-injection.
	wordService = request.ioc.get( "core.lib.util.WordService" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.word" type="string";
	param name="url.limit" type="numeric";
	param name="url.groupBy" type="string";

	// Under the hood, the WordService is making a remote HTTP API call to Datamuse. As
	// such, we need to increase the request timeout in order to accommodate the maximum
	// underlying gateway timeout.
	// --
	// Todo: I don't love the tight coupling here. I mean, I know that there's intrinsic
	// coupling because we have real-world timing constraints. But, I would like to figure
	// out a cleaner way to do this.
	cfsetting( requestTimeout = ( wordService.getMaxRequestTimeout() + 3 ) );

	groups = wordService.getMeansLike(
		word = url.word,
		limit = clamp( url.limit, 50, 500 ),
		groupBy = url.groupBy
	);

	request.response.template = "blank";

	// Shared view with rhymes.
	cfmodule(
		template = "./wordGroups.cfm",
		thing = "synonyms",
		groups = groups
	);

</cfscript>
