<cfscript>

	// Define properties for dependency-injection.
	authenticationService = request.ioc.get( "core.lib.service.authentication.AuthenticationService" );
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	sessionService = request.ioc.get( "core.lib.service.session.SessionService" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// Since the verification link is being provided via an email, we don't want the
	// values in the URL to be processed directly from the URL scope. Some email providers
	// will try to pre-cache links within an email (for faster rendering). As such, we
	// need to have a form that auto-submits upon loading so that we only process the
	// verification data during a form POST and not accidentally during an email-client
	// pre-render. To the user, there should be no (basically) difference.

	param name="url.email" type="string";
	param name="url.offsetInMinutes" type="string";
	param name="url.redirectTo" type="string";
	param name="url.token" type="string";
	param name="url.signature" type="string";

	errorMessage = "";

	if ( request.isPost ) {

		try {

			userID = authenticationService.verifyMagicLink(
				email = url.email,
				offsetInMinutes = val( url.offsetInMinutes ),
				redirectTo = url.redirectTo,
				token = url.token,
				signature = url.signature
			);

			sessionService.createSession(
				userID = userID,
				isAuthenticated = true
			);

			// Security: since the redirectTo as part of the signature generation and
			// verification, we know that it hasn't been tempered with and has already
			// been proven to be an INTERNAL url (during the request-sending).
			router.gotoUrl( url.redirectTo );

		} catch ( any error ) {

			errorMessage = requestHelper.processError( error )
				.message
			;

		}

	}

	if ( errorMessage.len() ) {

		title = request.response.title = "Could Not Verify Login";

		include "./verify.error.cfm";

	} else {

		title = request.response.title = "Verify Login";

		include "./verify.view.cfm";

	}

</cfscript>
