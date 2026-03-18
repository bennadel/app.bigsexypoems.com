<cfscript>

	// Define properties for dependency-injection.
	router = request.ioc.get( "core.lib.web.Router" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	request.response.template = "default";

	switch ( router.next( "overview" ) ) {
		case "external":
		case "overview":
		case "play":
			cfmodule( template = router.nextTemplate() );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

	switch ( request.response.template ) {
		case "blank":
			cfmodule( template = "/client/_shared/layout/blank.cfm" );
		break;
		case "default":
			cfmodule( template = "./_shared/layout/default.cfm" );
		break;
		default:
			throw( type = "App.Routing.InvalidTemplate" );
		break;
	}

</cfscript>
