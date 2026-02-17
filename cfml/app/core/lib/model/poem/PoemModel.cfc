component {

	// Define properties for dependency-injection.
	property name="gateway" ioc:type="core.lib.model.poem.PoemGateway";
	property name="validation" ioc:type="core.lib.model.poem.PoemValidation";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create a new model.
	*/
	public numeric function create(
		required numeric userID,
		required numeric collectionID,
		required string name,
		required string content,
		required date createdAt
		) {

		name = validation.nameFrom( name );
		content = validation.contentFrom( content );

		return gateway.create(
			userID = userID,
			collectionID = collectionID,
			name = name,
			content = content,
			createdAt = createdAt,
			updatedAt = createdAt
		);

	}


	/**
	* I delete the model that match the given filters.
	*/
	public void function deleteByFilter(
		numeric id,
		numeric userID,
		numeric collectionID
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
		numeric userID,
		numeric collectionID,
		string withSort
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
		numeric userID,
		numeric collectionID
		) {

		return maybeArrayFirst( getByFilter( argumentCollection = arguments ) );

	}


	/**
	* I update a model.
	*/
	public void function update(
		required numeric id,
		numeric collectionID,
		string name,
		string content,
		date updatedAt
		) {

		var existing = get( id );

		collectionID = isNull( collectionID )
			? existing.collectionID
			: collectionID
		;
		name = isNull( name )
			? existing.name
			: validation.nameFrom( name )
		;
		content = isNull( content )
			? existing.content
			: validation.contentFrom( content )
		;
		updatedAt = isNull( updatedAt )
			? existing.updatedAt
			: updatedAt
		;

		gateway.update(
			id = existing.id,
			collectionID = collectionID,
			name = name,
			content = content,
			updatedAt = updatedAt
		);

	}

}
