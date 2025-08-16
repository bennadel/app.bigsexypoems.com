<cfscript>

	writeOutput( generateSlug( 6 ) );


	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I generate a slug to be used with the emulated encapsulation. The slug will always
	* start with a letter so that it can be used as a JavaScript variable.
	*/
	private string function generateSlug( required numeric length ) {

		var letters = "abcdefghijklmnopqrstuvwxyz";
		var numbers = "0123456789";
		var both = "#letters##numbers#";

		// Always start with a letter.
		var chars = [ letters[ randRange( 1, letters.len(), "sha1prng" ) ] ];

		while ( chars.len() < length ) {

			chars.append( both[ randRange( 1, both.len(), "sha1prng" ) ] );

		}

		return chars.toList( "" );

	}

</cfscript>
