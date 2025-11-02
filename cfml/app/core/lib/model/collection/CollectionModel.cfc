component {

	// Define properties for dependency-injection.
	property name="gateway" ioc:type="core.lib.model.collection.CollectionGateway";
	property name="validation" ioc:type="core.lib.model.collection.CollectionValidation";

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
		required string descriptionMarkdown,
		required string descriptionHtml,
		required date createdAt
		) {

		name = validation.nameFrom( name );
		descriptionMarkdown = validation.descriptionMarkdownFrom( descriptionMarkdown );
		descriptionHtml = validation.descriptionHtmlFrom( descriptionHtml );

		return gateway.create(
			userID = userID,
			name = name,
			descriptionMarkdown = descriptionMarkdown,
			descriptionHtml = descriptionHtml,
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

		return maybeArrayFirst( getByFilter( argumentCollection = arguments ) );

	}


	/**
	* I update a model.
	*/
	public void function update(
		required numeric id,
		string name,
		string descriptionMarkdown,
		string descriptionHtml,
		date updatedAt
		) {

		var existing = get( id );

		name = isNull( name )
			? existing.name
			: validation.nameFrom( name )
		;
		descriptionMarkdown = isNull( descriptionMarkdown )
			? existing.descriptionMarkdown
			: validation.descriptionMarkdownFrom( descriptionMarkdown )
		;
		descriptionHtml = isNull( descriptionHtml )
			? existing.descriptionHtml
			: validation.descriptionHtmlFrom( descriptionHtml )
		;
		updatedAt = isNull( updatedAt )
			? existing.updatedAt
			: updatedAt
		;

		gateway.update(
			id = existing.id,
			name = name,
			descriptionMarkdown = descriptionMarkdown,
			descriptionHtml = descriptionHtml,
			updatedAt = updatedAt
		);

	}

}
