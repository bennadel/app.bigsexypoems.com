<cfscript>

	router = request.ioc.get( "core.lib.web.Router" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	switch ( router.next( "login" ) ) {
		case "login":
			cfmodule( template = "./login/login.cfm" );
		break;
		case "logout":
			cfmodule( template = "./logout/logout.cfm" );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

	cfmodule( template = "./_layout/layout.cfm" );

</cfscript>
