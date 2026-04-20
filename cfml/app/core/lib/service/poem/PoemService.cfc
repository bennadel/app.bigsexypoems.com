component {

	// Define properties for dependency-injection.
	property name="collectionAccess" ioc:type="core.lib.service.collection.CollectionAccess";
	property name="collectionModel" ioc:type="core.lib.model.collection.CollectionModel";
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

		transaction {

			var userWithLock = userModel.get(
				id = user.id,
				withLock = "readonly"
			);

			if ( collectionID ) {

				var collectionWithLock = collectionModel.get(
					id = collectionID,
					withLock = "readonly"
				);

			}

			var poemID = poemModel.create(
				userID = userWithLock.id,
				collectionID = collectionID,
				name = name,
				content = content,
				createdAt = utcNow()
			);

			// Snapshot the persisted poem as the initial revision. Since we created this
			// poem inside a transaction, we don't have to lock the repeatable read - no
			// other request can see this poem until it's been committed.
			var poem = poemModel.get( poemID );

			revisionModel.create(
				poemID = poem.id,
				name = poem.name,
				content = poem.content,
				createdAt = poem.updatedAt
			);

		} // End: transaction.

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

		transaction {

			var userWithLock = userModel.get(
				id = user.id,
				withLock = "readonly"
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

		if ( ! isNull( collectionID ) ) {

			testCollectionID( authContext, poem.userID, collectionID );

		}

		transaction {

			if ( ! isNull( collectionID ) ) {

				var collectionWithLock = collectionModel.get(
					id = collectionID,
					withLock = "readonly"
				);

			}

			var poemWithLock = poemModel.get(
				id = poem.id,
				withLock = "exclusive"
			);

			poemModel.update(
				id = poemWithLock.id,
				collectionID = arguments?.collectionID,
				name = arguments?.name,
				content = arguments?.content,
				updatedAt = utcNow()
			);

			// We only need to worry about a revision if the poem content has changed.
			// --
			// Note: revision are tied to the content. As such, even if the collection ID
			// was changed above, a revision will only ever be created if the content of
			// the poem meaningfully changed.
			if (
				( isNull( name ) || ! compare( name, poemWithLock.name ) ) &&
				( isNull( content ) || ! compare( content, poemWithLock.content ) )
				) {

				return;

			}

			// We have to re-read the persisted poem for the revision snapshot; but the
			// row-lock already exists, so we don't need to lock the row - we just need to
			// make sure that we're reading the updated row cache so that our poem changes
			// make it into the revision.
			var updatedPoem = poemModel.get( poemWithLock.id );
			var windowInSeconds = 120;
			var cutoffAt = updatedPoem.updatedAt.add( "s", -windowInSeconds );
			var maybeLastRevision = revisionModel.maybeGetMostRecentByPoemID( updatedPoem.id );

			// If there's no previous revision, or the window has closed, create a new one.
			if (
				! maybeLastRevision.exists ||
				( maybeLastRevision.value.updatedAt <= cutoffAt )
				) {

				revisionModel.create(
					poemID = updatedPoem.id,
					name = updatedPoem.name,
					content = updatedPoem.content,
					createdAt = updatedPoem.updatedAt
				);

			// Otherwise, update the existing revision within the window.
			} else {

				revisionModel.update(
					id = maybeLastRevision.value.id,
					name = updatedPoem.name,
					content = updatedPoem.content,
					updatedAt = updatedPoem.updatedAt
				);

			}

		} // End: transaction.

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I test that the collection with the given ID exists and that it can be associated
	* with the poem owned by the given user.
	*/
	private void function testCollectionID(
		required struct authContext,
		required numeric userID,
		required numeric collectionID
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
