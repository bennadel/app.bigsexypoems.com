component
	extends = "core.lib.model.BaseValidation"
	{

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I throw an already-exists error.
	*/
	public void function throwAlreadyExistsError() {

		throw( type = "App.Model.Session.Presence.AlreadyExists" );

	}


	/**
	* I throw a not-found error.
	*/
	public void function throwNotFoundError() {

		throw( type = "App.Model.Session.Presence.NotFound" );

	}

}
