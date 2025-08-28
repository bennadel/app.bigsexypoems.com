component hint = "I provide methods for getting words related to other words." {

	// Define properties for dependency-injection.
	property name="datamuseClient" ioc:type="core.lib.integration.datamuse.DatamuseClient";
	property name="logger" ioc:type="core.lib.util.Logger";
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

		cacheSyllableCountResultsAsync( results );

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

		cacheSyllableCountResultsAsync( results );

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

		cacheSyllableCountResultsAsync( results );

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
	* I cache the syllable counts for the given results in an asynchronous thread.
	*/
	private void function cacheSyllableCountResultsAsync( required array results ) {

		thread
			name = "WordService.cacheSyllableCountResultsAsync"
			results = results
			{

			try {

				cacheSyllableCountResultsSync( results );

			} catch ( any error ) {

				logger.logException( error );

			}

		}

	}


	/**
	* I cache the syllable counts for the given results.
	*/
	private void function cacheSyllableCountResultsSync( required array results ) {

		for ( var result in results ) {

			var tokens = tokenize( result.word );

			// We only want to cache words that result in a single token. This is how the
			// line-based parser works, so this will only be relevant for caching results
			// coming from other methods (ex, rhymes and synonyms).
			if ( tokens.len() != 1 ) {

				continue;

			}

			var word = tokens[ 1 ];

			// If we already have it cached in memory, then it means we already have it
			// cached in the database (or we've chosen to skip the database cache).
			if ( syllableCache.keyExists( word ) ) {

				continue;

			}

			// Always cache in memory since memory is cheap and will be reset whenever the
			// application is restarted.
			syllableCache[ word ] = result.syllableCount;

			// If the frequency is zero, it means that the word is either made-up,
			// misspelled, or isn't in any of the dictionaries that Datamuse uses.
			if ( ! result.partsPerMillion ) {

				continue;

			}

			// If the syllable count is zero, it means that the word is probably
			// misspelled or made-up.
			if ( ! result.syllableCount ) {

				continue;

			}

			// If the syllable count is greater than 4, it's going to be an extremely rare
			// word - most people use very simple words.
			if ( result.syllableCount > 4 ) {

				continue;

			}

			// If the part of speech couldn't be determined, it's probably a word that
			// won't be used very often - like a name or something esoteric.
			if ( result.isUnknown ) {

				continue;

			}

			// At this time, the primary-key of the cache table is only 20-characters.
			if ( word.len() > 20 ) {

				continue;

			}

			wordModel.create(
				token = word,
				syllableCount = result.syllableCount,
				partsPerMillion = result.partsPerMillion,
				isAdjective = result.isAdjective,
				isAdverb = result.isAdverb,
				isNoun = result.isNoun,
				isVerb = result.isVerb
			);

		}

	}


	/**
	* I ensure that the cache contains all the given tokens, fetching data from Datamuse
	* as needed in order to incrementally populate the cache.
	*/
	private void function ensureSyllableCountCache( required array tokens ) {

		tokens.each(
			( token ) => {

				if ( syllableCache.keyExists( token ) ) {

					return;

				}

				var maybeWord = wordModel.maybeGet( token );

				if ( maybeWord.exists ) {

					syllableCache[ token ] = maybeWord.value.syllableCount;
					return;

				}

				// We didn't have the token cached in the database, go to Datamuse and
				// cache results locally.
				try {

					cacheSyllableCountResultsSync( datamuseClient.getSyllableCount( token ) );

				} catch ( any error ) {

					logger.logException( error );

				}

			},
			true, // Parallel iteration.
			20    // Max parallel threads.
		);

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
