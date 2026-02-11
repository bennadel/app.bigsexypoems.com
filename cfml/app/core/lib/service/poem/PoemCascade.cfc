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
	* I delete the given poem and any data contained under it.
	*/
	public void function delete(
		required struct user,
		required struct poem
		) {

		deleteRevisions( poem );
		deleteShares( user, poem );

		poemModel.deleteByFilter( id = poem.id );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I delete the revisions associated with the given poem.
	*/
	private void function deleteRevisions( required struct poem ) {

		var revisions = revisionModel.getByFilter( poemID = poem.id );

		for ( var revision in revisions ) {

			revisionCascade.deleteRevision( revision );

		}

	}


	/**
	* I delete the shares associated with the given poem.
	*/
	private void function deleteShares(
		required struct user,
		required struct poem
		) {

		var shares = shareModel.getByFilter( poemID = poem.id );

		for ( var share in shares ) {

			shareCascade.deleteShare( user, poem, share );

		}

	}

}
