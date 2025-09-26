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
	public string function ipAddressFrom( required string input ) {

		return pipeline(
			normalizeString( input ).lcase(),
			[
				assertNotEmpty: [ "App.Model.Poem.Share.Viewing.IpAddress.Empty" ],
				assertMaxLength: [ 45, "App.Model.Poem.Share.Viewing.IpAddress.TooLong" ],
				assertIpAddress: [ "App.Model.Poem.Share.Viewing.IpAddress.Invalid" ]
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

		throw( type = "App.Model.Poem.Share.Viewing.NotFound" );

	}

}
