component {

	// Define properties for dependency-injection.
	property name="gateway" ioc:type="core.lib.model.poem.share.ViewingGateway";
	property name="validation" ioc:type="core.lib.model.poem.share.ViewingValidation";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create a new model.
	*/
	public numeric function create(
		required numeric poemID,
		required numeric shareID,
		required string ipAddress,
		required date createdAt
		) {

		ipAddress = validation.ipAddressFrom( ipAddress );

		return gateway.create(
			poemID = poemID,
			shareID = shareID,
			ipAddress = ipAddress,
			createdAt = createdAt
		);

	}


	/**
	* I delete the model that match the given filters.
	*/
	public void function deleteByFilter(
		numeric id,
		numeric poemID,
		numeric shareID
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
	*/
	public array function getByFilter(
		numeric id,
		numeric poemID,
		numeric shareID,
		string ipAddress
		) {

		return gateway.getByFilter( argumentCollection = arguments );

	}


	/**
	* I get the count that match the given filters.
	*/
	public numeric function getCountByFilter(
		numeric poemID,
		numeric shareID,
		string ipAddress
		) {

		return gateway.getCountByFilter( argumentCollection = arguments );

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
		numeric poemID,
		numeric shareID,
		string ipAddress
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

}
