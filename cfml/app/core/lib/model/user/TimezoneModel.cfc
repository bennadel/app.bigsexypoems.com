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
	* I delete the model that match the given filters.
	*/
	public void function deleteByFilter( numeric userID ) {

		gateway.deleteByFilter( argumentCollection = arguments );

	}


	/**
	* I get a model.
	*/
	public struct function get(
		required numeric userID,
		string withLock
		) {

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
		numeric userID,
		string withLock
		) {

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
	public struct function maybeGetByFilter( numeric userID ) {

		return maybeArrayFirst( getByFilter( argumentCollection = arguments ) );

	}


	/**
	* I update a model.
	*
	* Caution: this method should be called inside a transaction block in which the target
	* row has obtained an exclusive lock. This ensures that the subsequent get() call used
	* to fill-in null values will lead to a consistent read.
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
