<cfscript>

	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// SECURITY: This entire subsystem requires an authenticated user.
	request.authContext = requestHelper.ensureAuthenticatedContext();

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	request.response.template = "default";

	switch ( router.next( "profile" ) ) {
		case "profile":
			cfmodule( template = "./profile/profile.cfm" );
		break;
		case "session":
			cfmodule( template = "./session/session.cfm" );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

	switch ( request.response.template ) {
		case "default":
			cfmodule( template = "./_layout/default/default.cfm" );
		break;
		default:
			throw( type = "App.Routing.InvalidTemplate" );
		break;
	}

</cfscript>
