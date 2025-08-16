component {

	// Define properties for dependency-injection.
	property name="config" ioc:type="config";
	property name="errorTranslator" ioc:type="core.lib.web.ErrorTranslator";
	property name="logger" ioc:type="core.lib.util.Logger";
	property name="requestMetadata" ioc:type="core.lib.web.RequestMetadata";
	property name="router" ioc:type="core.lib.web.Router";
	property name="sessionService" ioc:type="core.lib.service.session.SessionService";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I return an authentication context, ensuring that the user is authentication. If the
	* user isn't authenticated, I redirect the request to the auth subsystem.
	*/
	public struct function ensureAuthenticatedContext() {

		var authContext = sessionService.getAuthenticationContext();

		if ( ! authContext.session.isAuthenticated ) {

			router.goto([
				event: "auth.login",
				redirectTo: router.getInternalUrl()
			]);

		}

		return authContext;

	}


	/**
	* I return an authentication context, ensuring that the user is identified. If the
	* user isn't identified, I redirect the request to the auth subsystem.
	*/
	public struct function ensureIdentifiedContext() {

		var authContext = sessionService.getAuthenticationContext();

		if ( ! authContext.session.isIdentified ) {

			router.goto([
				event: "auth.identify",
				redirectTo: router.getInternalUrl()
			]);

		}

		return authContext;

	}


	/**
	* I process the given error, applying the proper status code to the template, and
	* returning the error response.
	*/
	public struct function processError( required any error ) {

		logger.logException( error );

		var errorResponse = errorTranslator.translate( error );

		request.response.statusCode = errorResponse.statusCode;
		request.response.statusText = errorResponse.statusText;

		// Used to output error in local debugging.
		request.error = error;

		return errorResponse;

	}

}
