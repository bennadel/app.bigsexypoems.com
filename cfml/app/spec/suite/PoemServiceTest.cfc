component extends="spec.BaseTest" {

	// Define properties for dependency-injection.
	property name="collectionService" ioc:type="core.lib.service.collection.CollectionService";
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";
	property name="poemService" ioc:type="core.lib.service.poem.PoemService";
	property name="revisionModel" ioc:type="core.lib.model.poem.RevisionModel";
	property name="shareModel" ioc:type="core.lib.model.poem.share.ShareModel";
	property name="shareService" ioc:type="core.lib.service.poem.share.ShareService";
	property name="viewingModel" ioc:type="core.lib.model.poem.share.ViewingModel";

	// ---
	// HAPPY PATH TESTS.
	// ---

	/**
	* I test that creating a poem persists the data and captures an initial revision
	* that mirrors the poem's name and content.
	*/
	public void function testCreate() {

		var name = "Test Poem #createUUID()#";
		var content = "Roses are red.";

		var poemID = poemService.create(
			authContext = variables.authContext,
			userID = variables.authContext.user.id,
			collectionID = 0,
			name = name,
			content = content
		);

		var poem = poemModel.get( poemID );
		assertEqual( poem.name, name );
		assertEqual( poem.content, content );
		assertEqual( poem.userID, variables.authContext.user.id );

		// The initial revision is snapshotted from the persisted poem.
		var revisions = revisionModel.getByFilter( poemID = poemID );
		assertEqual( revisions.len(), 1, "Expected exactly one initial revision." );
		assertEqual( revisions.first().name, name, "Expected initial revision name to match the poem." );
		assertEqual( revisions.first().content, content, "Expected initial revision content to match the poem." );

	}


	/**
	* I test that updating a poem persists the new values and updates the existing
	* revision in place (rather than creating a new one) within the windowing period.
	*/
	public void function testUpdate() {

		var poemID = poemService.create(
			authContext = variables.authContext,
			userID = variables.authContext.user.id,
			collectionID = 0,
			name = "Before #createUUID()#",
			content = "Before content."
		);

		var newName = "After #createUUID()#";
		var newContent = "After content.";

		poemService.update(
			authContext = variables.authContext,
			id = poemID,
			name = newName,
			content = newContent
		);

		var poem = poemModel.get( poemID );
		assertEqual( poem.name, newName );
		assertEqual( poem.content, newContent );

		// Within the 120-second windowing period, the existing revision should be
		// updated in place — no new revision is created.
		var revisions = revisionModel.getByFilter( poemID = poemID );
		assertEqual( revisions.len(), 1, "Expected revision to be updated in place within windowing period." );
		assertEqual( revisions.first().name, newName, "Expected windowed revision to reflect the updated name." );
		assertEqual( revisions.first().content, newContent, "Expected windowed revision to reflect the updated content." );

	}


	/**
	* I test that deleting a poem cascades to revisions, shares, and viewings.
	*/
	public void function testDelete() {

		var poemID = poemService.create(
			authContext = variables.authContext,
			userID = variables.authContext.user.id,
			collectionID = 0,
			name = "Delete Me #createUUID()#",
			content = "Content."
		);

		// Create child entities to verify cascade.
		var shareID = shareService.create(
			authContext = variables.authContext,
			poemID = poemID,
			name = "Share",
			noteMarkdown = "",
			isSnapshot = false
		);
		shareService.logShareViewing( shareID );

		poemService.delete(
			authContext = variables.authContext,
			id = poemID
		);

		var result = poemModel.maybeGet( poemID );
		assertTrue( ! result.exists, "Expected poem to be deleted." );

		var revisions = revisionModel.getByFilter( poemID = poemID );
		assertEqual( revisions.len(), 0, "Expected revisions to be cascade-deleted." );

		var shares = shareModel.getByFilter( poemID = poemID );
		assertEqual( shares.len(), 0, "Expected shares to be cascade-deleted." );

		var viewings = viewingModel.getByFilter( poemID = poemID, shareID = shareID );
		assertEqual( viewings.len(), 0, "Expected viewings to be cascade-deleted." );

	}

	// ---
	// SAD PATH TESTS.
	// ---

	/**
	* I test that creating a poem with invalid input throws a validation error.
	*/
	public void function testCreateWithInvalidInputThrows() {

		var otherAuthContext = provisionAuthContext();
		var otherCollectionID = collectionService.create(
			authContext = otherAuthContext,
			userID = otherAuthContext.user.id,
			name = "OtherCol #createUUID()#",
			descriptionMarkdown = ""
		);

		// Empty name.
		assertThrows(
			() => {

				poemService.create(
					authContext = variables.authContext,
					userID = variables.authContext.user.id,
					collectionID = 0,
					name = "",
					content = "Some content."
				);

			},
			"App.Model.Poem.Name.Empty"
		);

		// Name too long.
		assertThrows(
			() => {

				poemService.create(
					authContext = variables.authContext,
					userID = variables.authContext.user.id,
					collectionID = 0,
					name = repeatString( "x", 300 ),
					content = "Some content."
				);

			},
			"App.Model.Poem.Name.TooLong"
		);

		// Content too long.
		assertThrows(
			() => {

				poemService.create(
					authContext = variables.authContext,
					userID = variables.authContext.user.id,
					collectionID = 0,
					name = "Valid Name #createUUID()#",
					content = repeatString( "x", 4000 )
				);

			},
			"App.Model.Poem.Content.TooLong"
		);

		// Suspicious encoding in name.
		assertThrows(
			() => {

				poemService.create(
					authContext = variables.authContext,
					userID = variables.authContext.user.id,
					collectionID = 0,
					name = "Test %2525 Encoded",
					content = "Some content."
				);

			},
			"App.Model.Poem.Name.SuspiciousEncoding"
		);

		// Collection owned by another user.
		assertThrows(
			() => {

				poemService.create(
					authContext = variables.authContext,
					userID = variables.authContext.user.id,
					collectionID = otherCollectionID,
					name = "Valid Name #createUUID()#",
					content = "Some content."
				);

			},
			"App.Model.Collection.NotFound"
		);

	}


	/**
	* I test that updating a poem with invalid input throws a validation error.
	*/
	public void function testUpdateWithInvalidInputThrows() {

		var otherAuthContext = provisionAuthContext();
		var otherCollectionID = collectionService.create(
			authContext = otherAuthContext,
			userID = otherAuthContext.user.id,
			name = "OtherCol #createUUID()#",
			descriptionMarkdown = ""
		);

		var poemID = poemService.create(
			authContext = variables.authContext,
			userID = variables.authContext.user.id,
			collectionID = 0,
			name = "Valid Name #createUUID()#",
			content = "Content."
		);

		// Name too long.
		assertThrows(
			() => {

				poemService.update(
					authContext = variables.authContext,
					id = poemID,
					name = repeatString( "x", 300 )
				);

			},
			"App.Model.Poem.Name.TooLong"
		);

		// Content too long.
		assertThrows(
			() => {

				poemService.update(
					authContext = variables.authContext,
					id = poemID,
					content = repeatString( "x", 4000 )
				);

			},
			"App.Model.Poem.Content.TooLong"
		);

		// Suspicious encoding in content.
		assertThrows(
			() => {

				poemService.update(
					authContext = variables.authContext,
					id = poemID,
					content = "Test %2525 Encoded"
				);

			},
			"App.Model.Poem.Content.SuspiciousEncoding"
		);

		// Collection owned by another user.
		assertThrows(
			() => {

				poemService.update(
					authContext = variables.authContext,
					id = poemID,
					collectionID = otherCollectionID
				);

			},
			"App.Model.Collection.NotFound"
		);

	}


	/**
	* I test that accessing another user's poem throws a not-found error.
	*/
	public void function testOtherUserPoemThrowsNotFound() {

		var otherAuthContext = provisionAuthContext();

		var poemID = poemService.create(
			authContext = otherAuthContext,
			userID = otherAuthContext.user.id,
			collectionID = 0,
			name = "Other User Poem #createUUID()#",
			content = "Content."
		);

		assertThrows(
			() => {

				poemService.update(
					authContext = variables.authContext,
					id = poemID,
					name = "Hacked"
				);

			},
			"App.Model.Poem.NotFound"
		);

		assertThrows(
			() => {

				poemService.delete(
					authContext = variables.authContext,
					id = poemID
				);

			},
			"App.Model.Poem.NotFound"
		);

	}

}
