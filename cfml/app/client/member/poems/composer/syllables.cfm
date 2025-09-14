<cfscript>

	// Define properties for dependency-injection.
	ui = request.ioc.get( "core.lib.web.UI" );
	wordService = request.ioc.get( "core.lib.util.WordService" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="form.content" type="string";

	partial = getPartial( form.content );
	lineCounts = partial.lineCounts;

	request.response.template = "blank";

	include "./syllables.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial( required string input ) {

		var counts = wordService.getSyllableCountForLines( input );

		// When the syllable counts are calculated, empty lines are stripped out and only
		// valid tokens are inspected. This creates a disconnect with the counts that come
		// back and the actual layout of the lines. Let's try to reconnect those values
		// with some massaging. There are edge-cases that this won't account for; but, it
		// will get us closer.
		var lineCounts = input
			.reReplace( "\r\n?", chr( 10 ), "all" )
			.reMatch( "[^\n]*" )
			.map(
				( line ) => {

					if ( ! counts.len() ) {

						return 0;

					}

					if ( ! wordService.tokenize( line ).len() ) {

						return 0;

					}

					return counts.shift();

				}
			)
		;

		return {
			lineCounts
		};

	}

</cfscript>
