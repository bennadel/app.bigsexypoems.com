component {

	// Define properties for dependency-injection.
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";
	property name="revisionAccess" ioc:type="core.lib.service.poem.RevisionAccess";
	property name="revisionCascade" ioc:type="core.lib.service.poem.RevisionCascade";
	property name="revisionModel" ioc:type="core.lib.model.poem.RevisionModel";
	property name="userModel" ioc:type="core.lib.model.user.UserModel";

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
		var user = context.user;
		var poem = context.poem;
		var revision = context.revision;

		transaction {

			var userWithLock = userModel.get(
				id = user.id,
				withLock = "readonly"
			);
			var poemWithLock = poemModel.get(
				id = poem.id,
				withLock = "readonly"
			);
			var revisionWithLock = revisionModel.get(
				id = revision.id,
				withLock = "exclusive"
			);

			revisionCascade.delete( userWithLock, poemWithLock, revisionWithLock );

		}

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
		var poem = context.poem;
		var revision = context.revision;

		transaction {

			var poemWithLock = poemModel.get(
				id = poem.id,
				withLock = "exclusive"
			);
			var revisionWithLock = revisionModel.get(
				id = revision.id,
				withLock = "readonly"
			);

			// Before overwriting the poem, snapshot the current live state so that the
			// user can revert back to it. Skip this if the most recent revision already
			// matches the live poem (no point creating a duplicate).
			var maybeLastRevision = revisionModel.maybeGetMostRecentByPoemID( poemWithLock.id );

			if (
				! maybeLastRevision.exists ||
				isRevisionStale( maybeLastRevision.value, poemWithLock )
				) {

				revisionModel.create(
					poemID = poemWithLock.id,
					name = poemWithLock.name,
					content = poemWithLock.content,
					createdAt = poemWithLock.updatedAt
				);

			}

			// Update the poem with the revision's content.
			poemModel.update(
				id = poemWithLock.id,
				name = revisionWithLock.name,
				content = revisionWithLock.content,
				updatedAt = utcNow()
			);

			// Create a new revision to snapshot the restored state.
			var restoredPoem = poemModel.get( poemWithLock.id );

			revisionModel.create(
				poemID = restoredPoem.id,
				name = restoredPoem.name,
				content = restoredPoem.content,
				createdAt = restoredPoem.updatedAt
			);

		}

	}

}
