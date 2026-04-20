component {

	// Define properties for dependency-injection.
	property name="gateway" ioc:type="core.lib.model.session.SessionGateway";
	property name="validation" ioc:type="core.lib.model.session.SessionValidation";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

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
		required string ipCity,
		required string ipRegion,
		required string ipCountry,
		required date createdAt
		) {

		ipAddress = validation.ipAddressFrom( ipAddress );
		ipCity = validation.ipCityFrom( ipCity );
		ipRegion = validation.ipRegionFrom( ipRegion );
		ipCountry = validation.ipCountryFrom( ipCountry );

		var id = gateway.create(
			token = token,
			userID = userID,
			isAuthenticated = isAuthenticated,
			ipAddress = ipAddress,
			ipCity = ipCity,
			ipRegion = ipRegion,
			ipCountry = ipCountry,
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
	public struct function get(
		required numeric id,
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
	* 
	* Caution: token comparisons are performed CASE SENSITIVE in the data-access layer.
	*/
	public array function getByFilter(
		numeric id,
		string token,
		numeric userID,
		string withSort,
		string withLock
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
