component
	extends = "core.lib.model.BaseValidation"
	{

	/**
	* I validate and return the normalized value.
	*/
	public string function testEmail( required string input ) {

		return pipeline(
			normalizeString( input ).lcase(),
			[
				assertNotEmpty: [ "App.Model.User.Email.Empty" ],
				assertMaxLength: [ 75, "App.Model.User.Email.TooLong" ],
				assertEmail: [ "App.Model.User.Email.Invalid" ],
				assertNotExampleEmail: [ "App.Model.User.Email.Example" ],
				assertUniformEncoding: [ "App.Model.User.Email.SuspiciousEncoding" ]
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
				assertNotEmpty: [ "App.Model.User.Name.Empty" ],
				assertMaxLength: [ 50, "App.Model.User.Name.TooLong" ],
				assertUniformEncoding: [ "App.Model.User.Name.SuspiciousEncoding" ]
			]
		);

	}


	/**
	* I throw an already-exists error.
	*/
	public void function throwAlreadyExistsError() {

		throw( type = "App.Model.User.AlreadyExists" );

	}


	/**
	* I throw a forbidden error.
	*/
	public void function throwForbiddenError() {

		throw( type = "App.Model.User.Forbidden" );

	}


	/**
	* I throw a not-found error.
	*/
	public void function throwNotFoundError() {

		throw( type = "App.Model.User.NotFound" );

	}

}
