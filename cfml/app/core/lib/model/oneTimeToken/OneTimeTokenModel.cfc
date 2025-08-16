component {

	// Define properties for dependency-injection.
	property name="gateway" ioc:type="core.lib.model.oneTimeToken.OneTimeTokenGateway";
	property name="validation" ioc:type="core.lib.model.oneTimeToken.OneTimeTokenValidation";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create a new model.
	*/
	public numeric function create(
		required string slug,
		required string passcode,
		required string value,
		required date expiresAt
		) {

		var id = gateway.create(
			slug = slug,
			passcode = passcode,
			value = value,
			expiresAt = expiresAt
		);

		return id;

	}


	/**
	* I delete the model that match the given filters.
	*/
	public void function deleteByFilter( numeric id ) {

		gateway.deleteByFilter( argumentCollection = arguments );

	}


	/**
	* I get the model that match the given filters.
	*/
	public array function getByFilter(
		numeric id,
		date expiresAtBefore
		) {

		return gateway.getByFilter( argumentCollection = arguments );

	}


	/**
	* I maybe get a model.
	*/
	public struct function maybeGet( required numeric id ) {

		var results = gateway.getByFilter( argumentCollection = arguments );

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
