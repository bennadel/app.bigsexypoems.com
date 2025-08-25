component hint = "I provide methods for getting words related to other words." {

	// Define properties for dependency-injection.
	property name="datamuseClient" ioc:type="core.lib.integration.datamuse.DatamuseClient";
	property name="syllableCache" ioc:skip;
	property name="wordModel" ioc:type="core.lib.model.language.WordModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the word service.
	*/
	public void function init() {

		variables.syllableCache = {};

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I get the words that loosely relate to the given word.
	*/
	public array function getMeansLike(
		required string word,
		required numeric limit,
		string groupBy = "typeOfSpeech"
		) {

		word = word.lcase().trim();

		if ( ! word.len() ) {

			return [];

		}

		var results = datamuseClient
			.getMeansLike( word, limit )
			.filter(
				( result ) => {

					if (
						result.isUnknown ||
						result.isAntonym ||
						result.isProperNoun
						) {

						return false;

					}

					return true;

				}
			)
		;

		return ( groupBy == "syllableCount" )
			? groupBySyllableCount( results )
			: groupByTypeOfSpeech( results )
		;

	}


	/**
	* I get the words that rhyme with the given word.
	*/
	public array function getRhyme(
		required string word,
		required numeric limit,
		string groupBy = "syllableCount"
		) {

		word = word.lcase().trim();

		if ( ! word.len() ) {

			return [];

		}

		var results = datamuseClient
			.getRhyme( word, limit )
			.filter(
				( result ) => {

					if (
						result.isUnknown ||
						result.isProperNoun
						) {

						return false;

					}

					return true;

				}
			)
		;

		return ( groupBy == "syllableCount" )
			? groupBySyllableCount( results )
			: groupByTypeOfSpeech( results )
		;

	}


	/**
	* I get the syllable counts for the lines of text within the given input.
	*/
	public array function getSyllableCountForLines( required string input ) {

		var tokens = tokenize( input );

		if ( ! tokens.len() ) {

			return [];

		}

		ensureSyllableCountCache( tokens );

		// Now that we've ensured that the tokens are cached in memory, all we have to do
		// is count the number of syllables per line.
		var lines = input
			.reMatch( "[^\r\n]+" )
			.filter( ( line ) => line.trim().len() )
			.map(
				( line ) => {

					return tokenize( line ).reduce(
						( reduction, token ) => {

							// Note: if Datamuse couldn't find the word, we won't have a
							// cached match. In that case, default to 1 syllable.
							return ( reduction + ( syllableCache[ token ] ?: 1 ) );

						},
						0
					);

				}
			)
		;

		return lines;

	}


	/**
	* I get the words that strictly relate to the given word.
	*/
	public array function getSynonym(
		required string word,
		required numeric limit,
		string groupBy = "typeOfSpeech"
		) {

		word = word.lcase().trim();

		if ( ! word.len() ) {

			return [];

		}

		var results = datamuseClient
			.getSynonym( word, limit )
			.filter(
				( result ) => {

					if (
						result.isUnknown ||
						result.isAntonym ||
						result.isProperNoun
						) {

						return false;

					}

					return true;

				}
			)
		;

		return ( groupBy == "syllableCount" )
			? groupBySyllableCount( results )
			: groupByTypeOfSpeech( results )
		;

	}


	/**
	* I break the given input up into normalized tokens.
	*/
	public array function tokenize( required string input ) {

		return input
			.trim()
			.lcase()
			.reReplace( "['""]+", "", "all" )
			.reReplace( "[[:punct:]]+", " ", "all" )
			.reMatch( "\S+" )
		;

	}

	// ---
	// PRIVAT METHODS.
	// ---

	/**
	* I ensure that the cache contains all the given tokens, fetching data from Datamuse
	* as needed in order to incrementally populate the cache.
	*/
	private void function ensureSyllableCountCache( required array tokens ) {

		tokens
			.filter( ( token ) => ! syllableCache.keyExists( token ) )
			.each(
				( token ) => {

					var maybeWord = wordModel.maybeGet( token );

					if ( maybeWord.exists ) {

						syllableCache[ token ] = maybeWord.value.syllableCount;
						return;

					}

					// We didn't have the token cached in the database, go to Datamuse.
					// --
					// Todo: we should add some sort of try/catch or back-off around this
					// call probably.
					var results = datamuseClient.getSyllableCount( token );

					for ( var result in results ) {

						syllableCache[ result.word ] = result.syllableCount;

						if (
							result.partsPerMillion &&
							result.syllableCount &&
							( token.len() <= 20 )
							) {

							wordModel.create(
								token = token,
								syllableCount = result.syllableCount,
								partsPerMillion = result.partsPerMillion,
								isAdjective = result.isAdjective,
								isAdverb = result.isAdverb,
								isNoun = result.isNoun,
								isVerb = result.isVerb
							);

						}

					}

				},
				true, // Parallel iteration.
				20    // Max parallel threads.
			)
		;

	}


	/**
	* I group the results by syllable count.
	*/
	private array function groupBySyllableCount( required array results ) {

		var groups = [
			{ label: "1 Syllable", results: [] },
			{ label: "2 Syllables", results: [] },
			{ label: "3 Syllables", results: [] },
			{ label: "4 Syllables", results: [] },
			{ label: "5 Syllables", results: [] },
			{ label: "6 Syllables", results: [] },
			{ label: "7 Syllables", results: [] },
			{ label: "8 Syllables", results: [] },
			{ label: "9 Syllables", results: [] },
			{ label: "10 Syllables", results: [] }
		];

		// Note: the results are returned by Datamuse in score-order (higher to lower).
		// We're going to leave it in this same order.

		for ( var result in results ) {

			// We're only accounting for a subset of fixed-length syllables.
			if ( ! groups.isDefined( result.syllableCount ) ) {

				continue;

			}

			groups[ result.syllableCount ].results.append( result );

		}

		// Only return groups with results.
		return groups.filter( ( group ) => group.results.len() );

	}


	/**
	* I group the results by type of speech.
	*/
	private array function groupByTypeOfSpeech( required array results ) {

		var groups = [
			{ label: "Adjective", results: [] },
			{ label: "Noun", results: [] },
			{ label: "Verb", results: [] },
			{ label: "Adverb", results: [] }
		];
		var groupsIndex = arrayIndexBy( groups, "label" );

		for ( var result in results ) {

			groupsIndex[ result.typeOfSpeech ].results.append( result );

		}

		// Only return groups with results.
		return groups.filter( ( group ) => group.results.len() );

	}

}
