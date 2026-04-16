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

		// Cascading deletion is initiated by the service layer but is treated as a black
		// box. Which means that we always execute it inside a transaction and we always
		// obtain exclusive locks on the rows that we're passing out-of-scope. The
		// transaction allows for atomic operations (which are very much needed in some
		// places and completely overkill in other places); and the transaction-based
		// locking allows for serialized access to rows that other workflows may be
		// locking concurrently. All locking must be performed from the "parent down" in
		// order to avoid deadlocks.
		transaction {

			// Re-fetch data with locks.
			var userWithLock = userModel.get(
				id = user.id,
				withLock = "exclusive"
			);
			var poemWithLock = poemModel.get(
				id = poem.id,
				withLock = "exclusive"
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
		var revision = context.revision;

		// This transaction uses an exclusive lock on the poem model in order to enforce
		// serialized access to the poem-level revisions (which is why we're re-fetching
		// the poem even though we could get it directly from the context).
		transaction {

			var poem = poemModel.get(
				id = context.poem.id,
				withLock = "exclusive"
			);

			// Before overwriting the poem, snapshot the current live state so the user
			// can revert back to it. Skip this if the most recent revision already
			// matches the live poem (no point creating a duplicate).
			var maybeLastRevision = revisionModel.maybeGetMostRecentByPoemID( poem.id );

			if (
				! maybeLastRevision.exists ||
				isRevisionStale( maybeLastRevision.value, poem )
				) {

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

		} // End: transaction and row-locks.

	}

}
