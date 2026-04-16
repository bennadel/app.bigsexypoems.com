component {

	// Define properties for dependency-injection.
	property name="presenceModel" ioc:type="core.lib.model.session.PresenceModel";
	property name="sessionModel" ioc:type="core.lib.model.session.SessionModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I delete the given session and any data that's logically contained under it.
	* 
	* Caution: this method must be called within a transaction block. All withLock usage
	* contained herein will be scoped to said transaction block and will create mutual
	* exclusion with other row-locking workflows. All passed-in entities must be locked.
	*/
	public void function delete(
		required struct user,
		required struct entry
		) {

		presenceModel.deleteByFilter( sessionID = entry.id );
		sessionModel.deleteByFilter( id = entry.id );

	}

}
