<cfscript>

	ui = request.ioc.get( "core.lib.web.UI" );
	wordService = request.ioc.get( "core.lib.util.WordService" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="form.content" type="string";

	counts = wordService.getSyllableCountForLines( form.content );

	request.response.template = "blank";

	include "./syllables.view.cfm";

</cfscript>
