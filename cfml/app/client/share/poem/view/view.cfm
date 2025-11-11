<cfscript>

	// Define properties for dependency-injection.
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

	lines = poem.content.reMatch( "[^\n]*" );

	request.response.title = title;

	include "./view.view.cfm";

</cfscript>
