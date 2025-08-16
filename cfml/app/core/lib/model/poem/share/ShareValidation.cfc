component
	extends = "core.lib.model.BaseValidation"
	{

	/**
	* I throw a not-found error.
	*/
	public void function throwNotFoundError() {

		throw( type = "App.Model.Poem.Share.NotFound" );

	}

}
