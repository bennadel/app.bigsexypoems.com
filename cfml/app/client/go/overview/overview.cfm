<cfscript>

	// Define properties for dependency-injection.
	config = request.ioc.get( "config" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	title = request.response.title = "GO Links";

	links = [
		{
			stub: "play",
			description: "Playground poem composer"
		}
	];

	include "./overview.view.cfm";

	cfmodule( template = "/client/_shared/layout/blank.cfm" );

</cfscript>
