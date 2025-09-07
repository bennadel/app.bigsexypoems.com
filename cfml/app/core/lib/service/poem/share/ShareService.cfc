component {

	// Define properties for dependency-injection.
	property name="secureRandom" ioc:type="core.lib.util.SecureRandom";
	property name="shareAccess" ioc:type="core.lib.service.poem.share.ShareAccess";
	property name="shareCascade" ioc:type="core.lib.service.poem.share.ShareCascade";
	property name="shareModel" ioc:type="core.lib.model.poem.share.ShareModel";
	property name="shareNoteParser" ioc:type="core.lib.model.poem.share.ShareNoteParser";
	property name="shareNoteSanitizer" ioc:type="core.lib.model.poem.share.ShareNoteSanitizer";

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
		required string shareName,
		required string shareNoteMarkdown
		) {

		var context = shareAccess.getContextForParent( authContext, poemID, "canCreateAny" );
		var poem = context.poem;
		var token = secureRandom.getToken( 32 );
		var shareNoteHtml = parseShareNote( shareNoteMarkdown );
		var createdAt = utcNow();

		var shareID = shareModel.create(
			poemID = poem.id,
			token = token,
			name = shareName,
			noteMarkdown = shareNoteMarkdown,
			noteHtml = shareNoteHtml,
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


	/**
	* I parse the share note markdown into sanitized HTML.
	*/
	public string function parseShareNote( required string noteMarkdown ) {

		var unsafeHtml = shareNoteParser.parse( noteMarkdown );
		var sanitizedResults = shareNoteSanitizer.sanitize( unsafeHtml );

		// When the HTML is sanitized, untrusted tags and attributes are quietly removed.
		// We can safely ignore the attributes; but, if tags are going to be removed, we
		// need to turn that into an error so that the user understands what is and is not
		// allowed in the markdown.
		if ( sanitizedResults.unsafeMarkup.tags.len() ) {

			shareValidation.throwUnsafeNoteError( sanitizedResults.unsafeMarkup );

		}

		return sanitizedResults.safeHtml;

	}


	/**
	* I update a share.
	*/
	public void function updateShare(
		required struct authContext,
		required numeric shareID,
		required string shareName,
		required string shareNoteMarkdown
		) {

		var context = shareAccess.getContext( authContext, shareID, "canUpdate" );
		var share = context.share;
		var shareNoteHtml = parseShareNote( shareNoteMarkdown );
		var updatedAt = utcNow();

		shareModel.update(
			id = share.id,
			name = shareName,
			noteMarkdown = shareNoteMarkdown,
			noteHtml = shareNoteHtml,
			updatedAt = updatedAt
		);

	}

}
