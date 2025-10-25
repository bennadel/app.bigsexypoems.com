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
		required numeric tagID,
		required string name,
		required string content,
		required date createdAt
		) {

		name = validation.nameFrom( name );
		content = validation.contentFrom( content );

		return gateway.create(
			userID = userID,
			tagID = tagID,
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
	*/
	public array function getByFilter(
		numeric id,
		numeric userID,
		numeric tagID
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
		numeric tagID
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
		numeric tagID,
		string name,
		string content,
		date updatedAt
		) {

		var existing = get( id );

		tagID = isNull( tagID )
			? existing.tagID
			: tagID
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
			tagID = tagID,
			name = name,
			content = content,
			updatedAt = updatedAt
		);

	}

}
