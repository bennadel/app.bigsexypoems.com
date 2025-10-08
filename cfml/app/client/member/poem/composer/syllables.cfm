<cfscript>

	// Define properties for dependency-injection.
	ui = request.ioc.get( "core.lib.web.UI" );
	wordService = request.ioc.get( "core.lib.util.WordService" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="form.content" type="string";

	// Under the hood, the WordService is making a remote HTTP API call to Datamuse. As
	// such, we need to increase the request timeout in order to accommodate the maximum
	// underlying gateway timeout.
	// --
	// Todo: I don't love the tight coupling here. I mean, I know that there's intrinsic
	// coupling because we have real-world timing constraints. But, I would like to figure
	// out a cleaner way to do this.
	cfsetting( requestTimeout = ( wordService.getMaxRequestTimeout() + 3 ) );

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
