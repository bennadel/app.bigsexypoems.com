component hint = "I provide low-level HTTP access to the Datamuse API." {

	// Define properties for dependency-injection.
	property name="httpUtilities" ioc:type="core.lib.util.HttpUtilities";
	property name="logger" ioc:type="core.lib.util.Logger";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I make the HTTP request to the Datamuse API.
	*/
	public any function makeRequest(
		required string resource,
		required struct searchParams,
		required numeric timeoutInSeconds
		) {

		cfhttp(
			result = "local.httpResponse",
			method = "get",
			url = "https://api.datamuse.com/#resource#",
			getAsBinary = "yes",
			timeout = timeoutInSeconds
			) {

			for ( var key in searchParams ) {

				cfhttpparam(
					type = "url",
					name = key,
					value = searchParams[ key ]
				);

			}
		}

		var statusCode = httpUtilities.parseStatusCode( httpResponse );
		var fileContent = httpUtilities.getFileContentAsString( httpResponse );

		if ( ! statusCode.ok ) {

			throw(
				type = "DatamuseGateway.StatusCode.NotOk",
				message = "Datamuse API status code error.",
				detail = "Returned with status code: #statusCode.original#",
				extendedInfo = fileContent,
				// Embed the status code as an accessible property on the error so it can
				// be read during they retry loop.
				errorCode = statusCode.code
			);

		}

		try {

			return deserializeJson( fileContent );

		} catch ( any error ) {

			throw(
				type = "DatamuseGateway.FileContent.ParseError",
				message = "Datamuse API response consumption error.",
				detail = "Returned with status code: #httpResponse.statusCode#",
				extendedInfo = fileContent
			);

		}

	}


	/**
	* I make the HTTP request to the Datamuse API using a back-off retry pattern.
	*/
	public any function makeRequestWithRetry(
		required string resource,
		required struct searchParams,
		required numeric timeoutInSeconds
		) {

		for ( var duration in httpUtilities.getBackoffDurations() ) {

			try {

				return makeRequest( argumentCollection = arguments );

			} catch ( DatamuseGateway.StatusCode.NotOk error ) {

				if ( ! duration ) {

					rethrow;

				}

				if ( ! httpUtilities.statusCodeIsRetriable( error.errorCode ) ) {

					rethrow;

				}

				logger.warning(
					"Retrying HTTP request for Datamuse.",
					{
						statusCode: error.errorCode,
						duration: duration,
						fileContent: error.extendedInfo
					}
				);

				sleep( duration );

			}

		}

	}

}
