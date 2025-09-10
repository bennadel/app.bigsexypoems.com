<cfscript>

	router = request.ioc.get( "core.lib.web.Router" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	request.response.activeNav = "account.session";

	switch ( router.next( "list" ) ) {
		case "list":
			cfmodule( template = router.nextTemplate() );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

</cfscript>
