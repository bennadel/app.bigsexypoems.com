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
	public string function tokenFrom( required string input ) {

		return pipeline(
			normalizeString( input ).lcase(),
			[
				assertMaxLength: [ 20, "App.Model.Language.Word.Token.TooLong" ]
			]
		);

	}

	// ---
	// ERROR METHODS.
	// ---

	/**
	* I throw a not-found error.
	*/
	public void function throwNotFoundError() {

		throw( type = "App.Model.Language.Word.NotFound" );

	}

}
