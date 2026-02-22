<cfscript>

	// Define properties for dependency-injection.
	config = request.ioc.get( "config" );
	router = request.ioc.get( "core.lib.web.Router" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// The dev subsystem is only available in non-production environments.
	if ( config.isLive ) {

		throw( type = "App.Routing.InvalidEvent" );

	}

	switch ( router.next() ) {
		// case "something":
		// 	cfmodule( template = router.nextTemplate() );
		// break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

	cfmodule( template = "./_shared/layout/default.cfm" );

</cfscript>
