component {

	// Define properties for dependency-injection.
	property name="collectionAccess" ioc:type="core.lib.service.collection.CollectionAccess";
	property name="logger" ioc:type="core.lib.util.Logger";
	property name="poemAccess" ioc:type="core.lib.service.poem.PoemAccess";
	property name="poemCascade" ioc:type="core.lib.service.poem.PoemCascade";
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";
	property name="poemValidation" ioc:type="core.lib.model.poem.PoemValidation";
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
		logger.info(
			"Poem deleted (logged for recovery purposes).",
			{
				user: structPick( user, [ "id", "email" ] ),
				poem: structPick( poem, [ "name", "content" ] )
			}
		);

		poemCascade.delete( user, poem );

	}


	/**
	* I split the given poem content into an array of lines.
	*/
	public array function splitLines( required string content ) {

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
		var poem = poemModel.get( poemID );
		var maybeLastRevision = revisionModel.maybeGetMostRecentByPoemID( poemID );

		var shouldCreateNewRevision = (
			! maybeLastRevision.exists ||
			( dateDiff( "s", maybeLastRevision.value.updatedAt, poem.updatedAt ) >= windowInSeconds )
		);

		// If there's no previous revision, or the window has closed, create a new one.
		if ( shouldCreateNewRevision ) {

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
