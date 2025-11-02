component hint = "I provide methods for generating and verifying one-time tokens." {

	// Define properties for dependency-injection.
	property name="model" ioc:type="core.lib.model.oneTimeToken.OneTimeTokenModel";
	property name="secureRandom" ioc:type="core.lib.util.SecureRandom";
	property name="validation" ioc:type="core.lib.model.oneTimeToken.OneTimeTokenValidation";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create and return the next random token. An optional passcode and value can be
	* associated with the token for subsequent validation.
	*/
	public string function createToken(
		required numeric ttlInMinutes,
		string passcode = "",
		string value = ""
		) {

		var slug = secureRandom.getToken( 32 );
		var expiresAt = utcNow()
			.add( "n", ttlInMinutes )
		;

		var id = model.create(
			slug = slug,
			passcode = passcode,
			value = value,
			expiresAt = expiresAt
		);

		return "#id#.#slug#";

	}


	/**
	* I maybe get the token with passcode confirmation.
	*/
	public struct function maybeGetToken(
		required string token,
		string passcode = ""
		) {

		var id = val( token.listFirst( "." ) );
		var slug = token.listRest( "." );

		lock
			name = "OneTimeTokens.maybeGetToken.#token#"
			type = "exclusive"
			timeout = 5
			{

			var maybeResult = model.maybeGet( id );

			if ( ! maybeResult.exists ) {

				return maybeResult;

			}

			model.deleteByFilter( id = id );

		}

		if ( maybeResult.value.expiresAt <= utcNow() ) {

			return maybeNew();

		}

		if ( compare( passcode, maybeResult.value.passcode ) ) {

			return maybeNew();

		}

		return maybeResult;

	}


	/**
	* I test the given token to see if it is valid.
	*/
	public void function testToken(
		required string token,
		string passcode = ""
		) {

		if ( ! maybeGetToken( argumentCollection = arguments ).exists ) {

			validation.throwNotFoundError();

		}

	}

}
