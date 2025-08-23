component {

	// Define properties for dependency-injection.
	property name="presenceModel" ioc:type="core.lib.model.session.PresenceModel";
	property name="sessionModel" ioc:type="core.lib.model.session.SessionModel";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I delete the given session and any data contained under it.
	*/
	public void function deleteSession(
		required struct user,
		required struct entry
		) {

		transaction {
			sessionModel.deleteByFilter( id = entry.id );
			presenceModel.deleteByFilter( sessionID = entry.id );
		}

	}

}
