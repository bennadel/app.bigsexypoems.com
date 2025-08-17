<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	ui = request.ioc.get( "core.lib.web.UI" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	user = request.authContext.user;

	request.response.title = "Home";
	request.response.activeNav = "member";

	include "./home.view.cfm";

</cfscript>
