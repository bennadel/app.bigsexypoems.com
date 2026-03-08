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
	public numeric function offsetInMinutesFrom( required numeric input ) {

		return val( input );

	}

	// ---
	// ERROR METHODS.
	// ---

	/**
	* I throw a model error.
	*/
	public void function throwAlreadyExistsError() {

		throw( type = "App.Model.User.Timezone.AlreadyExists" );

	}


	/**
	* I throw a model error.
	*/
	public void function throwNotFoundError() {

		throw( type = "App.Model.User.Timezone.NotFound" );

	}

}
