component {

	// Define properties for dependency-injection.
	property name="userAccess" ioc:type="core.lib.service.user.UserAccess";
	property name="userModel" ioc:type="core.lib.model.user.UserModel";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I update the given user.
	*/
	public void function updateUser(
		required struct authContext,
		required numeric userID,
		required string userName
		) {

		var context = userAccess.getContext( authContext, userID, "canUpdate" );
		var user = context.user;

		// Idea: for updating email address, we'll want to go through an email validation
		// workflow.

		userModel.update(
			id = user.id,
			name = userName
		);

	}

}
