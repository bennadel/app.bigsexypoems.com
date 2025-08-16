component
	extends = "core.lib.model.BaseValidation"
	{

	/**
	* I validate and return the normalized value.
	*/
	public string function testIpAddress( required string input ) {

		return pipeline(
			trim( input ).lcase(),
			[
				assertNotEmpty: [ "App.Model.Session.IpAddress.Empty" ],
				assertMaxLength: [ 45, "App.Model.Session.IpAddress.TooLong" ],
				assertIpAddress: [ "App.Model.Session.IpAddress.Invalid" ]
			]
		);

	}


	/**
	* I throw a not-found error.
	*/
	public void function throwNotFoundError() {

		throw( type = "App.Model.Session.NotFound" );

	}

}
