<cfscript>

	router = request.ioc.get( "core.lib.web.Router" );
	xsrfTokens = request.ioc.get( "core.lib.web.XsrfTokens" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// The `response` object is for HTTP-level configuration.
	request.response = {
		statusCode: 200,
		statusText: "OK"
	};

	try {

		// Most forms in this application post back to themselves for processing. For
		// aesthetic reasons, I'd like the URL for these post-back operations to remain
		// the same during the form processing life-cycle. This way, if we have to present
		// an error message to the user (after the form has been submitted), the URL is
		// never showing as "index.cfm"; but, rather, has the original URL of the page
		// itself. To do this, we're going to use the CGI.QUERY_STRING value to drive form
		// actions, with any additional form data (ex, "submitted") being provided as
		// additional form inputs.
		request.postBackAction = router.buildPostBackAction();

		// --------------------------------------------------------------------------- //
		// --------------------------------------------------------------------------- //

		param name="form.submitted" type="boolean" default=false;

		request.xsrfToken = xsrfTokens.ensureCookie();

		// All form submissions must include a valid XSRF token.
		if ( form.submitted ) {

			xsrfTokens.testRequest();

		}

		// --------------------------------------------------------------------------- //
		// --------------------------------------------------------------------------- //

		switch ( router.next( "member" ) ) {
			case "account":
				cfmodule( template = "./account/account.cfm" );
			break;
			case "auth":
				cfmodule( template = "./auth/auth.cfm" );
			break;
			case "member":
				cfmodule( template = "./member/member.cfm" );
			break;
			case "share":
				cfmodule( template = "./share/share.cfm" );
			break;
			case "system":
				cfmodule( template = "./system/system.cfm" );
			break;
			default:
				throw( type = "App.Routing.InvalidEvent" );
			break;
		}

	} catch ( any error ) {

		request.error = error;

		cfmodule( template = "./error/error.cfm" );

	}

</cfscript>
