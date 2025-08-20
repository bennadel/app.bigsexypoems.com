<cfscript>

	router = request.ioc.get( "core.lib.web.Router" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	switch ( router.next() ) {
		case "tasks":
			cfmodule( template = router.nextTemplate() );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

	cfmodule( template = "./_layout/layout.cfm" );

</cfscript>
