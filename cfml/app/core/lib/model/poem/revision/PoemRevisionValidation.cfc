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
	public string function contentFrom( required string input ) {

		return pipeline(
			normalizeString( input ),
			[
				assertMaxLength: [ 3000, "App.Model.Poem.Revision.Content.TooLong" ],
				assertUniformEncoding: [ "App.Model.Poem.Revision.Content.SuspiciousEncoding" ]
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

		throw( type = "App.Model.Poem.Revision.Forbidden" );

	}


	/**
	* I throw a model error.
	*/
	public void function throwNotFoundError() {

		throw( type = "App.Model.Poem.Revision.NotFound" );

	}

}
