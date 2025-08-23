component hint = "I provide utility methods for securely generating random values." {

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I generate a secure random key of a length recommended for the given algorithm.
	*/
	public binary function generateKeyForAlgorithm( required string algorithm ) {

		switch ( algorithm ) {
			// https://learn.microsoft.com/en-us/dotnet/api/system.security.cryptography.hmacsha256.-ctor?view=net-9.0
			case "HmacSHA256":
				return getBytes( 64 );
			break;
			// https://learn.microsoft.com/en-us/dotnet/api/system.security.cryptography.hmacsha384.-ctor?view=net-9.0
			case "HmacSHA384":
			// https://learn.microsoft.com/en-us/dotnet/api/system.security.cryptography.hmacsha512.-ctor?view=net-9.0
			case "HmacSHA512":
				return getBytes( 128 );
			break;
		}

		throw( type = "SecureRandom.UnsupportedAlgorithm" );

	}


	/**
	* I generate a cryptographically secure random byte.
	*/
	public numeric function getByte() {

		// Note: In Java, bytes are signed. Which means that the left-most bit (of the
		// byte) indicates the sign of the byte. In order to not jump through hoops to
		// convert a random INT into a SIGNED BYTE, we'll just produce an INT in the range
		// that we know will fit nicely into a byte, including the signed bit.
		return javaCast( "byte", getInt( -128, 127 ) );

	}


	/**
	* I generate a cryptographically secure random binary value with the given length.
	*/
	public binary function getBytes( required numeric byteCount ) {

		var bytes =  arrayNew( 1 )
			.resize( byteCount )
		;

		for ( var i = 1 ; i <= byteCount ; i++ ) {

			bytes[ i ] = getByte();

		}

		return javaCast( "byte[]", bytes );

	}


	/**
	* I generate a cryptographically secure random integer between the two values,
	* inclusive.
	*/
	public numeric function getInt(
		required numeric minValue,
		required numeric maxValue
		) {

		return randRange( minValue, maxValue, "sha1prng" );

	}


	/**
	* I generate a cryptographically secure random token of the given length. The token
	* is composed of URL-friendly characters.
	*/
	public string function getToken( required numeric tokenLength ) {

		// The set of character inputs that we can compose the random token.
		var charset = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
		var charsetCount = charset.len();

		var letters =  arrayNew( 1 )
			.resize( tokenLength )
		;

		for ( var i = 1 ; i <= tokenLength ; i++ ) {

			letters[ i ] = charset[ getInt( 1, charsetCount ) ];

		}

		return letters.toList( "" );

	}

}
