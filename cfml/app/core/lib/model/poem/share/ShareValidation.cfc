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
	public boolean function isSnapshotFrom( required boolean input ) {

		return !! input;

	}


	/**
	* I validate and return the normalized value.
	*/
	public string function nameFrom( required string input ) {

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
	public string function noteHtmlFrom( required string input ) {

		return pipeline(
			normalizeString( input ),
			[:]
		);

	}


	/**
	* I validate and return the normalized value.
	*/
	public string function noteMarkdownFrom( required string input ) {

		return pipeline(
			normalizeString( input ),
			[
				assertMaxLength: [ 500, "App.Model.Poem.Share.NoteMarkdown.TooLong" ],
				assertUniformEncoding: [ "App.Model.Poem.Share.NoteMarkdown.SuspiciousEncoding" ]
			]
		);

	}


	/**
	* I validate and return the normalized value.
	*/
	public string function snapshotContentFrom( required string input ) {

		return pipeline(
			normalizeString( input ),
			[
				assertMaxLength: [ 3000, "App.Model.Poem.Share.SnapshotContent.TooLong" ],
				assertUniformEncoding: [ "App.Model.Poem.Share.SnapshotContent.SuspiciousEncoding" ]
			]
		);

	}


	/**
	* I validate and return the normalized value.
	*/
	public string function snapshotNameFrom( required string input ) {

		return pipeline(
			normalizeString( input ),
			[
				assertMaxLength: [ 255, "App.Model.Poem.Share.SnapshotName.TooLong" ],
				assertUniformEncoding: [ "App.Model.Poem.Share.SnapshotName.SuspiciousEncoding" ]
			]
		);

	}

	// ---
	// ERROR METHODS.
	// ---

	/**
	* I throw a forbidden error.
	*/
	public void function throwForbiddenError() {

		throw( type = "App.Model.Poem.Share.Forbidden" );

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
