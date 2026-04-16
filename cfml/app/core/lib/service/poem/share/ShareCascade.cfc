component {

	// Define properties for dependency-injection.
	property name="shareModel" ioc:type="core.lib.model.poem.share.ShareModel";
	property name="viewingCascade" ioc:type="core.lib.service.poem.share.ViewingCascade";
	property name="viewingModel" ioc:type="core.lib.model.poem.share.ViewingModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I delete the given share and any data that's logically contained under it.
	* 
	* Caution: this method must be called within a transaction block. All withLock usage
	* contained herein will be scoped to said transaction block and will create mutual
	* exclusion with other row-locking workflows. All passed-in entities must be locked.
	*/
	public void function delete(
		required struct user,
		required struct poem,
		required struct share
		) {

		deleteViewings( user, poem, share );

		shareModel.deleteByFilter( id = share.id );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I delete the viewings associated with the given share.
	*/
	private void function deleteViewings(
		required struct user,
		required struct poem,
		required struct share
		) {

		var viewings = viewingModel.getByFilter(
			poemID = poem.id,
			shareID = share.id,
			withLock = "exclusive"
		);

		for ( var viewing in viewings ) {

			viewingCascade.delete( user, poem, share, viewing );

		}

	}

}
