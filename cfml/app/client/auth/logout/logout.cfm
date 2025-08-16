<cfscript>

	router = request.ioc.get( "core.lib.web.Router" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	switch ( router.next( "default" ) ) {
		case "default":
			cfmodule( template = "./default/default.cfm" );
		break;
		case "success":
			cfmodule( template = "./success/success.cfm" );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

</cfscript>
