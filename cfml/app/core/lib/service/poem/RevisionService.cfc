component {

	// Define properties for dependency-injection.
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";
	property name="revisionAccess" ioc:type="core.lib.service.poem.RevisionAccess";
	property name="revisionCascade" ioc:type="core.lib.service.poem.RevisionCascade";
	property name="revisionModel" ioc:type="core.lib.model.poem.RevisionModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I delete a revision.
	*/
	public void function delete(
		required struct authContext,
		required numeric id
		) {

		var context = revisionAccess.getContext( authContext, id, "canDelete" );
		var revision = context.revision;

		revisionCascade.deleteRevision( revision );

	}


	/**
	* I determine if the revision is stale (ie, the poem content is different from the
	* content in the revision).
	*/
	public boolean function isRevisionStale(
		required struct revision,
		required struct poem
		) {

		return (
			compare( revision.name, poem.name ) ||
			compare( revision.content, poem.content )
		);

	}


	/**
	* I restore the given revision as the current poem content.
	*/
	public void function makeCurrent(
		required struct authContext,
		required numeric revisionID
		) {

		var context = revisionAccess.getContext( authContext, revisionID, "canMakeCurrent" );
		var revision = context.revision;
		var poem = context.poem;

		// Before overwriting the poem, snapshot the current live state so the user can
		// revert back to it. Skip this if the most recent revision already matches the
		// live poem (no point creating a duplicate).
		var maybeLastRevision = revisionModel.maybeGetMostRecentByPoemID( poem.id );

		var isLastRevisionStale = (
			! maybeLastRevision.exists ||
			! isRevisionStale( maybeLastRevision.value, poem )
		);

		if ( isLastRevisionStale ) {

			revisionModel.create(
				poemID = poem.id,
				name = poem.name,
				content = poem.content,
				createdAt = poem.updatedAt
			);

		}

		// Update the poem with the revision's content.
		poemModel.update(
			id = poem.id,
			name = revision.name,
			content = revision.content,
			updatedAt = utcNow()
		);

		// Create a new revision to snapshot the restored state.
		var restoredPoem = poemModel.get( poem.id );

		revisionModel.create(
			poemID = restoredPoem.id,
			name = restoredPoem.name,
			content = restoredPoem.content,
			createdAt = restoredPoem.updatedAt
		);

	}

}
