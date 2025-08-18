<cfscript>

	router = request.ioc.get( "core.lib.web.Router" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	switch ( router.next( "list" ) ) {
		case "add":
			cfmodule( template = "./add/add.cfm" );
		break;
		case "compose":
			cfmodule( template = "./compose/compose.cfm" );
		break;
		case "edit":
			cfmodule( template = "./edit/edit.cfm" );
		break;
		case "delete":
			cfmodule( template = "./delete/delete.cfm" );
		break;
		case "list":
			cfmodule( template = "./list/list.cfm" );
		break;
		case "shares":
			cfmodule( template = "./shares/shares.cfm" );
		break;
		case "view":
			cfmodule( template = "./view/view.cfm" );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

</cfscript>
