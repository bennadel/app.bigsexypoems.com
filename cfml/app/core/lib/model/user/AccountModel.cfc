component {

	// Define properties for dependency-injection.
	property name="clock" ioc:type="core.lib.util.Clock";
	property name="gateway" ioc:type="core.lib.model.user.AccountGateway";
	property name="validation" ioc:type="core.lib.model.user.AccountValidation";

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
		date createdAt = clock.utcNow()
		) {

		var existing = gateway.getByFilter( userID = userID );

		if ( existing.len() ) {

			validation.throwAlreadyExistsError();

		}

		gateway.create(
			userID = userID,
			createdAt = createdAt
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
	public struct function maybeGetByFilter( numeric userID ) {

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

}
