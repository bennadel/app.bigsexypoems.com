component {

	// Define properties for dependency-injection.
	property name="gateway" ioc:type="core.lib.model.language.WordGateway";
	property name="validation" ioc:type="core.lib.model.language.WordValidation";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create a new model.
	*/
	public void function create(
		required string token,
		required numeric syllableCount,
		required numeric partsPerMillion,
		required boolean isAdjective,
		required boolean isAdverb,
		required boolean isNoun,
		required boolean isVerb
		) {

		token = validation.tokenFrom( token );

		gateway.create(
			token = token,
			syllableCount = syllableCount,
			partsPerMillion = partsPerMillion,
			isAdjective = isAdjective,
			isAdverb = isAdverb,
			isNoun = isNoun,
			isVerb = isVerb
		);

	}


	/**
	* I delete the model that match the given filters.
	*/
	public void function deleteByFilter( string token ) {

		gateway.deleteByFilter( argumentCollection = arguments );

	}


	/**
	* I get a model.
	*/
	public struct function get( required string token ) {

		var results = getByFilter( argumentCollection = arguments );

		if ( ! results.len() ) {

			validation.throwNotFoundError();

		}

		return results.first();

	}


	/**
	* I get the model that match the given filters.
	*/
	public array function getByFilter(
		string token,
		string withSort
		) {

		return gateway.getByFilter( argumentCollection = arguments );

	}


	/**
	* I maybe get a model.
	*/
	public struct function maybeGet( required string token ) {

		return maybeGetByFilter( argumentCollection = arguments );

	}


	/**
	* I maybe get the first model that match the given filters.
	*/
	public struct function maybeGetByFilter( string token ) {

		return maybeArrayFirst( getByFilter( argumentCollection = arguments ) );

	}

}
