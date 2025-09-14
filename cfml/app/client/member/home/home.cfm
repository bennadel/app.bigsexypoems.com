<cfscript>

	// Define properties for dependency-injection.
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	user = request.authContext.user;

	request.response.title = "Home";
	request.response.activeNav = "member";

	include "./home.view.cfm";

</cfscript>
