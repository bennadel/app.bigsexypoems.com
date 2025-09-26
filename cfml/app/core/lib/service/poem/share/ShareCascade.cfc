component {

	// Define properties for dependency-injection.
	property name="shareModel" ioc:type="core.lib.model.poem.share.ShareModel";
	property name="viewingModel" ioc:type="core.lib.model.poem.share.ViewingModel";

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

		viewingModel.deleteByFilter(
			poemID = poem.id,
			shareID = share.id
		);
		shareModel.deleteByFilter( id = share.id );

	}

}
