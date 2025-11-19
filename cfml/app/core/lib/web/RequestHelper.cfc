component {

	// Define properties for dependency-injection.
	property name="config" ioc:type="config";
	property name="errorTranslator" ioc:type="core.lib.web.ErrorTranslator";
	property name="logger" ioc:type="core.lib.util.Logger";
	property name="requestMetadata" ioc:type="core.lib.web.RequestMetadata";
	property name="router" ioc:type="core.lib.web.Router";
	property name="sessionService" ioc:type="core.lib.service.session.SessionService";
	property name="xsrfTokens" ioc:type="core.lib.web.XsrfTokens";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I perform generic pre-processing of the request.
	*/
	public void function setupRequest() {

		trimScopeValues( url );
		trimScopeValues( form );

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I return an authentication context, ensuring that the user is authentication. If the
	* user isn't authenticated, I redirect the request to the auth subsystem.
	*/
	public struct function ensureAuthenticatedContext() {

		request.authContext = sessionService.getAuthenticationContext();

		if ( ! request.authContext.session.isAuthenticated ) {

			router.goto([
				event: "auth.login",
				redirectTo: router.getInternalUrl()
			]);

		}

		return request.authContext;

	}


	/**
	* I return an authentication context, ensuring that the user is identified. If the
	* user isn't identified, I redirect the request to the auth subsystem.
	*/
	public struct function ensureIdentifiedContext() {

		request.authContext = sessionService.getAuthenticationContext();

		if ( ! request.authContext.session.isIdentified ) {

			router.goto([
				event: "auth.identify",
				redirectTo: router.getInternalUrl()
			]);

		}

		return request.authContext;

	}


	/**
	* I ensure that the URL scope only contains the given search params. If any additional
	* params are present, an error is thrown.
	*/
	public void function ensureStrictSearchParams( required array searchParams ) {

		// While not technically a query-string parameter, the path-info represents a part
		// of the URL that can change independently of the script name. As such, for the
		// purposes of locking the URL down to a set of search parameters, we're going to
		// treat the path-info as if it were a search parameter.
		if ( requestMetadata.getPathInfo().len() ) {

			throw(
				type = "App.Forbidden",
				message = "URL contains non-strict path-info."
			);

		}

		var scope = url.copy();

		for ( var key in searchParams ) {

			scope.delete( key );

		}

		// Now that we've deleted all the matching keys, the scope SHOULD BE empty. If the
		// scope is NOT empty, it means the request has unexpected url entries.
		if ( ! scope.isEmpty() ) {

			throw(
				type = "App.Forbidden",
				message = "URL contains non-strict parameters."
			);

		}

	}


	/**
	* I ensure that the current request has an XSRF token cookie; and, that any POST has
	* the XSRF token challenge.
	*/
	public string function ensureXsrfToken() {

		request.xsrfToken = xsrfTokens.ensureCookie();

		if ( request.isPost ) {

			xsrfTokens.testRequest();

		}

		return request.xsrfToken;

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


	/**
	* I process the given error and return the error response. Unlike the main process
	* error call, this one does not apply any changes to the status code so that HTMX will
	* still render the content.
	*/
	public struct function processErrorForHtmx( required any error ) {

		logger.logException( error );

		return errorTranslator.translate( error );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I trim the simple values in the given scope.
	* 
	* Note: this is assumed to run AFTER the field-group polyfill has been applied.
	* 
	* Note: in the long term, I can come up with a way to opt-out of this, probably with
	* some sort of sibling "noTrim" field; but for now, I'm assuming that all simple
	* values should be trimmed.
	*/
	private void function trimScopeValues( required struct scope ) {

		scope.each(
			( key, value ) => {

				scope[ key ] = trimScopeValuesRecursively( value );

			}
		);

	}


	/**
	* I recurse down the given data structure, trimming all simple fields.
	*/
	private any function trimScopeValuesRecursively( required any value ) {

		if ( isSimpleValue( value ) ) {

			return trim( value )
				// This isn't strictly part of the "trim" operation; but it is white-space
				// replaced. I'd like to normalize the line-endings on the request as
				// well. This will just make some in-request reFind()/reReplace() type
				// operations easier.
				.reReplace( "\r\n?", chr( 10 ), "all" )
			;

		}

		if ( isArray( value ) ) {

			return value.map( ( subvalue ) => trimScopeValuesRecursively( subvalue ) );

		}

		if ( isStruct( value ) ) {

			return value.map( ( key, subvalue ) => trimScopeValuesRecursively( subvalue ) );

		}

		return value;

	}

}
