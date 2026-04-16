component {

	// Define properties for dependency-injection.
	property name="userAccess" ioc:type="core.lib.service.user.UserAccess";
	property name="userCascade" ioc:type="core.lib.service.user.UserCascade";
	property name="userModel" ioc:type="core.lib.model.user.UserModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I delete the given user and all associated data.
	*/
	public void function delete(
		required struct authContext,
		required numeric id
		) {

		var context = userAccess.getContext( authContext, id, "canDelete" );
		var user = context.user;

		// Cascading deletion is initiated by the service layer but is treated as a black
		// box. Which means that we always execute it inside a transaction and we always
		// obtain exclusive locks on the rows that we're passing out-of-scope. The
		// transaction allows for atomic operations (which are very much needed in some
		// places and completely overkill in other places); and the transaction-based
		// locking allows for serialized access to rows that other workflows may be
		// locking concurrently. All locking must be performed from the "parent down" in
		// order to avoid deadlocks.
		transaction {

			// Re-fetch data with locks.
			var userWithLock = userModel.get(
				id = user.id,
				withLock = "exclusive"
			);

			userCascade.delete( userWithLock );

		}

	}


	/**
	* I update the given user.
	*/
	public void function update(
		required struct authContext,
		required numeric id,
		required string name
		) {

		var context = userAccess.getContext( authContext, id, "canUpdate" );
		var user = context.user;

		// Idea: for updating email address, we'll want to go through an email validation
		// workflow.

		userModel.update(
			id = user.id,
			name = name
		);

	}

}
