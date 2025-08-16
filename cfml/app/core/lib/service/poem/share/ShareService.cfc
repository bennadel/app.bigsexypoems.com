component {

	// Define properties for dependency-injection.
	property name="clock" ioc:type="core.lib.util.Clock";
	property name="secureRandom" ioc:type="core.lib.util.SecureRandom";
	property name="shareAccess" ioc:type="core.lib.service.poem.share.ShareAccess";
	property name="shareModel" ioc:type="core.lib.model.poem.share.ShareModel";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create a share.
	*/
	public numeric function createShare(
		required struct authContext,
		required numeric poemID
		) {

		var context = shareAccess.getContextForParent( authContext, poemID, "canCreateAny" );
		var poem = context.poem;
		var token = secureRandom.getToken( 32 );
		var createdAt = clock.utcNow();

		var shareID = shareModel.create(
			poemID = poem.id,
			token = token,
			createdAt = createdAt
		);

		return shareID;

	}


	/**
	* I delete a share.
	*/
	public void function deleteShare(
		required struct authContext,
		required numeric shareID
		) {

		var context = shareAccess.getContext( authContext, shareID, "canDelete" );
		var share = context.share;

		shareModel.deleteByFilter( id = share.id );

	}


	/**
	* I delete all the share for the given poem.
	*/
	public void function deleteSharesForPoem(
		required struct authContext,
		required numeric poemID
		) {

		var context = shareAccess.getContextForParent( authContext, poemID, "canDelete" );
		var poem = context.poem;

		shareModel.deleteByFilter( poemID = poem.id );

	}

}
