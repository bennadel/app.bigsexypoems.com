component {

	// Define properties for dependency-injection.
	property name="collectionAccess" ioc:type="core.lib.service.collection.CollectionAccess";
	property name="logger" ioc:type="core.lib.util.Logger";
	property name="poemAccess" ioc:type="core.lib.service.poem.PoemAccess";
	property name="poemCascade" ioc:type="core.lib.service.poem.PoemCascade";
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";
	property name="poemValidation" ioc:type="core.lib.model.poem.PoemValidation";
	property name="requestMetadata" ioc:type="core.lib.web.RequestMetadata";
	property name="revisionModel" ioc:type="core.lib.model.poem.RevisionModel";
	property name="userModel" ioc:type="core.lib.model.user.UserModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create a new poem.
	*/
	public numeric function create(
		required struct authContext,
		required numeric userID,
		required numeric collectionID,
		required string name,
		required string content
		) {

		var context = poemAccess.getContextForParent( authContext, userID, "canCreateAny" );
		var user = context.user;

		testCollectionID( authContext, userID, collectionID );

		var poemID = poemModel.create(
			userID = user.id,
			collectionID = collectionID,
			name = name,
			content = content,
			createdAt = utcNow()
		);

		saveRevision( poemID );

		return poemID;

	}


	/**
	* I delete the given poem.
	*/
	public void function delete(
		required struct authContext,
		required numeric id
		) {

		var context = poemAccess.getContext( authContext, id, "canDelete" );
		var user = context.user;
		var poem = context.poem;

		// Log the poem content for Support purposes. This will copy the content into the
		// logs which will then be automatically flushed within a few days (the logs are
		// all transient). This way, if someone deletes a poem accidentally, we'll have a
		// few days to manually recover it for them.
		// --
		// Note: logging PII (personally identifiable information) is frowned upon. But,
		// I think the amount of information is sufficiently safe; and is out-weighed by
		// the possible happiness this might bring the user (after an accidental delete).
		if ( ! requestMetadata.isTestRun() ) {

			logger.info(
				"Poem deleted (logged for recovery purposes).",
				{
					user: structPick( user, [ "id", "email" ] ),
					poem: structPick( poem, [ "name", "content" ] )
				}
			);

		}

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

			poemCascade.delete( userWithLock, poemWithLock );

		}

	}


	/**
	* I split the given poem content into an array of lines.
	*/
	public array function splitLines( required string content ) {

		if ( ! content.len() ) {

			return [];

		}

		return content.reMatch( "[^\n]*" );

	}


	/**
	* I update the given poem.
	*/
	public void function update(
		required struct authContext,
		required numeric id,
		numeric collectionID,
		string name,
		string content
		) {

		var context = poemAccess.getContext( authContext, id, "canUpdate" );
		var poem = context.poem;

		testCollectionID( authContext, poem.userID, arguments?.collectionID );

		poemModel.update(
			id = poem.id,
			collectionID = arguments?.collectionID,
			name = arguments?.name,
			content = arguments?.content,
			updatedAt = utcNow()
		);

		saveRevision( poem.id );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I save a revision for the given poem. If the most recent revision was updated within
	* the windowing period, I update it in place. Otherwise, I create a new revision. The
	* revision is snapshotted from the persisted poem state.
	*/
	private void function saveRevision( required numeric poemID ) {

		var windowInSeconds = 120;

		// This transaction uses an exclusive lock on the poem model in order to enforce
		// serialized access to the poem-level revisions.
		transaction {

			var poem = poemModel.get(
				id = poemID,
				withLock = "exclusive"
			);

			var cutoffAt = poem.updatedAt.add( "s", -windowInSeconds );
			var maybeLastRevision = revisionModel.maybeGetMostRecentByPoemID( poemID );

			// If there's no previous revision, or the window has closed, create a new one.
			if (
				! maybeLastRevision.exists ||
				( maybeLastRevision.value.updatedAt <= cutoffAt )
				) {

				revisionModel.create(
					poemID = poemID,
					name = poem.name,
					content = poem.content,
					createdAt = poem.updatedAt
				);

			// Otherwise, update the existing revision within the window.
			} else {

				revisionModel.update(
					id = maybeLastRevision.value.id,
					name = poem.name,
					content = poem.content,
					updatedAt = poem.updatedAt
				);

			}

		} // End: transaction and row-locks.

	}


	/**
	* I test that the collection with the given ID exists and that it can be associated
	* with the a poem owned by the given user.
	*/
	private void function testCollectionID(
		required struct authContext,
		required numeric userID,
		numeric collectionID = 0
		) {

		if ( ! collectionID ) {

			return;

		}

		var collection = collectionAccess
			.getContext( authContext, collectionID, "canView" )
			.collection
		;

		if ( collection.userID != userID ) {

			poemValidation.throwForbiddenError();

		}

	}

}
