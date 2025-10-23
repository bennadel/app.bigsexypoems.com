component {

	// Define properties for dependency-injection.
	property name="errorUtilities" ioc:type="core.lib.util.ErrorUtilities";
	property name="utilities" ioc:type="core.lib.util.ValidationUtilities";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I assert that the given input looks like a valid email address.
	*/
	public void function assertEmail(
		required string input,
		required string errorType
		) {

		if ( ! input.reFind( "^[^@]+@[^.]+(\.[^.]+)+" ) ) {

			throw( type = errorType );

		}

	}


	/**
	* I assert that the given input is a 6-digit hex color
	*/
	public void function assertHexColor(
		required string input,
		required string errorType
		) {

		if ( ! input.reFind( "^[a-z0-f]{6}$" ) ) {

			throw( type = errorType );

		}

	}


	/**
	* I assert that the given input looks like a valid IP address.
	*/
	public void function assertIpAddress(
		required string input,
		required string errorType
		) {

		if ( input.reFind( "[^0-9a-f:.]" ) ) {

			throw( type = errorType );

		}

	}


	/**
	* I assert that the given input is the given length.
	*/
	public void function assertLength(
		required string input,
		required numeric length,
		required string errorType
		) {

		if ( input.len() != length ) {

			throw(
				type = errorType,
				extendedInfo = embedMetadata({
					length: length
				})
			);

		}

	}


	/**
	* I assert that the given input falls within the given length.
	*/
	public void function assertMaxLength(
		required string input,
		required numeric maxLength,
		required string errorType
		) {

		if ( input.len() > maxLength ) {

			throw(
				type = errorType,
				extendedInfo = embedMetadata({
					maxLength: maxLength
				})
			);

		}

	}


	/**
	* I assert that the given input is not empty.
	*/
	public void function assertNotEmpty(
		required string input,
		required string errorType
		) {

		if ( ! input.len() ) {

			throw( type = errorType );

		}

	}


	/**
	* I assert that the given input doesn't look like a test / temporary email address.
	*/
	public void function assertNotExampleEmail(
		required string input,
		required string errorType
		) {

		if (
			input.find( "@example.com" ) ||
			input.find( "@test.com" )
			) {

			throw( type = errorType );

		}

	}


	/**
	* I assert that the given input doesn't contain encoded characters.
	*/
	public void function assertUniformEncoding(
		required string input,
		required string errorType
		) {

		if ( input != utilities.canonicalizeInput( input ) ) {

			throw( type = errorType );

		}

	}


	/**
	* I assert that the given input looks like a valid url.
	*/
	public void function assertUrl(
		required string input,
		required string errorType
		) {

		if ( ! input.reFindNoCase( "^https?://." ) ) {

			throw( type = errorType );

		}

	}


	/**
	* I return a string that can be used as the embedded metadata in an extendedInfo field
	* overload.
	*/
	public string function embedMetadata( required struct metadata ) {

		return errorUtilities.embedMetadata( metadata );

	}


	/**
	* I return a normalized string value.
	*/
	public string function normalizeString( required string input ) {

		return trim( input )
			.reReplace( "\r\n?", chr( 10 ), "all" )
		;

	}


	/**
	* I run the given input through the validation pipeline and return the input.
	*/
	public any function pipeline(
		required any input,
		required struct assertionMethods
		) {

		// In order for the pipeline processing to work as expected, list of assertions
		// needs to be defined within an ordered struct. Otherwise, we might end up doing
		// work that is not anticipated.
		if ( ! assertionMethods.isOrdered() ) {

			throw(
				type = "BaseValidation.InvalidAssertions",
				message = "The pipeline() assertions must be passed as an ordered struct."
			);

		}

		for ( var methodName in assertionMethods ) {

			invoke(
				this,
				methodName,
				assertionMethods[ methodName ].prepend( input )
			);

		}

		return input;

	}

}
