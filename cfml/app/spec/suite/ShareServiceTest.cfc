component extends="spec.BaseTest" {

	// Define properties for dependency-injection.
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";
	property name="poemService" ioc:type="core.lib.service.poem.PoemService";
	property name="shareModel" ioc:type="core.lib.model.poem.share.ShareModel";
	property name="shareService" ioc:type="core.lib.service.poem.share.ShareService";
	property name="viewingModel" ioc:type="core.lib.model.poem.share.ViewingModel";

	// ---
	// HAPPY PATH TESTS.
	// ---

	/**
	* I test that creating a share persists the data, defaults an empty name to "Unnamed
	* Share", and captures a snapshot when enabled.
	*/
	public void function testCreate() {

		var poemID = createPoem( "Create Share Poem" );

		// Create with explicit name and no snapshot.
		var shareID = shareService.create(
			authContext = variables.authContext,
			poemID = poemID,
			name = "My Share",
			noteMarkdown = "A **bold** note.",
			isSnapshot = false
		);

		var share = shareModel.get( shareID );
		assertEqual( share.name, "My Share" );
		assertEqual( share.noteMarkdown, "A **bold** note." );
		assertTrue( share.noteHtml.find( "<strong>" ), "Expected parsed HTML to contain <strong> tag." );
		assertTrue( share.token.len(), "Expected a non-empty token." );
		assertTrue( ! share.isSnapshot, "Expected isSnapshot to be false." );
		assertEqual( share.snapshotName, "" );
		assertEqual( share.snapshotContent, "" );

		// Create with empty name — should default to "Unnamed Share".
		var unnamedShareID = shareService.create(
			authContext = variables.authContext,
			poemID = poemID,
			name = "",
			noteMarkdown = "",
			isSnapshot = false
		);

		var unnamedShare = shareModel.get( unnamedShareID );
		assertEqual( unnamedShare.name, "Unnamed Share" );

		// Create with snapshot enabled — should capture poem content.
		var poem = poemModel.get( poemID );
		var snapshotShareID = shareService.create(
			authContext = variables.authContext,
			poemID = poemID,
			name = "Snapshot Share",
			noteMarkdown = "",
			isSnapshot = true
		);

		var snapshotShare = shareModel.get( snapshotShareID );
		assertTrue( snapshotShare.isSnapshot, "Expected isSnapshot to be true." );
		assertEqual( snapshotShare.snapshotName, poem.name );
		assertEqual( snapshotShare.snapshotContent, poem.content );

	}


	/**
	* I test that updating a share persists the new values.
	*/
	public void function testUpdate() {

		var poemID = createPoem( "Update Share Poem" );

		var shareID = shareService.create(
			authContext = variables.authContext,
			poemID = poemID,
			name = "Before",
			noteMarkdown = "Old note.",
			isSnapshot = false
		);

		shareService.update(
			authContext = variables.authContext,
			id = shareID,
			name = "After",
			noteMarkdown = "New **note**.",
			isSnapshot = true
		);

		var share = shareModel.get( shareID );
		assertEqual( share.name, "After" );
		assertEqual( share.noteMarkdown, "New **note**." );
		assertTrue( share.noteHtml.find( "<strong>" ), "Expected parsed HTML to contain <strong> tag." );
		assertTrue( share.isSnapshot, "Expected isSnapshot to be true after update." );

		var poem = poemModel.get( poemID );
		assertEqual( share.snapshotName, poem.name );
		assertEqual( share.snapshotContent, poem.content );

	}


	/**
	* I test that deleting a share removes it.
	*/
	public void function testDelete() {

		var poemID = createPoem( "Delete Share Poem" );

		var shareID = shareService.create(
			authContext = variables.authContext,
			poemID = poemID,
			name = "Delete Me",
			noteMarkdown = "",
			isSnapshot = false
		);

		shareService.delete(
			authContext = variables.authContext,
			id = shareID
		);

		var result = shareModel.maybeGet( shareID );
		assertTrue( ! result.exists, "Expected share to be deleted." );

	}


	/**
	* I test that deleteForPoem removes all shares for a given poem.
	*/
	public void function testDeleteForPoem() {

		var poemID = createPoem( "Delete All Shares Poem" );

		shareService.create(
			authContext = variables.authContext,
			poemID = poemID,
			name = "Share 1",
			noteMarkdown = "",
			isSnapshot = false
		);

		shareService.create(
			authContext = variables.authContext,
			poemID = poemID,
			name = "Share 2",
			noteMarkdown = "",
			isSnapshot = false
		);

		shareService.deleteForPoem(
			authContext = variables.authContext,
			poemID = poemID
		);

		var remaining = shareModel.getByFilter( poemID = poemID );
		assertEqual( remaining.len(), 0, "Expected all shares to be deleted." );

	}


	/**
	* I test that refreshSnapshot updates the snapshot with the current poem state.
	*/
	public void function testRefreshSnapshot() {

		var poemID = createPoem( "Refresh Snapshot Poem" );

		var shareID = shareService.create(
			authContext = variables.authContext,
			poemID = poemID,
			name = "Snap",
			noteMarkdown = "",
			isSnapshot = true
		);

		// Update the poem so the snapshot is stale.
		poemService.update(
			authContext = variables.authContext,
			id = poemID,
			name = "Changed Name",
			content = "Changed content."
		);

		shareService.refreshSnapshot(
			authContext = variables.authContext,
			id = shareID
		);

		var share = shareModel.get( shareID );
		assertEqual( share.snapshotName, "Changed Name" );
		assertEqual( share.snapshotContent, "Changed content." );

	}


	/**
	* I test that isSnapshotStale detects when a snapshot diverges from the poem.
	*/
	public void function testIsSnapshotStale() {

		var poem = { name: "Name", content: "Content." };

		// Non-snapshot share — never stale.
		var nonSnapshot = { isSnapshot: false, snapshotName: "", snapshotContent: "" };
		assertTrue( ! shareService.isSnapshotStale( nonSnapshot, poem ), "Expected non-snapshot to not be stale." );

		// Matching snapshot — not stale.
		var matching = { isSnapshot: true, snapshotName: "Name", snapshotContent: "Content." };
		assertTrue( ! shareService.isSnapshotStale( matching, poem ), "Expected matching snapshot to not be stale." );

		// Different name — stale.
		var staleName = { isSnapshot: true, snapshotName: "Old Name", snapshotContent: "Content." };
		assertTrue( shareService.isSnapshotStale( staleName, poem ), "Expected different name to be stale." );

		// Different content — stale.
		var staleContent = { isSnapshot: true, snapshotName: "Name", snapshotContent: "Old content." };
		assertTrue( shareService.isSnapshotStale( staleContent, poem ), "Expected different content to be stale." );

	}


	/**
	* I test that getOpenGraphImageVersion produces consistent hashes and changes when
	* inputs change.
	*/
	public void function testGetOpenGraphImageVersion() {

		var version1 = shareService.getOpenGraphImageVersion(
			poemName = "Poem",
			poemContent = "Content.",
			userName = "User"
		);

		var version2 = shareService.getOpenGraphImageVersion(
			poemName = "Poem",
			poemContent = "Content.",
			userName = "User"
		);

		assertEqual( version1, version2, "Expected same inputs to produce same hash." );

		var version3 = shareService.getOpenGraphImageVersion(
			poemName = "Different Poem",
			poemContent = "Content.",
			userName = "User"
		);

		assertTrue( version1 != version3, "Expected different inputs to produce different hash." );

	}


	/**
	* I test that logShareViewing creates a viewing record and updates the share metrics.
	*/
	public void function testLogShareViewing() {

		var poemID = createPoem( "Viewing Poem" );

		var shareID = shareService.create(
			authContext = variables.authContext,
			poemID = poemID,
			name = "Viewed Share",
			noteMarkdown = "",
			isSnapshot = false
		);

		shareService.logShareViewing( shareID );

		var share = shareModel.get( shareID );
		assertEqual( share.viewingCount, 1 );
		assertTrue( isDate( share.lastViewingAt ), "Expected lastViewingAt to be set." );

		var viewings = viewingModel.getByFilter( poemID = poemID, shareID = shareID );
		assertEqual( viewings.len(), 1, "Expected one viewing record." );

	}

	// ---
	// SAD PATH TESTS.
	// ---

	/**
	* I test that creating a share with invalid input throws a validation error.
	*/
	public void function testCreateWithInvalidInputThrows() {

		var poemID = createPoem( "Invalid Share Poem" );

		// Name too long.
		assertThrows(
			() => {

				shareService.create(
					authContext = variables.authContext,
					poemID = poemID,
					name = repeatString( "x", 51 ),
					noteMarkdown = "",
					isSnapshot = false
				);

			},
			"App.Model.Poem.Share.Name.TooLong"
		);

		// Suspicious encoding in name.
		assertThrows(
			() => {

				shareService.create(
					authContext = variables.authContext,
					poemID = poemID,
					name = "Test %2525 Encoded",
					noteMarkdown = "",
					isSnapshot = false
				);

			},
			"App.Model.Poem.Share.Name.SuspiciousEncoding"
		);

		// Note markdown too long.
		assertThrows(
			() => {

				shareService.create(
					authContext = variables.authContext,
					poemID = poemID,
					name = "Valid",
					noteMarkdown = repeatString( "x", 501 ),
					isSnapshot = false
				);

			},
			"App.Model.Poem.Share.NoteMarkdown.TooLong"
		);

		// Suspicious encoding in note markdown.
		assertThrows(
			() => {

				shareService.create(
					authContext = variables.authContext,
					poemID = poemID,
					name = "Valid",
					noteMarkdown = "Test %2525 Encoded",
					isSnapshot = false
				);

			},
			"App.Model.Poem.Share.NoteMarkdown.SuspiciousEncoding"
		);

	}


	/**
	* I test that creating a share with unsafe HTML tags in note markdown throws a
	* validation error.
	*/
	public void function testUnsafeNoteMarkdownThrows() {

		var poemID = createPoem( "Unsafe Note Poem" );

		assertThrows(
			() => {

				shareService.create(
					authContext = variables.authContext,
					poemID = poemID,
					name = "Valid",
					noteMarkdown = "<div>unsafe block</div>",
					isSnapshot = false
				);

			},
			"App.Model.Poem.Share.NoteMarkdown.Unsafe"
		);

	}


	/**
	* I test that accessing another user's share throws a not-found error.
	*/
	public void function testOtherUserShareThrowsNotFound() {

		var otherAuthContext = provisionAuthContext();

		var otherPoemID = poemService.create(
			authContext = otherAuthContext,
			userID = otherAuthContext.user.id,
			collectionID = 0,
			name = "Other Poem #createUUID()#",
			content = "Content."
		);

		var otherShareID = shareService.create(
			authContext = otherAuthContext,
			poemID = otherPoemID,
			name = "Other Share",
			noteMarkdown = "",
			isSnapshot = false
		);

		// Update by another user.
		assertThrows(
			() => {

				shareService.update(
					authContext = variables.authContext,
					id = otherShareID,
					name = "Hacked",
					noteMarkdown = "",
					isSnapshot = false
				);

			},
			"App.Model.Poem.Share.NotFound"
		);

		// Delete by another user.
		assertThrows(
			() => {

				shareService.delete(
					authContext = variables.authContext,
					id = otherShareID
				);

			},
			"App.Model.Poem.Share.NotFound"
		);

		// Create on another user's poem.
		assertThrows(
			() => {

				shareService.create(
					authContext = variables.authContext,
					poemID = otherPoemID,
					name = "Hacked Share",
					noteMarkdown = "",
					isSnapshot = false
				);

			},
			"App.Model.Poem.Share.Forbidden"
		);

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I create a poem for the current auth context and return its ID.
	*/
	private numeric function createPoem( required string name ) {

		return poemService.create(
			authContext = variables.authContext,
			userID = variables.authContext.user.id,
			collectionID = 0,
			name = "#name# #createUUID()#",
			content = "Test content."
		);

	}

}
