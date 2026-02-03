component {

	// Define properties for dependency-injection.
	property name="DEFAULT_SHARE_NAME" ioc:skip;
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

	/**
	* I initialize the service.
	*/
	public void function init() {

		variables.DEFAULT_SHARE_NAME = "Unnamed Share";

	}

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
		required string noteMarkdown,
		required boolean isSnapshot
		) {

		var context = shareAccess.getContextForParent( authContext, poemID, "canCreateAny" );
		var poem = context.poem;
		var token = secureRandom.getToken( 32 );
		var noteHtml = parseNoteMarkdown( noteMarkdown );
		var snapshotName = "";
		var snapshotContent = "";
		var createdAt = utcNow();

		// Only capture snapshot if enabled.
		if ( isSnapshot ) {

			snapshotName = poem.name;
			snapshotContent = poem.content;

		}

		if ( ! name.len() ) {

			name = DEFAULT_SHARE_NAME;

		}

		var shareID = shareModel.create(
			poemID = poem.id,
			token = token,
			name = name,
			noteMarkdown = noteMarkdown,
			noteHtml = noteHtml,
			isSnapshot = isSnapshot,
			snapshotName = snapshotName,
			snapshotContent = snapshotContent,
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
	* I generate a thumbprint of the Open Graph image that's based on the rendered parts
	* of the image. This thumbprint allows the Open Graph image URL to change in step with
	* the contents of the poem. The design version (ex, "v1") then allows the URL to
	* change in step with the graphic design of the image.
	*/
	public string function getOpenGraphImageVersion(
		required string poemName,
		required string poemContent,
		required string userName,
		string design = "v1"
		) {

		return hash( design & poemName & poemContent & userName )
			.lcase()
		;

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
	* I refresh the snapshot with the current poem state.
	*/
	public void function refreshSnapshot(
		required struct authContext,
		required numeric id
		) {

		var context = shareAccess.getContext( authContext, id, "canUpdate" );
		var share = context.share;
		var poem = context.poem;
		var updatedAt = utcNow();

		shareModel.update(
			id = share.id,
			snapshotName = poem.name,
			snapshotContent = poem.content,
			updatedAt = updatedAt
		);

	}


	/**
	* I update a share.
	*/
	public void function update(
		required struct authContext,
		required numeric id,
		required string name,
		required string noteMarkdown,
		required boolean isSnapshot
		) {

		var context = shareAccess.getContext( authContext, id, "canUpdate" );
		var share = context.share;
		var poem = context.poem;
		var noteHtml = parseNoteMarkdown( noteMarkdown );
		var snapshotName = "";
		var snapshotContent = "";
		var updatedAt = utcNow();

		// Only capture snapshot if enabled, otherwise the cached values will be cleared.
		if ( isSnapshot ) {

			snapshotName = poem.name;
			snapshotContent = poem.content;

		}

		if ( ! name.len() ) {

			name = DEFAULT_SHARE_NAME;

		}

		shareModel.update(
			id = share.id,
			name = name,
			noteMarkdown = noteMarkdown,
			noteHtml = noteHtml,
			isSnapshot = isSnapshot,
			snapshotName = snapshotName,
			snapshotContent = snapshotContent,
			updatedAt = updatedAt
		);

	}

}
