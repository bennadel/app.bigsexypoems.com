<cfscript>

	// Define properties for dependency-injection.
	config = request.ioc.get( "config" );
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	requestMetadata = request.ioc.get( "core.lib.web.RequestMetadata" );
	router = request.ioc.get( "core.lib.web.Router" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// While these components are all cached in the application scope, they all need to
	// operate, in part, on requests-scoped variables. As such, we have to initialize the
	// request-scoped variables at the start of each request.
	requestMetadata.setupRequest();
	requestHelper.setupRequest();
	router.setupRequest();

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// Note: this is the one piece outside the core try/catch because it's the one piece
	// of data that I want any other view to be able to depend on.
	request.response = {
		statusCode: 200
	};

	// Most forms in this application post back to themselves for processing. For
	// aesthetic reasons, I'd like the URL for these post-back operations to remain the
	// same during the form processing life-cycle. This way, if we have to present an
	// error message to the user (after the form has been submitted), the URL is never
	// showing as "index.cfm"; but, rather, has the original URL of the page itself. To do
	// this, we're going to use the CGI.QUERY_STRING value to drive form actions, with any
	// additional data being provided as form inputs.
	request.postBackAction = router.buildPostBackAction();
	// Define globally convenient short-hands.
	request.isLive = config.isLive;
	request.isLocal = ! request.isLive;
	request.isGet = requestMetadata.isGet();
	request.isPost = requestMetadata.isPost();
	request.htmx = requestMetadata.getHtmxHeaders();
	request.isHtmx = request.htmx.request;

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	try {

		switch ( router.next( "member" ) ) {
			case "account":
			case "auth":
			case "member":
			case "playground":
			case "share":
			case "system":
				cfmodule( template = router.nextTemplate() );
			break;
			default:
				throw( type = "App.Routing.InvalidEvent" );
			break;
		}

	} catch ( any error ) {

		request.error = error;

		cfmodule( template = "./error/error.cfm" );

		// Edge-case: ColdFusion isn't always super reliable when it comes to creating the
		// per-application datasource during the bootstrapping process. If we ever get the
		// error that the datasource cannot be found, shut the application down and exit.
		// The next request should re-start the ColdFusion application and the datasource
		// will _likely_ have been created successfully at that point.
		// --
		// Note: the error will be logged within the error-module above.
		if (
			( error.type == "database" ) &&
			( error.message contains "datasource" ) &&
			( error.message contains "could not be found" )
			) {

			applicationStop();
			abort;

		}

	}

</cfscript>
