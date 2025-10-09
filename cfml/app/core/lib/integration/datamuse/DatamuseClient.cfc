/**
* Datamuse API: https://www.datamuse.com/api/
* 
* Use of this API requires us to give credit on the website.
*/
component hint = "I provide high-level HTTP access to the Datamuse API." {

	// Define properties for dependency-injection.
	property name="gateway" ioc:type="core.lib.integration.datamuse.DatamuseGateway";
	property name="timeoutInSeconds" ioc:skip;

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the service.
	*/
	public void function init( numeric timeoutInSeconds = 5 ) {

		variables.timeoutInSeconds = arguments.timeoutInSeconds;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I get words that generally mean the same thing as the given word.
	*/
	public array function getMeansLike(
		required string word,
		required numeric limit
		) {

		return makeRequestAndNormalizeResults(
			resource = "words",
			searchParams = {
				ml: wordFrom( word ),
				md: "fps", // Frequency, parts of speech, syllable count.
				max: limit
			}
		);

	}


	/**
	* I get words that rhyme with the given word.
	*/
	public array function getRhyme(
		required string word,
		required numeric limit
		) {

		return makeRequestAndNormalizeResults(
			resource = "words",
			searchParams = {
				rel_rhy: wordFrom( word ),
				md: "fps", // Frequency, parts of speech, syllable count.
				max: limit
			}
		);

	}


	/**
	* I get syllable count for the given word.
	*/
	public array function getSyllableCount( required string word ) {

		var results = makeRequestAndNormalizeResults(
			resource = "words",
			searchParams = {
				"sp": wordFrom( word ),
				"qe": "sp",
				"md": "fps", // Frequency, parts of speech, syllable count.
				"max": 1
			}
		);

		// If the given word is misspelled or unknown, the "sp" (spelled like) resource
		// may end up returning a different word. But, we only want top return the results
		// if the Datamuse could make sense of it.
		return results.filter( ( result ) => result.word == word );

	}


	/**
	* I get words that are strictly defined as synonyms of the given word. This is a more
	* strict query that the getMeansLike().
	*/
	public array function getSynonym(
		required string word,
		required numeric limit
		) {

		return makeRequestAndNormalizeResults(
			resource = "words",
			searchParams = {
				rel_syn: wordFrom( word ),
				md: "fps", // Frequency, parts of speech, syllable count.
				max: limit
			}
		);

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I make the request to the given resource and then filter and normalize the results
	* into a common format.
	*/
	private array function makeRequestAndNormalizeResults(
		required string resource,
		required struct searchParams
		) {

		// Caution: we're not using .filter() here because there's a bug in ColdFusion
		// that causes nested filters, starting with a root async-filter, to destroy
		// access to closed-over variables. See my reproduction here:
		// --
		// https://www.bennadel.com/blog/4831-adobe-coldfusion-bug-nested-array-iteration-breaks-closure-variables.htm

		// return gateway
		// 	.makeRequest( resource, searchParams )
		// 	.filter( ( result ) => normalizeResult( result ) )
		// ;

		var results = gateway.makeRequest(
			resource = resource,
			searchParams = searchParams,
			timeoutInSeconds = timeoutInSeconds
		);
		var filteredResults = [];

		for ( var result in results ) {

			if ( normalizeResult( result ) ) {

				filteredResults.append( result );

			}

		}

		return filteredResults;

	}


	/**
	* I normalize the given result, making easier-to-consume data.
	*/
	private boolean function normalizeResult( required struct result ) {

		// Sometimes the data coming back from Datamuse is incomplete. Or, at least,
		// that's what my old experimental code says - I'm not sure if this is still true.
		if ( isNull( result.tags ) || isNull( result.score ) ) {

			return false;

		}

		result.syllableCount = ( result.numSyllables ?: 0 );

		// Note: starts off in the unknown state for type of speech.
		result.typeOfSpeech = "Unknown";
		result.isUnknown = true;
		result.isAdjective = false;
		result.isAdverb = false;
		result.isNoun = false;
		result.isVerb = false;

		result.isProperNoun = false;
		result.isAntonym = false;
		result.isSynonym = false;

		for ( var tag in result.tags ) {

			switch ( tag ) {
				case "adj":
					result.typeOfSpeech = "Adjective";
					result.isAdjective = true;
					result.isUnknown = false;
				break;
				case "adv":
					result.typeOfSpeech = "Adverb";
					result.isAdverb = true;
					result.isUnknown = false;
				break;
				case "ant":
					result.isAntonym = true;
				break;
				case "n":
					result.typeOfSpeech = "Noun";
					result.isNoun = true;
					result.isUnknown = false;
				break;
				case "prop":
					result.isProperNoun = true;
				break;
				case "syn":
					result.isSynonym = true;
				break;
				case "u":
					result.typeOfSpeech = "Unknown";
					result.isUnknown = true;
				break;
				case "v":
					result.typeOfSpeech = "Verb";
					result.isVerb = true;
					result.isUnknown = false;
				break;
				// Some of the injected tags are prefixed-based and need to be parsed.
				default:

					var prefix = tag.listFirst( ":" );

					switch ( prefix ) {
						case "f":
							result.partsPerMillion = val( tag.listRest( ":" ) )
						break;
					}

				break;
			}

		}

		return true;

	}


	/**
	* I test and normalize the given word before sending it to Datamuse. Not sure if this
	* makes any difference, but I like having a predictable API.
	*/
	private string function wordFrom( required string word ) {

		word = word.trim().lcase();

		if ( ! word.len() ) {

			throw( type = "DatamuseClient.Word.Empty" );

		}

		return word;

	}

}
