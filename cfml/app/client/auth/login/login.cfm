<cfscript>

	router = request.ioc.get( "core.lib.web.Router" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	switch ( router.next( "request" ) ) {
		case "request":
			cfmodule( template = "./request/request.cfm" );
		break;
		case "sent":
			cfmodule( template = "./sent/sent.cfm" );
		break;
		case "verify":
			cfmodule( template = "./verify/verify.cfm" );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

</cfscript>
