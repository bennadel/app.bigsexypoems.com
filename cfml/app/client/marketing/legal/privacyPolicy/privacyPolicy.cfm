<cfscript>

	// Define properties for dependency-injection.
	config = request.ioc.get( "config" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	title = "Privacy Policy";
	siteName = config.site.name;
	systemEmail = config.systemEmail.address;

	request.response.title = title;

	include "./privacyPolicy.view.cfm";

</cfscript>
