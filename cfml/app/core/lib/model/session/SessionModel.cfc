component {

	// Define properties for dependency-injection.
	property name="clock" ioc:type="core.lib.util.Clock";
	property name="gateway" ioc:type="core.lib.model.session.SessionGateway";
	property name="validation" ioc:type="core.lib.model.session.SessionValidation";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create a new model.
	*/
	public numeric function create(
		required string token,
		required numeric userID,
		required boolean isAuthenticated,
		required string ipAddress,
		date createdAt = clock.utcNow()
		) {

		ipAddress = validation.testIpAddress( ipAddress );

		var id = gateway.create(
			token = token,
			userID = userID,
			isAuthenticated = isAuthenticated,
			ipAddress = ipAddress,
			createdAt = createdAt
		);

		return id;

	}


	/**
	* I delete the model that match the given filters. 
	*/
	public void function deleteByFilter(
		numeric id,
		numeric userID
		) {

		gateway.deleteByFilter( argumentCollection = arguments );

	}


	/**
	* I get a model.
	*/
	public struct function get( required numeric id ) {

		var results = getByFilter( argumentCollection = arguments );

		if ( ! results.len() ) {

			validation.throwNotFoundError();

		}

		return results.first();

	}


	/**
	* I get the model that match the given filters.
	* 
	* Caution: token comparisons are performed CASE SENSITIVE in the data-access layer.
	*/
	public array function getByFilter(
		numeric id,
		string token,
		numeric userID
		) {

		return gateway.getByFilter( argumentCollection = arguments );

	}


	/**
	* I maybe get a model.
	*/
	public struct function maybeGet( required numeric id ) {

		return maybeGetByFilter( argumentCollection = arguments );

	}


	/**
	* I maybe get the first model that match the given filters.
	*/
	public struct function maybeGetByFilter(
		numeric id,
		string token,
		numeric userID
		) {

		var results = getByFilter( argumentCollection = arguments );

		if ( results.len() ) {

			return {
				exists: true,
				value: results.first()
			};

		}

		return {
			exists: false
		};

	}


	/**
	* I update a model.
	*/
	public void function update(
		required numeric id,
		boolean isAuthenticated
		) {

		var existing = get( id );

		isAuthenticated = isNull( isAuthenticated )
			? existing.isAuthenticated
			: isAuthenticated
		;

		gateway.update(
			id = existing.id,
			isAuthenticated = isAuthenticated
		);

	}

}
