<cfscript>

	router = request.ioc.get( "core.lib.web.Router" );
	sessionService = request.ioc.get( "core.lib.service.session.SessionService" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.redirectTo" type="string" default="";

	sessionService.logout();

	if ( router.isInternalUrl( url.redirectTo ) ) {

		router.gotoUrl( url.redirectTo );

	} else {

		router.goto([
			event: "auth.logout.success"
		]);

	}

</cfscript>
