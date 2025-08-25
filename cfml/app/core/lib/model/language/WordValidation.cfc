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
	public string function testToken( required string input ) {

		return pipeline(
			normalizeString( input ).lcase(),
			[
				assertMaxLength: [ 20, "App.Model.Language.Word.Token.TooLong" ]
			]
		);

	}


	/**
	* I throw a not-found error.
	*/
	public void function throwNotFoundError() {

		throw( type = "App.Model.Language.Word.NotFound" );

	}

}
