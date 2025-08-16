component
	extends = "core.lib.model.BaseValidation"
	{

	/**
	* I validate and return the normalized value.
	*/
	public numeric function testOffsetInMinutes( required numeric input ) {

		return val( input );

	}


	/**
	* I throw an already-exists error.
	*/
	public void function throwAlreadyExistsError() {

		throw( type = "App.Model.User.Timezone.AlreadyExists" );

	}


	/**
	* I throw a not-found error.
	*/
	public void function throwNotFoundError() {

		throw( type = "App.Model.User.Timezone.NotFound" );

	}

}
