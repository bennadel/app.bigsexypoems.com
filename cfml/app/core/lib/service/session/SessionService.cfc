component hint = "I provide methods for accessing the session associated with the current request." {

	// Define properties for dependency-injection.
	property name="logger" ioc:type="core.lib.util.Logger";
	property name="nullAuthenticationContext" ioc:skip;
	property name="presenceModel" ioc:type="core.lib.model.session.PresenceModel";
	property name="requestMetadata" ioc:type="core.lib.web.RequestMetadata";
	property name="secureRandom" ioc:type="core.lib.util.SecureRandom";
	property name="sessionAccess" ioc:type="core.lib.service.session.SessionAccess";
	property name="sessionCascade" ioc:type="core.lib.service.session.SessionCascade";
	property name="sessionCookies" ioc:type="core.lib.service.session.SessionCookies";
	property name="sessionModel" ioc:type="core.lib.model.session.SessionModel";
	property name="timezoneModel" ioc:type="core.lib.model.user.TimezoneModel";
	property name="userModel" ioc:type="core.lib.model.user.UserModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the session helper.
	*/
	public void function $init() {

		// This will be shared across all unauthorized / unidentified request access.
		// --
		// Note: the isIdentified key is technically not required (any authenticated
		// session will imply an identified user). But, I'm including it with the request
		// in order to create more natural semantics in the calling code.
		variables.nullAuthenticationContext = [
			session: {
				id: 0,
				isIdentified: false,
				isAuthenticated: false
			},
			user: {
				id: 0
			},
			timezone: {
				offsetInMinutes: 0
			}
		];

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create a new session for the given user.
	*/
	public void function create(
		required numeric userID,
		required boolean isAuthenticated
		) {

		var ipAddress = requestMetadata.getIpAddress();
		var sessionToken = secureRandom.getToken( 64 );

		transaction {
			var sessionID = sessionModel.create(
				token = sessionToken,
				userID = userID,
				isAuthenticated = isAuthenticated,
				ipAddress = ipAddress,
				createdAt = utcNow()
			);
			presenceModel.create(
				sessionID = sessionID,
				requestCount = 1,
				lastRequestAt = utcNow()
			);
		}

		sessionCookies.setCookie( sessionID, sessionToken );

	}


	/**
	* I end the all actives sessions for the given user.
	*/
	public void function endAllSessions(
		required struct authContext,
		required numeric userID
		) {

		var context = sessionAccess.getContextForParent( authContext, userID, "canDeleteAny" );
		var user = context.user;
		var sessions = sessionModel.getByFilter( userID = user.id );

		for ( var userSession in sessions ) {

			sessionCascade.delete( user, userSession );

		}

		sessionCookies.deleteCookie();

	}


	/**
	* I end the given session for the given user.
	*/
	public void function endSession(
		required struct authContext,
		required numeric sessionID
		) {

		var context = sessionAccess.getContext( authContext, sessionID, "canDelete" );
		var user = context.user;
		var userSession = context.userSession;

		sessionCascade.delete( user, userSession );

		// If this was the current session, let's also delete the cookies.
		if ( sessionCookies.getCookie().sessionID == sessionID ) {

			sessionCookies.deleteCookie();

		}

	}


	/**
	* I get the authentication context associated with the current request.
	*/
	public struct function getAuthenticationContext() {

		var payload = sessionCookies.getCookie();

		if ( ! payload.sessionID ) {

			return nullAuthenticationContext;

		}

		var maybeSession = sessionModel.maybeGet( payload.sessionID );

		// If there's no session with the given ID, the cookie is invalid.
		if ( ! maybeSession.exists ) {

			sessionCookies.deleteCookie();
			return nullAuthenticationContext;

		}

		// If the session was found but has a mismatching token, it's likely a malicious
		// request containing a tampered-with cookie payload.
		if ( maybeSession.value.token != payload.sessionToken ) {

			logger.warning( "Mismatching session cookie detected." );
			sessionCookies.deleteCookie();
			return nullAuthenticationContext;

		}

		// If we've made it this far, we have a valid session.
		var currentSession = maybeSession.value;
		var user = userModel.get( currentSession.userID );
		var timezone = timezoneModel.get( user.id );

		updateSessionPresenceAsync( currentSession.id );

		return {
			session: {
				id: currentSession.id,
				isIdentified: true,
				isAuthenticated: currentSession.isAuthenticated,
				ipAddress: currentSession.ipAddress,
				createdAt: currentSession.createdAt
			},
			user,
			timezone
		};

	}


	/**
	* I end the current session.
	*/
	public void function logout() {

		var payload = sessionCookies.getAndDeleteCookie();
		var maybeSession = sessionModel.maybeGet( payload.sessionID );

		if ( ! maybeSession.exists ) {

			return;

		}

		// Caution: deleting a session from the database represents a potential attack
		// vector. As such, we only want to delete the database records if the token is
		// a match. This way, if a malicious actor attempts to make requests with a valid
		// session ID but an invalid session TOKEN, we won't let the request affect
		// another user.
		if ( maybeSession.value.token == payload.sessionToken ) {

			var user = userModel.get( maybeSession.value.userID );

			sessionCascade.delete( user, maybeSession.value );

		}

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I update the presence settings for the given session.
	*/
	private void function updateSessionPresenceAsync( required numeric sessionID ) {

		thread
			name = "SessionService.updateSessionPresenceAsync"
			sessionID = sessionID
			{

			try {

				presenceModel.logRequest( sessionID );

			} catch ( any error ) {

				logger.logException( error );

			}

		}

	}

}
