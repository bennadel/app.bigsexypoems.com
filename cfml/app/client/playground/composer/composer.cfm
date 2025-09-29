<cfscript>

	// Define properties for dependency-injection.
	router = request.ioc.get( "core.lib.web.Router" );
	sessionService = request.ioc.get( "core.lib.service.session.SessionService" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// This section doesn't require authentication, but it will be helpful to know if a
	// user is logged-in for some UI prompting.
	request.authContext = sessionService.getAuthenticationContext();

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	request.response.template = "default";

	switch ( router.next( "editor" ) ) {
		case "editor":
		case "rhymes":
		case "syllables":
		case "synonyms":
			cfmodule( template = router.nextTemplate( false ) );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

	switch ( request.response.template ) {
		case "blank":
			cfmodule( template = "./_layout/blank.cfm" );
		break;
		case "default":
			cfmodule( template = "./_layout/default.cfm" );
		break;
		default:
			throw( type = "App.Routing.InvalidTemplate" );
		break;
	}

</cfscript>
