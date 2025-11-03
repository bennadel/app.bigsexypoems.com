component {

	// Define properties for dependency-injection.
	property name="userAccess" ioc:type="core.lib.service.user.UserAccess";
	property name="userModel" ioc:type="core.lib.model.user.UserModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

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
