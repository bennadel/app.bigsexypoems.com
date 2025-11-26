<cfscript>

	// Define properties for dependency-injection.
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	requestHelper.ensureXsrfToken();
	requestHelper.ensureAuthenticatedContext();

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	request.response.template = "default";
	request.response.breadcrumbs = [];

	switch ( router.next( "home" ) ) {
		case "collection":
		case "home":
		case "poem":
		case "profile":
		case "session":
		case "tag":
			cfmodule( template = router.nextTemplate() );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

	switch ( request.response.template ) {
		case "binary":
			cfmodule( template = "/client/_shared/layout/binary.cfm" );
		break;
		case "blank":
			cfmodule( template = "/client/_shared/layout/blank.cfm" );
		break;
		case "default":
			cfmodule( template = "./_shared/layout/default.cfm" );
		break;
		default:
			throw( type = "App.Routing.InvalidTemplate" );
		break;
	}

</cfscript>
