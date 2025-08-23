component hint = "I provide low-level HTTP access to the Datamuse API." {

	// Define properties for dependency-injection.
	property name="httpUtilities" ioc:type="core.lib.util.HttpUtilities";

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
		numeric timeoutInSeconds = 5
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

		var fileContent = httpUtilities.getFileContentAsString( httpResponse );

		if ( httpUtilities.statusCodeIsFailure( httpResponse ) ) {

			throw(
				type = "DatamuseGateway.ApiFailure",
				message = "Datamuse API error.",
				detail = "Returned with status code: #httpResponse.statusCode#",
				extendedInfo = fileContent
			);

		}

		try {

			return deserializeJson( fileContent );

		} catch ( any error ) {

			throw(
				type = "DatamuseGateway.PayloadError",
				message = "Datamuse API response consumption error.",
				detail = "Returned with status code: #httpResponse.statusCode#",
				extendedInfo = fileContent
			);

		}

	}

}
