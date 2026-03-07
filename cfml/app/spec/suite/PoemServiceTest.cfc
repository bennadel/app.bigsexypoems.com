component extends="spec.BaseTest" {

	// Define properties for dependency-injection.
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
	* I test that creating a poem with an empty name throws a validation error.
	*/
	public void function testCreateWithEmptyNameThrows() {

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

	}


	/**
	* I test that updating a poem with an oversized name throws a validation error.
	*/
	public void function testUpdateWithNameTooLongThrows() {

		var poemID = poemService.create(
			authContext = variables.authContext,
			userID = variables.authContext.user.id,
			collectionID = 0,
			name = "Valid Name #createUUID()#",
			content = "Content."
		);

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
