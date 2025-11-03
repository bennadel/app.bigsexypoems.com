component {

	// Define properties for dependency-injection.
	property name="collectionAccess" ioc:type="core.lib.service.collection.CollectionAccess";
	property name="poemAccess" ioc:type="core.lib.service.poem.PoemAccess";
	property name="poemCascade" ioc:type="core.lib.service.poem.PoemCascade";
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";
	property name="poemValidation" ioc:type="core.lib.model.poem.PoemValidation";
	property name="userModel" ioc:type="core.lib.model.user.UserModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create a new poem.
	*/
	public numeric function create(
		required struct authContext,
		required numeric userID,
		required numeric collectionID,
		required string name,
		required string content
		) {

		var context = poemAccess.getContextForParent( authContext, userID, "canCreateAny" );
		var user = context.user;

		testCollectionID( authContext, userID, collectionID );

		var poemID = poemModel.create(
			userID = user.id,
			collectionID = collectionID,
			name = name,
			content = content,
			createdAt = utcNow()
		);

		return poemID;

	}


	/**
	* I delete the given poem.
	*/
	public void function delete(
		required struct authContext,
		required numeric id
		) {

		var context = poemAccess.getContext( authContext, id, "canDelete" );
		var user = context.user;
		var poem = context.poem;

		poemCascade.delete( user, poem );

	}


	/**
	* I update the given poem.
	*/
	public void function update(
		required struct authContext,
		required numeric id,
		numeric collectionID,
		string name,
		string content
		) {

		var context = poemAccess.getContext( authContext, id, "canUpdate" );
		var poem = context.poem;

		testCollectionID( authContext, poem.userID, arguments?.collectionID );

		poemModel.update(
			id = poem.id,
			collectionID = arguments?.collectionID,
			name = arguments?.name,
			content = arguments?.content,
			updatedAt = utcNow()
		);

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I test that the collection with the given ID exists and that it can be associated
	* with the a poem owned by the given user.
	*/
	private void function testCollectionID(
		required struct authContext,
		required numeric userID,
		numeric collectionID = 0
		) {

		if ( ! collectionID ) {

			return;

		}

		var collection = collectionAccess
			.getContext( authContext, collectionID, "canView" )
			.collection
		;

		if ( collection.userID != userID ) {

			poemValidation.throwForbiddenError();

		}

	}

}
