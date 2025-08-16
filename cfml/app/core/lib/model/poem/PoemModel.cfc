component {

	// Define properties for dependency-injection.
	property name="clock" ioc:type="core.lib.util.Clock";
	property name="gateway" ioc:type="core.lib.model.poem.PoemGateway";
	property name="validation" ioc:type="core.lib.model.poem.PoemValidation";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create a new model.
	*/
	public numeric function create(
		required numeric userID,
		required string name,
		required string content
		) {

		name = validation.testName( name );
		content = validation.testContent( content );

		var createdAt = clock.utcNow();

		return gateway.create(
			userID = userID,
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
		string email
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
		string email
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
		required string name,
		required string content
		) {

		var existing = get( id );

		name = isNull( name )
			? existing.name
			: validation.testName( name )
		;
		content = isNull( content )
			? existing.content
			: validation.testContent( content )
		;

		gateway.update(
			id = existing.id,
			name = name,
			content = content,
			updatedAt = clock.utcNow()
		);

	}

}
