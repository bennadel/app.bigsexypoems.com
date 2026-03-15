<cfscript>

	// Define properties for dependency-injection.
	wordService = request.ioc.get( "core.lib.util.WordService" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.word" type="string";

	groups = wordService.getDefinition( word = url.word );

	request.response.template = "blank";

	include "./definitions.view.cfm";

</cfscript>
