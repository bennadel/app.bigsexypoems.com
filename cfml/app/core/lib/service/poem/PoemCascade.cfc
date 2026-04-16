component {

	// Define properties for dependency-injection.
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";
	property name="revisionCascade" ioc:type="core.lib.service.poem.RevisionCascade";
	property name="revisionModel" ioc:type="core.lib.model.poem.RevisionModel";
	property name="shareCascade" ioc:type="core.lib.service.poem.share.ShareCascade";
	property name="shareModel" ioc:type="core.lib.model.poem.share.ShareModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I delete the given poem and any data that's logically contained under it.
	* 
	* Caution: this method must be called within a transaction block. All withLock usage
	* contained herein will be scoped to said transaction block and will create mutual
	* exclusion with other row-locking workflows. All passed-in entities must be locked.
	*/
	public void function delete(
		required struct user,
		required struct poem
		) {

		deleteRevisions( user, poem );
		deleteShares( user, poem );

		poemModel.deleteByFilter( id = poem.id );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I delete the revisions associated with the given poem.
	*/
	private void function deleteRevisions(
		required struct user,
		required struct poem
		) {

		var revisions = revisionModel.getByFilter(
			poemID = poem.id,
			withLock = "exclusive"
		);

		for ( var revision in revisions ) {

			revisionCascade.delete( user, poem, revision );

		}

	}


	/**
	* I delete the shares associated with the given poem.
	*/
	private void function deleteShares(
		required struct user,
		required struct poem
		) {

		var shares = shareModel.getByFilter(
			poemID = poem.id,
			withLock = "exclusive"
		);

		for ( var share in shares ) {

			shareCascade.delete( user, poem, share );

		}

	}

}
