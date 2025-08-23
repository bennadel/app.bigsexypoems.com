component {

	// Define properties for dependency-injection.
	property name="shareModel" ioc:type="core.lib.model.poem.share.ShareModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I delete the given share and any data contained under it.
	*/
	public void function deleteShare(
		required struct user,
		required struct poem,
		required struct share
		) {

		shareModel.deleteByFilter( id = share.id );

	}

}
