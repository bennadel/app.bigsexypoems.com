component output = false {

	// Define properties for dependency-injection.
	property name="gateway" ioc:type="client.account.session.list.ListGateway";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I get the primary data for the partial.
	*/
	public struct function getPrimary( required struct authContext ) {

		var sessions = getSessions(
			userID = authContext.user.id,
			sessionID = authContext.session.id
		);

		return {
			sessions: sessions
		};

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I get the active sessions for the given user.
	*/
	private array function getSessions(
		required numeric userID,
		required numeric sessionID
		) {

		var sessions = gateway.getSessions( userID );

		for ( var entry in sessions ) {

			entry.isCurrent = ( entry.id == sessionID );

		}

		return sessions;

	}

}
