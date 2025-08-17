component
	output = false
	hint = "I provide methods for getting words related to other words."
	{

	// Define properties for dependency-injection.
	property name="datamuseClient" ioc:type="core.lib.integration.datamuse.DatamuseClient";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

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

	// ---
	// PRIVAT METHODS.
	// ---

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
