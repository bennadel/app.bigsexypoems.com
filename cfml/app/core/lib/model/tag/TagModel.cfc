component {

	// Define properties for dependency-injection.
	property name="gateway" ioc:type="core.lib.model.tag.TagGateway";
	property name="validation" ioc:type="core.lib.model.tag.TagValidation";

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
		required string name,
		required string slug,
		required string fillHex,
		required string textHex,
		required date createdAt
		) {

		name = validation.nameFrom( name );
		slug = validation.slugFrom( slug );
		fillHex = validation.fillHexFrom( fillHex );
		textHex = validation.textHexFrom( textHex );

		return gateway.create(
			userID = userID,
			name = name,
			slug = slug,
			fillHex = fillHex,
			textHex = textHex,
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
		string name,
		string slug,
		string fillHex,
		string textHex,
		date updatedAt
		) {

		var existing = get( id );

		name = isNull( name )
			? existing.name
			: validation.nameFrom( name )
		;
		slug = isNull( slug )
			? existing.slug
			: validation.slugFrom( slug )
		;
		fillHex = isNull( fillHex )
			? existing.fillHex
			: validation.fillHexFrom( fillHex )
		;
		textHex = isNull( textHex )
			? existing.textHex
			: validation.textHexFrom( textHex )
		;
		updatedAt = isNull( updatedAt )
			? existing.updatedAt
			: updatedAt
		;

		gateway.update(
			id = existing.id,
			name = name,
			slug = slug,
			fillHex = fillHex,
			textHex = textHex,
			updatedAt = updatedAt
		);

	}

}
