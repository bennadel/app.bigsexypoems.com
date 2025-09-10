<cfscript>

	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	requestHelper.ensureXsrfToken();
	requestHelper.ensureAuthenticatedContext();

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	request.response.template = "default";

	switch ( router.next( "home" ) ) {
		case "home":
		case "poems":
		case "profile":
		case "sessions":
			cfmodule( template = router.nextTemplate() );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

	switch ( request.response.template ) {
		case "binary":
			cfmodule( template = "./_layout/binary/binary.cfm" );
		break;
		case "blank":
			cfmodule( template = "./_layout/blank/blank.cfm" );
		break;
		case "default":
			cfmodule( template = "./_layout/default/default.cfm" );
		break;
		default:
			throw( type = "App.Routing.InvalidTemplate" );
		break;
	}

</cfscript>
