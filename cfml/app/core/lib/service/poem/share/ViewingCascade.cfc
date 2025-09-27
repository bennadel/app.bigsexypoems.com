component {

	// Define properties for dependency-injection.
	property name="viewingModel" ioc:type="core.lib.model.poem.share.ViewingModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I delete the given viewing and any data contained under it.
	*/
	public void function deleteViewing(
		required struct user,
		required struct poem,
		required struct share,
		required struct viewing
		) {

		viewingModel.deleteByFilter( id = viewing.id );

	}

}
