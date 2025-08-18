<cfscript>

	router = request.ioc.get( "core.lib.web.Router" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	switch ( router.next( "list" ) ) {
		case "add":
		case "delete":
		case "deleteAll":
		case "list":
			cfmodule( template = "./#router.segment()#/#router.segment()#.cfm" );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

</cfscript>
