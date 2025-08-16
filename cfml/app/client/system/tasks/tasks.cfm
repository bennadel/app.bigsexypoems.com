<cfscript>

	router = request.ioc.get( "core.lib.web.Router" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	switch ( router.next() ) {
		case "all":
			cfmodule( template = "./all/all.cfm" );
		break;
		case "one":
			cfmodule( template = "./one/one.cfm" );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

</cfscript>
