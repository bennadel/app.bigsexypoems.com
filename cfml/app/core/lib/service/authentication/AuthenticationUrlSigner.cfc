component {

	// Define properties for dependency-injection.
	property name="loginRequestKey" ioc:get="config.keys.hmacSha512.loginRequest";
	property name="loginRequestKeyBinary" ioc:skip;
	property name="pepper" ioc:skip;

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the url signer.
	*/
	public void function $init() {

		variables.loginRequestKeyBinary = binaryDecode( loginRequestKey, "base64" );
		variables.pepper = "x78xt8";

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I generate the URL signature.
	*/
	public string function generateSignature(
		required string email,
		required numeric offsetInMinutes,
		required string redirectTo,
		required string token,
		required string salt
		) {

		var parts = [ email, offsetInMinutes, redirectTo, token, salt, pepper ];

		return hmac( parts.toList( "/" ), loginRequestKeyBinary, "hmacsha512" )
			.lcase()
		;

	}


	/**
	* I test the URL signature.
	*/
	public void function testSignature(
		required string email,
		required numeric offsetInMinutes,
		required string redirectTo,
		required string token,
		required string salt,
		required string signature
		) {

		var expectedSignature = generateSignature( email, offsetInMinutes, redirectTo, token, salt );

		if ( compare( signature, expectedSignature ) ) {

			throw(
				type = "App.Url.SignatureMismatch",
				message = "Magic link URL signature does match expected signature.",
				detail = "Signature: [#signature#], Expected signature: [#expectedSignature#]."
			);

		}

	}

}
