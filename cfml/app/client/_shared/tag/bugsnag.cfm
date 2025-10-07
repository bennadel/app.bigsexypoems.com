<cfscript>

	// Define properties for dependency-injection.
	config = request.ioc.get( "config" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

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
	exit;

</cfscript>
