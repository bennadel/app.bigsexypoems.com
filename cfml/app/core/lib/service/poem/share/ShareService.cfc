component {

	// Define properties for dependency-injection.
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";
	property name="requestMetadata" ioc:type="core.lib.web.RequestMetadata";
	property name="secureRandom" ioc:type="core.lib.util.SecureRandom";
	property name="shareAccess" ioc:type="core.lib.service.poem.share.ShareAccess";
	property name="shareCascade" ioc:type="core.lib.service.poem.share.ShareCascade";
	property name="shareModel" ioc:type="core.lib.model.poem.share.ShareModel";
	property name="shareNoteParser" ioc:type="core.lib.model.poem.share.ShareNoteParser";
	property name="shareNoteSanitizer" ioc:type="core.lib.model.poem.share.ShareNoteSanitizer";
	property name="viewingModel" ioc:type="core.lib.model.poem.share.ViewingModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create a share.
	*/
	public numeric function create(
		required struct authContext,
		required numeric poemID,
		required string name,
		required string noteMarkdown
		) {

		var context = shareAccess.getContextForParent( authContext, poemID, "canCreateAny" );
		var poem = context.poem;
		var token = secureRandom.getToken( 32 );
		var noteHtml = parseNoteMarkdown( noteMarkdown );
		var createdAt = utcNow();

		var shareID = shareModel.create(
			poemID = poem.id,
			token = token,
			name = name,
			noteMarkdown = noteMarkdown,
			noteHtml = noteHtml,
			viewingCount = 0,
			lastViewingAt = "",
			createdAt = createdAt,
			updatedAt = createdAt
		);

		return shareID;

	}


	/**
	* I delete a share.
	*/
	public void function delete(
		required struct authContext,
		required numeric id
		) {

		var context = shareAccess.getContext( authContext, id, "canDelete" );
		var user = context.user;
		var poem = context.poem;
		var share = context.share;

		shareCascade.delete( user, poem, share );

	}


	/**
	* I delete all the share for the given poem.
	*/
	public void function deleteForPoem(
		required struct authContext,
		required numeric poemID
		) {

		var context = shareAccess.getContextForParent( authContext, poemID, "canDelete" );
		var user = context.user;
		var poem = context.poem;
		var shares = shareModel.getByFilter( poemID = poem.id );

		for ( var share in shares ) {

			shareCascade.delete( user, poem, share );

		}

	}


	/**
	* I log the unique viewing of the given share link.
	*/
	public void function logShareViewing( required numeric id ) {

		var share = shareModel.get( id );
		var poem = poemModel.get( share.poemID );
		var ipAddress = requestMetadata.getIpAddress();
		// Let's trim the city/region since it doesn't much matter if they get truncated
		// in the database. I'd rather them get truncated than have a user-provided value
		// (more or less) possibly throw an error.
		var ipCity = requestMetadata.getIpCity().left( 50 );
		var ipRegion = requestMetadata.getIpRegion().left( 50 );
		var ipCountry = requestMetadata.getIpCountry();
		var createdAt = utcNow();

		viewingModel.create(
			poemID = poem.id,
			shareID = share.id,
			ipAddress = ipAddress,
			ipCity = ipCity,
			ipRegion = ipRegion,
			ipCountry = ipCountry,
			createdAt = createdAt
		);

		// Recalculate the viewing aggregate.
		var viewingCount = viewingModel.getCountByFilter(
			poemID = poem.id,
			shareID = share.id
		);

		shareModel.update(
			id = share.id,
			viewingCount = viewingCount,
			lastViewingAt = createdAt
		);

	}


	/**
	* I parse the share note markdown into sanitized HTML.
	*/
	public string function parseNoteMarkdown( required string noteMarkdown ) {

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
	public void function update(
		required struct authContext,
		required numeric id,
		required string name,
		required string noteMarkdown
		) {

		var context = shareAccess.getContext( authContext, id, "canUpdate" );
		var share = context.share;
		var noteHtml = parseNoteMarkdown( noteMarkdown );
		var updatedAt = utcNow();

		shareModel.update(
			id = share.id,
			name = name,
			noteMarkdown = noteMarkdown,
			noteHtml = noteHtml,
			updatedAt = updatedAt
		);

	}

}
