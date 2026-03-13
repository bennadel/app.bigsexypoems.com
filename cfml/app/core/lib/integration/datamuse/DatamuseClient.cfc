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
	* I get definitions for the given word.
	*/
	public array function getDefinition( required string word ) {

		var results = gateway.makeRequestWithRetry(
			resource = "words",
			searchParams = {
				sp: wordFrom( word ),
				qe: "sp",
				md: "d", // Definition.
				max: 1 // Otherwise alternate words will be included.
			},
			timeoutInSeconds = timeoutInSeconds
		);

		if ( ! results.len() ) {

			return [];

		}

		var result = results.first();

		// Note: if the word is misspelled, it will be returned without definitions; and
		// possibly with tags that are prefixed with "spellcor:". This would allow me to
		// return suggestions for fixing the word. But for now, I'm just going to treat
		// misspellings as a non-results. Dealing with misspellings can be a future-facing
		// improvement.
		if ( isNull( result.defs ) ) {

			return [];

		}

		var TAB = chr( 9 );
		var definitionResults = [];

		// Convert each simple definition string into a robust result.
		for ( var def in result.defs ) {

			var definitionResult = {
				score: result.score,
				word: result.word,
				definition: def,

				// Note: starts off in the unknown state for type of speech.
				typeOfSpeech: "Unknown",
				isUnknown: true,
				isAdjective: false,
				isAdverb: false,
				isNoun: false,
				isVerb: false,
				isProperNoun: false,
				isAntonym: false,
				isSynonym: false,
			};

			// The type of speech (v, adj, n) is embedded in the definition itself, as a
			// tab-delimited prefix. I'm not sure if this is wholly consistent, so I'm
			// checking for it after the fact.
			if ( def.find( TAB ) ) {

				definitionResult.definition = def.listRest( TAB );

				switch ( def.listFirst( TAB ) ) {
					case "adj":
						definitionResult.typeOfSpeech = "Adjective";
						definitionResult.isAdjective = true;
						definitionResult.isUnknown = false;
					break;
					case "adv":
						definitionResult.typeOfSpeech = "Adverb";
						definitionResult.isAdverb = true;
						definitionResult.isUnknown = false;
					break;
					case "ant":
						definitionResult.isAntonym = true;
					break;
					case "n":
						definitionResult.typeOfSpeech = "Noun";
						definitionResult.isNoun = true;
						definitionResult.isUnknown = false;
					break;
					case "prop":
						definitionResult.isProperNoun = true;
					break;
					case "syn":
						definitionResult.isSynonym = true;
					break;
					case "u":
						// Note: this is the default state; but I'm keeping it here so
						// that we never fall-through to the default case.
						// --
						// definitionResult.typeOfSpeech = "Unknown";
						// definitionResult.isUnknown = true;
					break;
					case "v":
						definitionResult.typeOfSpeech = "Verb";
						definitionResult.isVerb = true;
						definitionResult.isUnknown = false;
					break;
				}

			}

			definitionResults.append( definitionResult );

		}

		return definitionResults;

	}


	/**
	* I get words that generally mean the same thing as the given word.
	*/
	public array function getMeansLike(
		required string word,
		required numeric limit
		) {

		return makeWordRequest(
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

		return makeWordRequest(
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

		var wordResults = makeWordRequest(
			resource = "words",
			searchParams = {
				"sp": wordFrom( word ),
				"qe": "sp",
				"md": "fps", // Frequency, parts of speech, syllable count.
				"max": 1
			}
		);

		// If the given word is misspelled or unknown, the "sp" (spelled like) resource
		// may end up returning a different word. But, we only want to return the results
		// if the Datamuse could make sense of it.
		return wordResults.filter( ( wordResult ) => wordResult.word == word );

	}


	/**
	* I get words that are strictly defined as synonyms of the given word. This is a more
	* strict query that the getMeansLike().
	*/
	public array function getSynonym(
		required string word,
		required numeric limit
		) {

		return makeWordRequest(
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
	* I make the word request to the given resource and then filter and normalize the
	* results into a common format.
	*/
	private array function makeWordRequest(
		required string resource,
		required struct searchParams
		) {

		var results = gateway.makeRequestWithRetry(
			resource = resource,
			searchParams = searchParams,
			timeoutInSeconds = timeoutInSeconds
		);

		// Caution: we're not using .filter() here because there's a bug in ColdFusion
		// that causes nested filters, starting with a root async-filter, to destroy
		// access to closed-over variables. The Adobe tracker has this bug marked as
		// "fixed". So it will hopefully be resolved in the next updater (7).
		// --
		// https://www.bennadel.com/blog/4831-adobe-coldfusion-bug-nested-array-iteration-breaks-closure-variables.htm
		var wordResults = [];

		for ( var result in results ) {

			// Sometimes the data coming back from Datamuse is incomplete. Or, at least,
			// that's what my old experimental code says - I'm not sure if this is still
			// true.
			if ( isNull( result.tags ) || isNull( result.score ) ) {

				continue;

			}

			var wordResult = {
				score: result.score,
				word: result.word,
				syllableCount: ( result.numSyllables ?: 0 ),
				partsPerMillion: 0,

				// Note: starts off in the unknown state for type of speech.
				typeOfSpeech: "Unknown",
				isUnknown: true,
				isAdjective: false,
				isAdverb: false,
				isNoun: false,
				isVerb: false,
				isProperNoun: false,
				isAntonym: false,
				isSynonym: false,
			};

			for ( var tag in result.tags ) {

				switch ( tag ) {
					case "adj":
						wordResult.typeOfSpeech = "Adjective";
						wordResult.isAdjective = true;
						wordResult.isUnknown = false;
					break;
					case "adv":
						wordResult.typeOfSpeech = "Adverb";
						wordResult.isAdverb = true;
						wordResult.isUnknown = false;
					break;
					case "ant":
						wordResult.isAntonym = true;
					break;
					case "n":
						wordResult.typeOfSpeech = "Noun";
						wordResult.isNoun = true;
						wordResult.isUnknown = false;
					break;
					case "prop":
						wordResult.isProperNoun = true;
					break;
					case "syn":
						wordResult.isSynonym = true;
					break;
					case "u":
						// Note: this is the default state; but I'm keeping it here so
						// that we never fall-through to the default case.
						// --
						// wordResult.typeOfSpeech = "Unknown";
						// wordResult.isUnknown = true;
					break;
					case "v":
						wordResult.typeOfSpeech = "Verb";
						wordResult.isVerb = true;
						wordResult.isUnknown = false;
					break;
					// Some of the injected tags are prefixed-based and need to be parsed.
					default:

						var prefix = tag.listFirst( ":" );

						switch ( prefix ) {
							case "f":
								wordResult.partsPerMillion = val( tag.listRest( ":" ) )
							break;
						}

					break;
				}

			}

			wordResults.append( wordResult );

		}

		return wordResults;

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
