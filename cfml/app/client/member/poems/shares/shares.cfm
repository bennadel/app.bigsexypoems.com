<cfscript>

	router = request.ioc.get( "core.lib.web.Router" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	switch ( router.next( "list" ) ) {
		case "add":
			cfmodule( template = "./add/add.cfm" );
		break;
		case "delete":
			cfmodule( template = "./delete/delete.cfm" );
		break;
		case "deleteAll":
			cfmodule( template = "./deleteAll/deleteAll.cfm" );
		break;
		case "list":
			cfmodule( template = "./list/list.cfm" );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

</cfscript>
