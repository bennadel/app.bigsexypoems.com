component hint = "I provide high-level HTTP access to the Cloudflare Turnstile API." {

	// Define properties for dependency-injection.
	property name="gateway" ioc:type="core.lib.integration.turnstile.TurnstileGateway";
	property name="httpUtilities" ioc:type="core.lib.util.HttpUtilities";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I test the given Cloudflare Turnstile challenge token provided by the client-side
	* form. If the challenge passes successfully, the method exists. Otherwise, it throws
	* an error.
	*/
	public void function testToken(
		required string token,
		required string ipAddress
		) {

		if ( ! verifyToken( argumentCollection = arguments ) ) {

			throw(
				type = "TurnstileClient.VerificationFailure",
				message = "Cloudflare Turnstile verification failure.",
				detail = "Challenge did not pass, user might be a bot."
			);

		}

	}


	/**
	* I verify the given Cloudflare Turnstile challenge token.
	*/
	public boolean function verifyToken(
		required string token,
		required string ipAddress
		) {

		// If no token has been provided by the Turnstyle system, then we know the user is
		// attempting to bypass the security. There's no need to make the API call.
		if ( ! token.len() ) {

			throw(
				type = "TurnstileClient.InvalidToken",
				message = "Cloudflare Turnstile token is empty."
			);

		}

		var apiResponse = gateway.siteVerify( token, ipAddress );

		return apiResponse.success;

	}

}
