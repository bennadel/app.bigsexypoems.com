component {

	// Define properties for dependency-injection.
	property name="gateway" ioc:type="core.lib.model.user.TimezoneGateway";
	property name="validation" ioc:type="core.lib.model.user.TimezoneValidation";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create a new model.
	*/
	public void function create(
		required numeric userID,
		required numeric offsetInMinutes
		) {

		var existing = getByFilter( userID = userID );

		if ( existing.len() ) {

			validation.throwAlreadyExistsError();

		}

		offsetInMinutes = validation.offsetInMinutesFrom( offsetInMinutes );

		gateway.create(
			userID = userID,
			offsetInMinutes = offsetInMinutes
		);

	}


	/**
	* I get a model.
	*/
	public struct function get( required numeric userID ) {

		var results = getByFilter( argumentCollection = arguments );

		if ( ! results.len() ) {

			validation.throwNotFoundError();

		}

		return results.first();

	}


	/**
	* I get the model that match the given filters.
	*/
	public array function getByFilter( numeric userID ) {

		return gateway.getByFilter( argumentCollection = arguments );

	}


	/**
	* I maybe get a model.
	*/
	public struct function maybeGet( required numeric userID ) {

		return maybeGetByFilter( argumentCollection = arguments );

	}


	/**
	* I maybe get the first model that match the given filters.
	*/
	public struct function maybeGetByFilter(
		numeric userID
		) {

		return maybeArrayFirst( getByFilter( argumentCollection = arguments ) );

	}


	/**
	* I update a model.
	*/
	public void function update(
		required numeric userID,
		numeric offsetInMinutes
		) {

		var existing = get( userID );

		offsetInMinutes = isNull( offsetInMinutes )
			? existing.offsetInMinutes
			: validation.offsetInMinutesFrom( offsetInMinutes )
		;

		gateway.update(
			userID = existing.userID,
			offsetInMinutes = offsetInMinutes
		);

	}

}
