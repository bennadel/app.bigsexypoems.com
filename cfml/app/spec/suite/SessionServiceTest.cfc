component extends="spec.BaseTest" {

	// Define properties for dependency-injection.
	property name="presenceModel" ioc:type="core.lib.model.session.PresenceModel";
	property name="sessionModel" ioc:type="core.lib.model.session.SessionModel";
	property name="sessionService" ioc:type="core.lib.service.session.SessionService";

	// ---
	// HAPPY PATH TESTS.
	// ---

	/**
	* I test that create persists a session and its presence record, and returns the
	* session ID.
	*/
	public void function testCreate() {

		var sessionID = sessionService.create(
			userID = variables.authContext.user.id,
			isAuthenticated = true
		);

		assertTrue( sessionID, "Expected a valid session ID." );

		var session = sessionModel.get( sessionID );
		assertEqual( session.userID, variables.authContext.user.id );
		assertTrue( session.isAuthenticated, "Expected session to be authenticated." );
		assertTrue( session.token.len(), "Expected a non-empty token." );
		assertTrue( session.ipAddress.len(), "Expected a non-empty IP address." );

		// Verify presence was created as a side effect.
		var presence = presenceModel.get( sessionID );
		assertEqual( presence.sessionID, sessionID );

	}


	/**
	* I test that endSession deletes the session and its presence record.
	*/
	public void function testEndSession() {

		var sessionID = sessionService.create(
			userID = variables.authContext.user.id,
			isAuthenticated = true
		);

		sessionService.endSession(
			authContext = variables.authContext,
			sessionID = sessionID
		);

		// Verify the session and presence are deleted.
		assertThrows(
			() => {

				sessionModel.get( sessionID );

			},
			"App.Model.Session.NotFound"
		);

		assertThrows(
			() => {

				presenceModel.get( sessionID );

			},
			"App.Model.Session.Presence.NotFound"
		);

	}


	/**
	* I test that endAllSessions deletes all sessions for a user and their presence
	* records.
	*/
	public void function testEndAllSessions() {

		var sessionID1 = sessionService.create(
			userID = variables.authContext.user.id,
			isAuthenticated = true
		);
		var sessionID2 = sessionService.create(
			userID = variables.authContext.user.id,
			isAuthenticated = true
		);
		var sessionID3 = sessionService.create(
			userID = variables.authContext.user.id,
			isAuthenticated = true
		);

		// Verify all three sessions exist.
		var sessions = sessionModel.getByFilter( userID = variables.authContext.user.id );
		assertTrue( sessions.len() >= 3, "Expected at least 3 sessions." );

		sessionService.endAllSessions(
			authContext = variables.authContext,
			userID = variables.authContext.user.id
		);

		// Verify all sessions are deleted.
		var remaining = sessionModel.getByFilter( userID = variables.authContext.user.id );
		assertEqual( remaining.len(), 0 );

		// Verify presence records are also deleted.
		assertThrows(
			() => {

				presenceModel.get( sessionID1 );

			},
			"App.Model.Session.Presence.NotFound"
		);

	}

	// ---
	// SAD PATH TESTS.
	// ---

	/**
	* I test that endSession and endAllSessions throw not-found errors when accessed by
	* a different user.
	*/
	public void function testOtherUserSessionThrowsNotFound() {

		var otherAuthContext = provisionAuthContext();
		var sessionID = sessionService.create(
			userID = otherAuthContext.user.id,
			isAuthenticated = true
		);

		// endSession should throw for cross-user access.
		assertThrows(
			() => {

				sessionService.endSession(
					authContext = variables.authContext,
					sessionID = sessionID
				);

			},
			"App.Model.Session.NotFound"
		);

		// endAllSessions should throw for cross-user access.
		assertThrows(
			() => {

				sessionService.endAllSessions(
					authContext = variables.authContext,
					userID = otherAuthContext.user.id
				);

			},
			"App.Model.Session.Forbidden"
		);

	}

}
