component extends="spec.BaseTest" {

	// Define properties for dependency-injection.
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";
	property name="poemService" ioc:type="core.lib.service.poem.PoemService";
	property name="revisionModel" ioc:type="core.lib.model.poem.RevisionModel";
	property name="revisionService" ioc:type="core.lib.service.poem.RevisionService";

	// ---
	// HAPPY PATH TESTS.
	// ---

	/**
	* I test that deleting a revision removes it.
	*/
	public void function testDelete() {

		var poemID = poemService.create(
			authContext = variables.authContext,
			userID = variables.authContext.user.id,
			collectionID = 0,
			name = "Poem #createUUID()#",
			content = "Content."
		);

		var revisions = revisionModel.getByFilter( poemID = poemID );
		var revisionID = revisions.first().id;

		revisionService.delete(
			authContext = variables.authContext,
			id = revisionID
		);

		var remaining = revisionModel.getByFilter( id = revisionID );
		assertTrue( ! remaining.len(), "Expected revision to be deleted." );

	}


	/**
	* I test that isRevisionStale detects when poem content differs from the revision.
	*/
	public void function testIsRevisionStale() {

		var revision = {
			name: "Original Name",
			content: "Original content."
		};

		// Same content — not stale.
		var matchingPoem = {
			name: "Original Name",
			content: "Original content."
		};
		assertTrue( ! revisionService.isRevisionStale( revision, matchingPoem ), "Expected matching content to not be stale." );

		// Different name — stale.
		var differentNamePoem = {
			name: "Changed Name",
			content: "Original content."
		};
		assertTrue( revisionService.isRevisionStale( revision, differentNamePoem ), "Expected different name to be stale." );

		// Different content — stale.
		var differentContentPoem = {
			name: "Original Name",
			content: "Changed content."
		};
		assertTrue( revisionService.isRevisionStale( revision, differentContentPoem ), "Expected different content to be stale." );

	}


	/**
	* I test that makeCurrent restores a revision as the poem's current content and creates
	* new revision snapshots.
	*/
	public void function testMakeCurrent() {

		var poemID = poemService.create(
			authContext = variables.authContext,
			userID = variables.authContext.user.id,
			collectionID = 0,
			name = "Live #createUUID()#",
			content = "Live content."
		);

		// Create a separate revision with different content to restore from. We do this
		// manually because the PoemService windowing would overwrite the original revision.
		var oldName = "Old #createUUID()#";
		var oldContent = "Old content.";

		var oldRevisionID = revisionModel.create(
			poemID = poemID,
			name = oldName,
			content = oldContent,
			createdAt = utcNow()
		);

		var revisionCountBefore = revisionModel.getByFilter( poemID = poemID ).len();

		// Restore the old revision.
		revisionService.makeCurrent(
			authContext = variables.authContext,
			revisionID = oldRevisionID
		);

		// Verify the poem was restored to the old revision's content.
		var poem = poemModel.get( poemID );
		assertEqual( poem.name, oldName );
		assertEqual( poem.content, oldContent );

		// Verify new revisions were created (snapshot of live state + snapshot of restored
		// state = 2 new revisions).
		var revisionsAfter = revisionModel.getByFilter( poemID = poemID );
		assertEqual( revisionsAfter.len(), ( revisionCountBefore + 2 ), "Expected exactly 2 new revisions (live snapshot + restored snapshot)." );

	}


	/**
	* I test that makeCurrent skips the live-state snapshot when the most recent revision
	* already matches the live poem content.
	*/
	public void function testMakeCurrentSkipsRedundantSnapshot() {

		var poemID = poemService.create(
			authContext = variables.authContext,
			userID = variables.authContext.user.id,
			collectionID = 0,
			name = "Live #createUUID()#",
			content = "Live content."
		);

		// The create call produced a revision that matches the live poem. Now create
		// a second revision with different content to restore from.
		var oldRevisionID = revisionModel.create(
			poemID = poemID,
			name = "Old #createUUID()#",
			content = "Old content.",
			createdAt = utcNow()
		);

		// Restore the old revision — this changes the poem away from the latest revision.
		revisionService.makeCurrent(
			authContext = variables.authContext,
			revisionID = oldRevisionID
		);

		// Now the most recent revision (created by makeCurrent above) matches the live
		// poem. Restoring the old revision again should skip the live-state snapshot
		// because it would be a duplicate of the most recent revision.
		var revisionCountBefore = revisionModel.getByFilter( poemID = poemID ).len();

		revisionService.makeCurrent(
			authContext = variables.authContext,
			revisionID = oldRevisionID
		);

		// Only 1 new revision (the restored snapshot), not 2 — the live-state snapshot
		// was correctly skipped because the most recent revision already matched.
		var revisionsAfter = revisionModel.getByFilter( poemID = poemID );
		assertEqual( revisionsAfter.len(), ( revisionCountBefore + 1 ), "Expected exactly 1 new revision (no redundant live snapshot)." );

	}

	// ---
	// SAD PATH TESTS.
	// ---

	/**
	* I test that accessing another user's revision throws a not-found error.
	*/
	public void function testOtherUserRevisionThrowsNotFound() {

		var otherAuthContext = provisionAuthContext();

		var poemID = poemService.create(
			authContext = otherAuthContext,
			userID = otherAuthContext.user.id,
			collectionID = 0,
			name = "Other Poem #createUUID()#",
			content = "Content."
		);

		var revisions = revisionModel.getByFilter( poemID = poemID );
		var revisionID = revisions.first().id;

		// Delete by another user.
		assertThrows(
			() => {

				revisionService.delete(
					authContext = variables.authContext,
					id = revisionID
				);

			},
			"App.Model.Poem.Revision.NotFound"
		);

		// MakeCurrent by another user.
		assertThrows(
			() => {

				revisionService.makeCurrent(
					authContext = variables.authContext,
					revisionID = revisionID
				);

			},
			"App.Model.Poem.Revision.NotFound"
		);

	}

}
