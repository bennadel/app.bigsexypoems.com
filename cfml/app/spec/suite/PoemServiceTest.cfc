component extends="spec.BaseTest" {

	// Define properties for dependency-injection.
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";
	property name="poemService" ioc:type="core.lib.service.poem.PoemService";
	property name="revisionModel" ioc:type="core.lib.model.poem.RevisionModel";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I test that creating a poem returns a valid ID and persists the data.
	*/
	public void function testCreatePersistsPoem() {

		var name = "Test Poem #createUUID()#";
		var content = "Roses are red.";

		var poemID = poemService.create(
			authContext = variables.authContext,
			userID = variables.testUser.id,
			collectionID = 0,
			name = name,
			content = content
		);

		var poem = poemModel.get( poemID );
		assertEqual( poem.name, name );
		assertEqual( poem.content, content );
		assertEqual( poem.userID, variables.testUser.id );

	}


	/**
	* I test that creating a poem also creates a revision.
	*/
	public void function testCreateAlsoCreatesRevision() {

		var poemID = poemService.create(
			authContext = variables.authContext,
			userID = variables.testUser.id,
			collectionID = 0,
			name = "Revision Test #createUUID()#",
			content = "Some content."
		);

		var revisions = revisionModel.getByFilter( poemID = poemID );
		assertTrue( revisions.len(), "Expected at least one revision after poem creation." );

	}


	/**
	* I test that creating a poem with an empty name throws a validation error.
	*/
	public void function testCreateWithEmptyNameThrows() {

		assertThrows(
			() => {

				poemService.create(
					authContext = variables.authContext,
					userID = variables.testUser.id,
					collectionID = 0,
					name = "",
					content = "Some content."
				);

			},
			"App.Model.Poem.Name.Empty"
		);

	}


	/**
	* I test that updating a poem persists the new name.
	*/
	public void function testUpdateChangesName() {

		var poemID = poemService.create(
			authContext = variables.authContext,
			userID = variables.testUser.id,
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
	* I test that updating with an oversized name throws a validation error.
	*/
	public void function testUpdateWithNameTooLongThrows() {

		var poemID = poemService.create(
			authContext = variables.authContext,
			userID = variables.testUser.id,
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
	* I test that deleting a poem makes it unfindable.
	*/
	public void function testDeleteRemovesPoem() {

		var poemID = poemService.create(
			authContext = variables.authContext,
			userID = variables.testUser.id,
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

}
