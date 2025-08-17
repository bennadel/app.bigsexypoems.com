<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	ui = request.ioc.get( "core.lib.web.UI" );
	utilities = request.ioc.get( "core.lib.util.Utilities" );
	wordService = request.ioc.get( "core.lib.util.WordService" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.word" type="string";
	param name="url.limit" type="numeric";
	param name="url.groupBy" type="string";

	partial = getPrimary(
		word = url.word,
		limit = utilities.clamp( url.limit, 50, 500 ),
		groupBy = url.groupBy
	);
	groups = partial.groups;

	include "./synonyms.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I provide the primary partial for the view.
	*/
	private struct function getPrimary(
		required string word,
		required numeric limit,
		required string groupBy
		) {

		var groups = wordService.getMeansLike(
			word = word,
			limit = limit,
			groupBy = groupBy
		);

		return {
			groups
		};

	}

</cfscript>
