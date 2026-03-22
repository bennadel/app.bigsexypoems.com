component extends="spec.BaseTest" {

	// Define properties for dependency-injection.
	property name="collectionModel" ioc:type="core.lib.model.collection.CollectionModel";
	property name="collectionService" ioc:type="core.lib.service.collection.CollectionService";
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";
	property name="poemService" ioc:type="core.lib.service.poem.PoemService";

	// ---
	// HAPPY PATH TESTS.
	// ---

	/**
	* I test that creating a collection persists the data and parses the description.
	*/
	public void function testCreate() {

		var name = "TestCol #left( createUUID(), 8 )#";
		var descriptionMarkdown = "This is **bold** text.";

		var collectionID = collectionService.create(
			authContext = variables.authContext,
			userID = variables.authContext.user.id,
			name = name,
			descriptionMarkdown = descriptionMarkdown
		);

		var collection = collectionModel.get( collectionID );
		assertEqual( collection.name, name );
		assertEqual( collection.descriptionMarkdown, descriptionMarkdown );
		assertEqual( collection.userID, variables.authContext.user.id );
		assertTrue( collection.descriptionHtml.find( "<strong>" ), "Expected parsed HTML to contain <strong> tag." );

	}


	/**
	* I test that updating a collection persists the new values.
	*/
	public void function testUpdate() {

		var collectionID = collectionService.create(
			authContext = variables.authContext,
			userID = variables.authContext.user.id,
			name = "Before #left( createUUID(), 8 )#",
			descriptionMarkdown = "Old description."
		);

		var newName = "After #left( createUUID(), 8 )#";
		var newDescription = "New **description**.";

		collectionService.update(
			authContext = variables.authContext,
			id = collectionID,
			name = newName,
			descriptionMarkdown = newDescription
		);

		var collection = collectionModel.get( collectionID );
		assertEqual( collection.name, newName );
		assertEqual( collection.descriptionMarkdown, newDescription );
		assertTrue( collection.descriptionHtml.find( "<strong>" ), "Expected parsed HTML to contain <strong> tag." );

	}


	/**
	* I test that deleting a collection removes it and unlinks its poems.
	*/
	public void function testDelete() {

		var collectionID = collectionService.create(
			authContext = variables.authContext,
			userID = variables.authContext.user.id,
			name = "DeleteMe #left( createUUID(), 8 )#",
			descriptionMarkdown = ""
		);

		var poemID = poemService.create(
			authContext = variables.authContext,
			userID = variables.authContext.user.id,
			collectionID = collectionID,
			name = "Poem #left( createUUID(), 8 )#",
			content = "Content."
		);

		collectionService.delete(
			authContext = variables.authContext,
			id = collectionID
		);

		var result = collectionModel.maybeGet( collectionID );
		assertTrue( ! result.exists, "Expected collection to be deleted but it still exists." );

		var poem = poemModel.get( poemID );
		assertEqual( poem.collectionID, 0, "Expected poem to be unlinked from deleted collection." );

	}

	// ---
	// SAD PATH TESTS.
	// ---

	/**
	* I test that creating a collection with invalid input throws a validation error.
	*/
	public void function testCreateWithInvalidInputThrows() {

		// Empty name.
		assertThrows(
			() => {

				collectionService.create(
					authContext = variables.authContext,
					userID = variables.authContext.user.id,
					name = "",
					descriptionMarkdown = ""
				);

			},
			"App.Model.Collection.Name.Empty"
		);

		// Name too long.
		assertThrows(
			() => {

				collectionService.create(
					authContext = variables.authContext,
					userID = variables.authContext.user.id,
					name = repeatString( "x", 100 ),
					descriptionMarkdown = ""
				);

			},
			"App.Model.Collection.Name.TooLong"
		);

		// Suspicious encoding in name.
		assertThrows(
			() => {

				collectionService.create(
					authContext = variables.authContext,
					userID = variables.authContext.user.id,
					name = "Test %2525 Encoded",
					descriptionMarkdown = ""
				);

			},
			"App.Model.Collection.Name.SuspiciousEncoding"
		);

		// Description markdown too long.
		assertThrows(
			() => {

				collectionService.create(
					authContext = variables.authContext,
					userID = variables.authContext.user.id,
					name = "Valid #left( createUUID(), 8 )#",
					descriptionMarkdown = repeatString( "x", 600 )
				);

			},
			"App.Model.Collection.DescriptionMarkdown.TooLong"
		);

	}


	/**
	* I test that updating a collection with invalid input throws a validation error.
	*/
	public void function testUpdateWithInvalidInputThrows() {

		var collectionID = collectionService.create(
			authContext = variables.authContext,
			userID = variables.authContext.user.id,
			name = "Valid #left( createUUID(), 8 )#",
			descriptionMarkdown = ""
		);

		// Name too long.
		assertThrows(
			() => {

				collectionService.update(
					authContext = variables.authContext,
					id = collectionID,
					name = repeatString( "x", 100 )
				);

			},
			"App.Model.Collection.Name.TooLong"
		);

		// Description markdown too long.
		assertThrows(
			() => {

				collectionService.update(
					authContext = variables.authContext,
					id = collectionID,
					descriptionMarkdown = repeatString( "x", 600 )
				);

			},
			"App.Model.Collection.DescriptionMarkdown.TooLong"
		);

		// Suspicious encoding in name.
		assertThrows(
			() => {

				collectionService.update(
					authContext = variables.authContext,
					id = collectionID,
					name = "Test %2525 Encoded"
				);

			},
			"App.Model.Collection.Name.SuspiciousEncoding"
		);

	}


	/**
	* I test that parsing unsafe HTML tags in description markdown throws a validation error.
	*/
	public void function testParseDescriptionMarkdownWithUnsafeTagsThrows() {

		assertThrows(
			() => {

				collectionService.parseDescriptionMarkdown( "<div>unsafe block</div>" );

			},
			"App.Model.Collection.DescriptionMarkdown.Unsafe"
		);

	}


	/**
	* I test that accessing another user's collection throws a not-found error.
	*/
	public void function testOtherUserCollectionThrowsNotFound() {

		var otherAuthContext = provisionAuthContext();

		var collectionID = collectionService.create(
			authContext = otherAuthContext,
			userID = otherAuthContext.user.id,
			name = "Other #left( createUUID(), 8 )#",
			descriptionMarkdown = ""
		);

		assertThrows(
			() => {

				collectionService.update(
					authContext = variables.authContext,
					id = collectionID,
					name = "Hacked"
				);

			},
			"App.Model.Collection.NotFound"
		);

		assertThrows(
			() => {

				collectionService.delete(
					authContext = variables.authContext,
					id = collectionID
				);

			},
			"App.Model.Collection.NotFound"
		);

	}

}
