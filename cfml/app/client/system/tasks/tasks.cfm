<cfscript>

	router = request.ioc.get( "core.lib.web.Router" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	switch ( router.next() ) {
		case "all":
		case "one":
			cfmodule( template = router.nextTemplate() );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

</cfscript>
