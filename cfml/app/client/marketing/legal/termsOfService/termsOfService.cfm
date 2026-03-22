<cfscript>

	// Define properties for dependency-injection.
	config = request.ioc.get( "config" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	title = "Terms of Service";
	siteName = config.site.name;
	systemOwner = "Ben Nadel";
	systemEmail = config.systemEmail.address;

	request.response.title = title;

	include "./termsOfService.view.cfm";

</cfscript>
