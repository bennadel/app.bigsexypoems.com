component
	extends = "core.lib.model.BaseValidation"
	{

	/**
	* I throw an already-exists error.
	*/
	public void function throwAlreadyExistsError() {

		throw( type = "App.Model.User.Account.AlreadyExists" );

	}


	/**
	* I throw a not-found error.
	*/
	public void function throwNotFoundError() {

		throw( type = "App.Model.User.Account.NotFound" );

	}

}
