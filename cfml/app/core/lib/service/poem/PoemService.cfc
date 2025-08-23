component {

	// Define properties for dependency-injection.
	property name="poemAccess" ioc:type="core.lib.service.poem.PoemAccess";
	property name="poemCascade" ioc:type="core.lib.service.poem.PoemCascade";
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";
	property name="poemValidation" ioc:type="core.lib.model.poem.PoemValidation";
	property name="userModel" ioc:type="core.lib.model.user.UserModel";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create a new poem.
	*/
	public numeric function createPoem(
		required struct authContext,
		required numeric userID,
		required string poemName,
		required string poemContent
		) {

		var context = poemAccess.getContextForParent( authContext, userID, "canCreateAny" );
		var user = context.user;

		var poemID = poemModel.create(
			userID = user.id,
			name = poemName,
			content = poemContent
		);

		return poemID;

	}


	/**
	* I delete the given poem.
	*/
	public void function deletePoem(
		required struct authContext,
		required numeric poemID
		) {

		var context = poemAccess.getContext( authContext, poemID, "canDelete" );
		var user = context.user;
		var poem = context.poem;

		poemCascade.deletePoem( user, poem );

	}


	/**
	* I update the given poem.
	*/
	public void function updatePoem(
		required struct authContext,
		required numeric poemID,
		required string poemName,
		required string poemContent
		) {

		var context = poemAccess.getContext( authContext, poemID, "canUpdate" );
		var poem = context.poem;

		poemModel.update(
			id = poem.id,
			name = poemName,
			content = poemContent
		);

	}

}
