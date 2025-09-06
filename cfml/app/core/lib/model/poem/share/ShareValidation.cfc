component
	extends = "core.lib.model.BaseValidation"
	{

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I validate and return the normalized value.
	*/
	public string function testName( required string input ) {

		return pipeline(
			normalizeString( input ),
			[
				assertMaxLength: [ 50, "App.Model.Poem.Share.Name.TooLong" ],
				assertUniformEncoding: [ "App.Model.Poem.Share.Name.SuspiciousEncoding" ]
			]
		);

	}


	/**
	* I validate and return the normalized value.
	*/
	public string function testNoteHtml( required string input ) {

		return pipeline(
			normalizeString( input ),
			[:]
		);

	}


	/**
	* I validate and return the normalized value.
	*/
	public string function testNoteMarkdown( required string input ) {

		return pipeline(
			normalizeString( input ),
			[
				assertMaxLength: [ 500, "App.Model.Poem.Share.NoteMarkdown.TooLong" ],
				assertUniformEncoding: [ "App.Model.Poem.Share.NoteMarkdown.SuspiciousEncoding" ]
			]
		);

	}


	/**
	* I throw a not-found error.
	*/
	public void function throwNotFoundError() {

		throw( type = "App.Model.Poem.Share.NotFound" );

	}


	/**
	* I throw an unsafe note error.
	*/
	public void function throwUnsafeNoteError( required struct unsafeMarkup ) {

		var tagNames = unsafeMarkup
			.tags
			.map( ( entry ) => entry.tagName )
			.toList( ", " )
		;

		throw(
			type = "App.Model.Poem.Share.NoteMarkdown.Unsafe",
			extendedInfo = embedMetadata({
				tagNames: tagNames
			})
		);

	}

}
