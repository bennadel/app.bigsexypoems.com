component {

	// Define properties for dependency-injection.
	property name="gateway" ioc:type="core.lib.model.poem.share.ShareGateway";
	property name="validation" ioc:type="core.lib.model.poem.share.ShareValidation";

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
		required string token,
		required string name,
		required string noteMarkdown,
		required string noteHtml,
		required date createdAt,
		required date updatedAt
		) {

		name = validation.testName( name );
		noteMarkdown = validation.testNoteMarkdown( noteMarkdown );
		noteHtml = validation.testNoteHtml( noteHtml );

		return gateway.create(
			poemID = poemID,
			token = token,
			name = name,
			noteMarkdown = noteMarkdown,
			noteHtml = noteHtml,
			createdAt = createdAt,
			updatedAt = updatedAt
		);

	}


	/**
	* I delete the model that match the given filters.
	*/
	public void function deleteByFilter(
		numeric id,
		numeric poemID
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
		string token
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
		numeric poemID,
		string token
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
		string noteMarkdown,
		string noteHtml,
		date updatedAt
		) {

		var existing = get( id );

		name = isNull( name )
			? existing.name
			: validation.testName( name )
		;
		noteMarkdown = isNull( noteMarkdown )
			? existing.noteMarkdown
			: validation.testNoteMarkdown( noteMarkdown )
		;
		noteHtml = isNull( noteHtml )
			? existing.noteHtml
			: noteHtml
		;
		updatedAt = isNull( updatedAt )
			? existing.updatedAt
			: updatedAt
		;

		gateway.update(
			id = existing.id,
			name = name,
			noteMarkdown = noteMarkdown,
			noteHtml = noteHtml,
			updatedAt = updatedAt
		);

	}

}
