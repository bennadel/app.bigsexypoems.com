component {

	// Define properties for dependency-injection.
	property name="gateway" ioc:type="core.lib.model.session.PresenceGateway";
	property name="validation" ioc:type="core.lib.model.session.PresenceValidation";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create a new model.
	*/
	public void function create(
		required numeric sessionID,
		numeric requestCount = 1,
		date lastRequestAt = utcNow()
		) {

		var existing = getByFilter( sessionID = sessionID );

		if ( existing.len() ) {

			validation.throwAlreadyExistsError();

		}

		gateway.create(
			sessionID = sessionID,
			requestCount = requestCount,
			lastRequestAt = lastRequestAt
		);

	}


	/**
	* I delete the model that match the given filters.
	*/
	public void function deleteByFilter( numeric sessionID ) {

		gateway.deleteByFilter( argumentCollection = arguments );

	}


	/**
	* I get a model.
	*/
	public struct function get( required numeric sessionID ) {

		var results = getByFilter( argumentCollection = arguments );

		if ( ! results.len() ) {

			validation.throwNotFoundError();

		}

		return results.first();

	}


	/**
	* I get the model that match the given filters.
	*/
	public array function getByFilter( numeric sessionID ) {

		return gateway.getByFilter( argumentCollection = arguments );

	}


	/**
	* I increment the request count and date for the given model.
	*/
	public void function logRequest( required numeric sessionID ) {

		gateway.logRequest( sessionID );

	}

}
