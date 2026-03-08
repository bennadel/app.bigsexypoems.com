<cfscript>

	// Define properties for dependency-injection.
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	testRunner = request.ioc.get( "spec.TestRunner" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	title = "Test Cleanup";
	errorResponse = "";

	request.response.title = title;

	if ( request.isPost ) {

		try {

			testRunner.cleanup();

			router.goto([
				event: "dev.test.spec.cleanup",
				flash: "dev.test.cleanup.completed"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./cleanup.view.cfm";

</cfscript>
