<cfscript>

	router = request.ioc.get( "core.lib.web.Router" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	switch ( router.next( "editor" ) ) {
		case "editor":
			cfmodule( template = "./editor.cfm" );
		break;
		case "rhymes":
			cfmodule( template = "./rhymes.cfm" );
		break;
		case "synonyms":
			cfmodule( template = "./synonyms.cfm" );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

</cfscript>
