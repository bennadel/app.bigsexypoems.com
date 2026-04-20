component {

	// Define properties for dependency-injection.
	property name="gateway" ioc:type="core.lib.model.user.UserGateway";
	property name="validation" ioc:type="core.lib.model.user.UserValidation";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create a new model.
	*/
	public numeric function create(
		required string name,
		required string email,
		required date createdAt
		) {

		name = validation.nameFrom( name );
		email = validation.emailFrom( email );

		var existing = gateway.getByFilter( email = email );

		if ( existing.len() ) {

			validation.throwAlreadyExistsError();

		}

		var id = gateway.create(
			name = name,
			email = email,
			createdAt = createdAt,
			updatedAt = createdAt
		);

		return id;

	}


	/**
	* I delete the model that match the given filters.
	*/
	public void function deleteByFilter(
		numeric id,
		string email
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
	*/
	public array function getByFilter(
		numeric id,
		string email,
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
		string email
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
		string name,
		string email
		) {

		var existing = get( id );

		name = isNull( name )
			? existing.name
			: validation.nameFrom( name )
		;
		email = isNull( email )
			? existing.email
			: validation.emailFrom( email )
		;

		gateway.update(
			id = existing.id,
			name = name,
			email = email
		);

	}

}
