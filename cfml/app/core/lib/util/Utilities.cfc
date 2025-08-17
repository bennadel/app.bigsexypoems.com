component
	output = false
	hint = "I provide miscellaneous utility functions."
	{

	/**
	* I return an abbreviated, flattened version of the given component metadata.
	*/
	public struct function getFlatMetadataIndex( required any input ) {

		var rootMetadata = getMetadata( input );
		// In order to make the chain visiting easier, let's create a fake "root" that
		// uses the input as a "parent". This way, the first step in our do-while loop can
		// always be an ".extends" navigation.
		var target = {
			extends: rootMetadata
		};
		// Stylistic choice, I'm using ordered structs here so that the "more concrete"
		// entries will be higher-up in the final collections. And, the "more abstract"
		// entries will be lower-down in the final collections.
		var propertyIndex = [:];
		var functionIndex = [:];

		do {

			target = target.extends;

			for ( var entry in target.properties ) {

				// Since we're walking up the component chain from more concrete to more
				// abstract, only include properties that haven't already been defined at
				// a more concrete level.
				if ( ! propertyIndex.keyExists( entry.name ) ) {

					propertyIndex[ entry.name ] = entry;

				}

			}

			for ( var entry in target.functions ) {

				// Since we're walking up the component chain from more concrete to more
				// abstract, only include functions that haven't already been defined at
				// a more concrete level.
				if ( ! functionIndex.keyExists( entry.name ) ) {

					functionIndex[ entry.name ] = entry;

				}

			}

		} while ( target.keyExists( "extends" ) );

		return {
			name: rootMetadata.name,
			propertyIndex: propertyIndex,
			functionIndex: functionIndex
		};

	}


	/**
	* I extract a temporary name from the given email address.
	*/
	public string function getNameFromEmail(
		required string email,
		string fallbackName = "New User"
		) {

		var name = email
			.listFirst( "@" )
			.reReplace( "[._-]+", " ", "all" )
			.trim()
			.reReplace( "(?:^|\b)(\S)", "\U\1", "all" )
		;

		if ( name.len() ) {

			return name.left( 50 );

		}

		return fallbackName;

	}

}
