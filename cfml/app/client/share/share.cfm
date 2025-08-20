<cfscript>

	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	requestHelper.ensureXsrfToken();

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	switch ( router.next() ) {
		case "poem":
			cfmodule( template = router.nextTemplate() );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

</cfscript>
