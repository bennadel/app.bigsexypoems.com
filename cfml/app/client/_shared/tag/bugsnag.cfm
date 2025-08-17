<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	config = request.ioc.get( "config" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	startConfig = [
		apiKey: config.bugsnag.client.apiKey,
		releaseStage: config.bugsnag.client.releaseStage
	];

	if ( val( request.authContext?.user?.id ) ) {

		startConfig.user = [
			id: request.authContext.user.id,
			email: request.authContext.user.email
		];

	}

	include "./bugsnag.view.cfm";

</cfscript>
