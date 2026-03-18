component hint = "I provide methods for base64url encoding and decoding." {

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I decode the given base64url string back to the original binary value.
	*/
	public binary function decode( required string encodedValue ) {

		var result = encodedValue
			.replace( "-", "+", "all" )
			.replace( "_", "/", "all" )
		;

		return binaryDecode( ensurePadding( result ), "base64" );

	}


	/**
	* I decode the given base64url string back to its original string value.
	*/
	public string function decodeString( required string encodedValue ) {

		return charsetEncode( decode( encodedValue ), "utf-8" );

	}


	/**
	* I encode the given binary value as a base64url string.
	*/
	public string function encode( required binary value ) {

		return binaryEncode( value, "base64" )
			.replace( "+", "-", "all" )
			.replace( "/", "_", "all" )
			.reReplace( "=+$", "" )
		;

	}


	/**
	* I encode the given string value as a base64url string.
	*/
	public string function encodeString( required string value ) {

		return encode( charsetDecode( value, "utf-8" ) );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* When the base64 value is converted to base64url, the padding is stripped. I re-pad
	* the given value, as part of the conversion from base64url back to base64, ensuring
	* that its length is a multiple of 4. This is required by the binaryDecode() method,
	* which will throw an error if the length of the input is not correct.
	*/
	private string function ensurePadding( required string recoded ) {

		var paddingLength = ( ( 4 - ( recoded.len() % 4 ) ) % 4 );

		return ( recoded & repeatString( "=", paddingLength ) );

	}

}
