<cfscript>

	// Define properties for dependency-injection.
	router = request.ioc.get( "core.lib.web.Router" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	switch ( router.next( "list" ) ) {
		case "add":
		case "composer":
		case "edit":
		case "delete":
		case "list":
		case "share":
		case "view":
			cfmodule( template = router.nextTemplate() );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

</cfscript>
