component {

	// Define properties for dependency-injection.
	property name="collectionAccess" ioc:type="core.lib.service.collection.CollectionAccess";
	property name="poemAccess" ioc:type="core.lib.service.poem.PoemAccess";
	property name="poemCascade" ioc:type="core.lib.service.poem.PoemCascade";
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";
	property name="poemValidation" ioc:type="core.lib.model.poem.PoemValidation";
	property name="tagAccess" ioc:type="core.lib.service.tag.TagAccess";
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
		required numeric collectionID,
		required numeric tagID,
		required string name,
		required string content
		) {

		var context = poemAccess.getContextForParent( authContext, userID, "canCreateAny" );
		var user = context.user;

		testCollectionID( authContext, userID, collectionID );
		testTagID( authContext, userID, tagID );

		var poemID = poemModel.create(
			userID = user.id,
			collectionID = collectionID,
			tagID = tagID,
			name = name,
			content = content,
			createdAt = utcNow()
		);

		return poemID;

	}


	/**
	* I delete the given poem.
	*/
	public void function deletePoem(
		required struct authContext,
		required numeric id
		) {

		var context = poemAccess.getContext( authContext, id, "canDelete" );
		var user = context.user;
		var poem = context.poem;

		poemCascade.deletePoem( user, poem );

	}


	/**
	* I update the given poem.
	*/
	public void function updatePoem(
		required struct authContext,
		required numeric id,
		numeric collectionID,
		numeric tagID,
		string name,
		string content
		) {

		var context = poemAccess.getContext( authContext, id, "canUpdate" );
		var poem = context.poem;

		testCollectionID( authContext, poem.userID, arguments?.collectionID );
		testTagID( authContext, poem.userID, arguments?.tagID );

		poemModel.update(
			id = poem.id,
			collectionID = arguments?.collectionID,
			tagID = arguments?.tagID,
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
