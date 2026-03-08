component
	extends = "core.lib.model.BaseValidation"
	{

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I throw a model error.
	*/
	public void function throwAlreadyExistsError() {

		throw( type = "App.Model.User.Account.AlreadyExists" );

	}


	/**
	* I throw a model error.
	*/
	public void function throwNotFoundError() {

		throw( type = "App.Model.User.Account.NotFound" );

	}

}
