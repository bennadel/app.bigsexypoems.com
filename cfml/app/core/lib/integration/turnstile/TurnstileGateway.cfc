component
	output = false
	hint = "I provide low-level HTTP access to the Cloudflare Turnstile API."
	{

	// Define properties for dependency-injection.
	property name="httpUtilities" ioc:type="core.lib.util.HttpUtilities";
	property name="turnstile" ioc:get="config.turnstile";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I verify the given Cloudflare Turnstile challenge token.
	*/
	public struct function siteVerify(
		required string token,
		required string ipAddress,
		numeric timeoutInSeconds = 5
		) {

		cfhttp(
			result = "local.httpResponse",
			method = "post",
			url = "https://challenges.cloudflare.com/turnstile/v0/siteverify",
			getAsBinary = "yes",
			timeout = timeoutInSeconds
			) {

			cfhttpparam(
				type = "formfield",
				name = "secret",
				value = turnstile.server.apiKey
			);
			cfhttpparam(
				type = "formfield",
				name = "response",
				value = token
			);
			cfhttpparam(
				type = "formfield",
				name = "remoteip",
				value = ipAddress
			);
		}

		var fileContent = httpUtilities.getFileContentAsString( httpResponse );

		if ( httpUtilities.statusCodeIsFailure( httpResponse ) ) {

			throw(
				type = "TurnstileGateway.ApiFailure",
				message = "Cloudflare Turnstile API error.",
				detail = "Returned with status code: #httpResponse.statusCode#",
				extendedInfo = fileContent
			);

		}

		try {

			// Example response:
			// {
			//   "success": true,
			//   "error-codes": [],
			//   "challenge_ts": "2022-10-06T00:07:23.274Z",
			//   "hostname": "example.com"
			// }
			return deserializeJson( fileContent );

		} catch ( any error ) {

			throw(
				type = "TurnstileGateway.PayloadError",
				message = "Cloudflare Turnstile API response consumption error.",
				detail = "Returned with status code: #httpResponse.statusCode#",
				extendedInfo = fileContent
			);

		}

	}

}
