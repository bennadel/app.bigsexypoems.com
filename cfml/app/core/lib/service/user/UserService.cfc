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

		transaction {

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
