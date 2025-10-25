component {

	// Define properties for dependency-injection.
	property name="poemAccess" ioc:type="core.lib.service.poem.PoemAccess";
	property name="poemCascade" ioc:type="core.lib.service.poem.PoemCascade";
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";
	property name="poemValidation" ioc:type="core.lib.model.poem.PoemValidation";
	property name="tagAccess" ioc:type="core.lib.service.tag.TagAccess";
	property name="tagModel" ioc:type="core.lib.model.tag.TagModel";
	property name="userModel" ioc:type="core.lib.model.user.UserModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create a new poem.
	*/
	public numeric function createPoem(
		required struct authContext,
		required numeric userID,
		required numeric poemTagID,
		required string poemName,
		required string poemContent
		) {

		var context = poemAccess.getContextForParent( authContext, userID, "canCreateAny" );
		var user = context.user;

		testTagID( authContext, userID, poemTagID );

		var poemID = poemModel.create(
			userID = user.id,
			tagID = poemTagID,
			name = poemName,
			content = poemContent,
			createdAt = utcNow()
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
		numeric poemTagID,
		string poemName,
		string poemContent
		) {

		var context = poemAccess.getContext( authContext, poemID, "canUpdate" );
		var poem = context.poem;

		testTagID( authContext, poem.userID, arguments?.poemTagID );

		poemModel.update(
			id = poem.id,
			tagID = arguments?.poemTagID,
			name = arguments?.poemName,
			content = arguments?.poemContent,
			updatedAt = utcNow()
		);

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I test that the tag with the given ID exists and that it can be associated with the
	* a poem owned by the given user.
	*/
	private void function testTagID(
		required struct authContext,
		required numeric userID,
		numeric tagID = 0
		) {

		if ( ! tagID ) {

			return;

		}

		var tag = tagAccess
			.getContext( authContext, tagID, "canView" )
			.tag
		;

		if ( tag.userID != userID ) {

			poemValidation.throwForbiddenError();

		}

	}

}
