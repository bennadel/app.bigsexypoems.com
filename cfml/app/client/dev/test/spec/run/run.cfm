<cfscript>

	// Define properties for dependency-injection.
	requestMetadata = request.ioc.get( "core.lib.web.RequestMetadata" );
	testRunner = request.ioc.get( "spec.TestRunner" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.suite" type="string" default="";
	param name="url.test" type="string" default="";

	// Test suites may take a while to run. Increase the request timeout so that we don't
	// run into premature termination of the test harness. That said, duration of test is
	// part of the UX of the application (granted, developer facing). As such, we don't
	// want to the tests to take too long. Keeping the timeout relatively low so that
	// going over it is a point of friction.
	cfsetting( requestTimeout = 20 );

	// Note: this is used in RequestMetadata::isTestRun() to remove some side-effect
	// behaviors that we don't need during a test suite execution.
	request.isTestRun = true;

	startedAt = getTickCount();
	results = testRunner.runAll(
		suiteFilter = url.suite,
		testFilter = url.test
	);
	duration = ( getTickCount() - startedAt );

	// Claude code will consume this as a JSON end-point.
	if ( requestMetadata.accepts( "application/json" ) ) {

		request.response.template = "binary";
		request.response.mimeType = "application/json";
		request.response.filename = "results.json";
		request.response.body = charsetDecode( serializeJson( results ), "utf-8" );

	} else {

		request.response.title = "Test Results";
		include "./run.view.cfm";

	}

</cfscript>
