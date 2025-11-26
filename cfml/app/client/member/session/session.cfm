<cfscript>

	// Define properties for dependency-injection.
	router = request.ioc.get( "core.lib.web.Router" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	request.response.activeNav = "sessions";
	request.response.breadcrumbs.append([ "Home", "member.home" ]);
	request.response.breadcrumbs.append([ "Sessions", "member.session" ]);

	switch ( router.next( "list" ) ) {
		case "list":
			cfmodule( template = router.nextTemplate() );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

</cfscript>
