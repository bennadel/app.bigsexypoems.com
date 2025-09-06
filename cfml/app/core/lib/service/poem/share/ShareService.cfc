component {

	// Define properties for dependency-injection.
	property name="secureRandom" ioc:type="core.lib.util.SecureRandom";
	property name="shareAccess" ioc:type="core.lib.service.poem.share.ShareAccess";
	property name="shareCascade" ioc:type="core.lib.service.poem.share.ShareCascade";
	property name="shareModel" ioc:type="core.lib.model.poem.share.ShareModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create a share.
	*/
	public numeric function createShare(
		required struct authContext,
		required numeric poemID,
		required string shareName
		) {

		var context = shareAccess.getContextForParent( authContext, poemID, "canCreateAny" );
		var poem = context.poem;
		var token = secureRandom.getToken( 32 );
		var createdAt = utcNow();

		var shareID = shareModel.create(
			poemID = poem.id,
			token = token,
			name = shareName,
			noteMarkdown = "",
			noteHtml = "",
			createdAt = createdAt,
			updatedAt = createdAt
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
		var user = context.user;
		var poem = context.poem;
		var share = context.share;

		shareCascade.deleteShare( user, poem, share );

	}


	/**
	* I delete all the share for the given poem.
	*/
	public void function deleteSharesForPoem(
		required struct authContext,
		required numeric poemID
		) {

		var context = shareAccess.getContextForParent( authContext, poemID, "canDelete" );
		var user = context.user;
		var poem = context.poem;
		var shares = shareModel.getByFilter( poemID = poem.id );

		for ( var share in shares ) {

			shareCascade.deleteShare( user, poem, share );

		}

	}

}
