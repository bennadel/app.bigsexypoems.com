component extends="spec.BaseTest" {

	// Define properties for dependency-injection.
	property name="collectionService" ioc:type="core.lib.service.collection.CollectionService";
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";
	property name="poemService" ioc:type="core.lib.service.poem.PoemService";
	property name="revisionModel" ioc:type="core.lib.model.poem.RevisionModel";

	// ---
	// HAPPY PATH TESTS.
	// ---

	/**
	* I test that creating a poem persists the data and creates a revision.
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

		var revisions = revisionModel.getByFilter( poemID = poemID );
		assertTrue( revisions.len(), "Expected at least one revision after poem creation." );

	}


	/**
	* I test that updating a poem persists the new name.
	*/
	public void function testUpdate() {

		var poemID = poemService.create(
			authContext = variables.authContext,
			userID = variables.authContext.user.id,
			collectionID = 0,
			name = "Before #createUUID()#",
			content = "Content."
		);

		var newName = "After #createUUID()#";

		poemService.update(
			authContext = variables.authContext,
			id = poemID,
			name = newName
		);

		var poem = poemModel.get( poemID );
		assertEqual( poem.name, newName );

	}


	/**
	* I test that deleting a poem makes it unfindable.
	*/
	public void function testDelete() {

		var poemID = poemService.create(
			authContext = variables.authContext,
			userID = variables.authContext.user.id,
			collectionID = 0,
			name = "Delete Me #createUUID()#",
			content = "Content."
		);

		poemService.delete(
			authContext = variables.authContext,
			id = poemID
		);

		var result = poemModel.maybeGet( poemID );
		assertTrue( ! result.exists, "Expected poem to be deleted but it still exists." );

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
