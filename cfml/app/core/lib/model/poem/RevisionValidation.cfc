component
	extends = "core.lib.model.BaseValidation"
	{

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// ERROR METHODS.
	// ---

	/**
	* I throw a forbidden error.
	*/
	public void function throwForbiddenError() {

		throw( type = "App.Model.Poem.Revision.Forbidden" );

	}


	/**
	* I throw a not-found error.
	*/
	public void function throwNotFoundError() {

		throw( type = "App.Model.Poem.Revision.NotFound" );

	}

}
