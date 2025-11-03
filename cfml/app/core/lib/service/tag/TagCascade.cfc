component {

	// Define properties for dependency-injection.
	property name="tagModel" ioc:type="core.lib.model.tag.TagModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I delete the given tag and any data contained under it.
	*/
	public void function delete(
		required struct user,
		required struct tag
		) {

		tagModel.deleteByFilter( id = tag.id );

	}

}
