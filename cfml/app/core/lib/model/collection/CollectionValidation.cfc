component
	extends = "core.lib.model.BaseValidation"
	{

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// VALIDATION METHODS.
	// ---

	/**
	* I validate and return the normalized value.
	*/
	public string function descriptionHtmlFrom( required string input ) {

		return pipeline(
			normalizeString( input ),
			[:]
		);

	}


	/**
	* I validate and return the normalized value.
	*/
	public string function descriptionMarkdownFrom( required string input ) {

		return pipeline(
			normalizeString( input ),
			[
				assertMaxLength: [ 500, "App.Model.Collection.DescriptionMarkdown.TooLong" ],
				assertUniformEncoding: [ "App.Model.Collection.DescriptionMarkdown.SuspiciousEncoding" ]
			]
		);

	}


	/**
	* I validate and return the normalized value.
	*/
	public string function nameFrom( required string input ) {

		return pipeline(
			normalizeString( input ),
			[
				assertNotEmpty: [ "App.Model.Collection.Name.Empty" ],
				assertMaxLength: [ 50, "App.Model.Collection.Name.TooLong" ],
				assertUniformEncoding: [ "App.Model.Collection.Name.SuspiciousEncoding" ]
			]
		);

	}

	// ---
	// ERROR METHODS.
	// ---

	/**
	* I throw a model error.
	*/
	public void function throwForbiddenError() {

		throw( type = "App.Model.Collection.Forbidden" );

	}


	/**
	* I throw a model error.
	*/
	public void function throwNotFoundError() {

		throw( type = "App.Model.Collection.NotFound" );

	}


	/**
	* I throw a model error.
	*/
	public void function throwUnsafeDescriptionError( required struct unsafeMarkup ) {

		var tagNames = unsafeMarkup
			.tags
			.map( ( entry ) => entry.tagName )
			.toList( ", " )
		;

		throw(
			type = "App.Model.Collection.DescriptionMarkdown.Unsafe",
			extendedInfo = embedMetadata({
				tagNames: tagNames
			})
		);

	}

}
