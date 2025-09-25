<cfscript>

	// Define properties for dependency-injection.
	authenticationService = request.ioc.get( "core.lib.service.authentication.AuthenticationService" );
	config = request.ioc.get( "config" );
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	requestMetadata = request.ioc.get( "core.lib.web.RequestMetadata" );
	router = request.ioc.get( "core.lib.web.Router" );
	sessionService = request.ioc.get( "core.lib.service.session.SessionService" );
	turnstileClient = request.ioc.get( "core.lib.integration.turnstile.TurnstileClient" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.redirectTo" type="string" default="";

	param name="form.email" type="string" default="";
	param name="form.betaPassword" type="string" default="";
	param name="form.timezoneOffsetInMinutes" type="string" default="";
	param name="form[ 'cf-turnstile-response' ]" type="string" default="";

	authContext = sessionService.getAuthenticationContext();

	// If the user is already logged-in, redirect them to the app.
	if ( authContext.session.isAuthenticated ) {

		nextUrl = router.isInternalUrl( url.redirectTo )
			? url.redirectTo
			: "/"
		;

		router.gotoUrl( nextUrl );

	}

	fromEmail = config.systemEmail.address;
	errorMessage = "";

	request.response.title = "Request Login / Signup";

	if ( request.isPost && form.email.len() ) {

		try {

			// For ease of development, Turnstile only required in production.
			if ( config.turnstile.isEnabled ) {

				turnstileClient.testToken( form[ "cf-turnstile-response" ], requestMetadata.getIpAddress() );

			}

			authenticationService.requestMagicLink(
				email = form.email,
				betaPassword = form.betaPassword,
				offsetInMinutes = val( form.timezoneOffsetInMinutes ),
				redirectTo = url.redirectTo
			);

			router.goto([
				event: "auth.login.sent"
			]);

		} catch ( any error ) {

			errorMessage = requestHelper.processError( error )
				.message
			;

			// Special overrides to create a better affordance for the user.
			switch ( error.type ) {
				case "App.Model.User.Email.Example":
					errorMessage = "Please enter a real email address.";
				break;
				case "App.Model.User.Email.Empty":
				case "App.Model.User.Email.Invalid":
				case "App.Model.User.Email.SuspiciousEncoding":
				case "App.Model.User.Email.TooLong":
					errorMessage = "Please enter a valid email address.";
				break;
				case "TurnstileClient.InvalidToken":
					errorMessage = "It looks like your one-time form token failed to load. This error happens intermittently (and is not your fault). Please try logging-in again.";
				break;
			}

		}

	}

	include "./request.view.cfm";

</cfscript>
