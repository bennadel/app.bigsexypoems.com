<cfscript>

	// Define properties for dependency-injection.
	poemService = request.ioc.get( "core.lib.service.poem.PoemService" );
	router = request.ioc.get( "core.lib.web.Router" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	poem = request.poem;
	share = request.share;
	user = request.user;

	title = poem.name;
	lines = poemService.splitLines( poem.content );

	request.response.title = title;

	include "./view.view.cfm";

</cfscript>
