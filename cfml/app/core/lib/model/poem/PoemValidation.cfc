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
	public string function testContent( required string input ) {

		return pipeline(
			normalizeString( input ),
			[
				assertMaxLength: [ 3000, "App.Model.Poem.Content.TooLong" ],
				assertUniformEncoding: [ "App.Model.Poem.Content.SuspiciousEncoding" ]
			]
		);

	}


	/**
	* I validate and return the normalized value.
	*/
	public string function testName( required string input ) {

		return pipeline(
			normalizeString( input ),
			[
				assertNotEmpty: [ "App.Model.Poem.Name.Empty" ],
				assertMaxLength: [ 255, "App.Model.Poem.Name.TooLong" ],
				assertUniformEncoding: [ "App.Model.Poem.Name.SuspiciousEncoding" ]
			]
		);

	}


	/**
	* I throw a not-found error.
	*/
	public void function throwNotFoundError() {

		throw( type = "App.Model.Poem.NotFound" );

	}

}
