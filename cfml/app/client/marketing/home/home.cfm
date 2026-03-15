<cfscript>

	// Define properties for dependency-injection.
	config = request.ioc.get( "config" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	request.response.title = config.site.name;
	request.response.activeNav = "home";

	include "./home.view.cfm";

</cfscript>
