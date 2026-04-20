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
	property name="shareValidation" ioc:type="core.lib.model.poem.share.ShareValidation";
	property name="userModel" ioc:type="core.lib.model.user.UserModel";
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

		transaction {

			var poemWithLock = poemModel.get(
				id = poem.id,
				withLock = "readonly"
			);

			// Only capture snapshot if enabled.
			if ( isSnapshot ) {

				snapshotName = poemWithLock.name;
				snapshotContent = poemWithLock.content;

			}

			if ( ! name.len() ) {

				name = DEFAULT_SHARE_NAME;

			}

			var shareID = shareModel.create(
				poemID = poemWithLock.id,
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

		}

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

		transaction {

			var userWithLock = userModel.get(
				id = user.id,
				withLock = "readonly"
			);
			var poemWithLock = poemModel.get(
				id = poem.id,
				withLock = "readonly"
			);
			var shareWithLock = shareModel.get(
				id = share.id,
				withLock = "exclusive"
			);

			shareCascade.delete( userWithLock, poemWithLock, shareWithLock );

		}

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

		transaction {

			var userWithLock = userModel.get(
				id = user.id,
				withLock = "readonly"
			);
			var poemWithLock = poemModel.get(
				id = poem.id,
				withLock = "readonly"
			);
			var sharesWithLock = shareModel.getByFilter(
				poemID = poem.id,
				withLock = "exclusive"
			);

			for ( var shareWithLock in sharesWithLock ) {

				shareCascade.delete( userWithLock, poemWithLock, shareWithLock );

			}

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
	* I determine if the snapshot share is stale (ie, the poem has changed since the
	* snapshot was taken).
	*/
	public boolean function isSnapshotStale(
		required struct share,
		required struct poem
		) {

		if ( ! share.isSnapshot ) {

			return false;

		}

		return (
			compare( share.snapshotName, poem.name ) ||
			compare( share.snapshotContent, poem.content )
		);

	}


	/**
	* I log the unique viewing of the given share link.
	*/
	public void function logShareViewing( required numeric id ) {

		var ipAddress = requestMetadata.getIpAddress();
		// Let's trim the city/region since it doesn't much matter if they get truncated
		// in the database. I'd rather them get truncated than have a user-provided value
		// (more or less) possibly throw an error.
		var ipCity = requestMetadata.getIpCity().left( 50 );
		var ipRegion = requestMetadata.getIpRegion().left( 50 );
		var ipCountry = requestMetadata.getIpCountry();
		var createdAt = utcNow();

		transaction {

			// This share model is using an exclusive lock in order to enforce serialized
			// access to the view-count aggregate calculation.
			var shareWithLock = shareModel.get(
				id = id,
				withLock = "exclusive"
			);

			viewingModel.create(
				poemID = shareWithLock.poemID,
				shareID = shareWithLock.id,
				ipAddress = ipAddress,
				ipCity = ipCity,
				ipRegion = ipRegion,
				ipCountry = ipCountry,
				createdAt = createdAt
			);

			// Recalculate the viewing aggregate.
			var viewingCount = viewingModel.getCountByFilter(
				poemID = shareWithLock.poemID,
				shareID = shareWithLock.id
			);

			shareModel.update(
				id = shareWithLock.id,
				viewingCount = viewingCount,
				lastViewingAt = createdAt
			);

		}

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

		transaction {

			var poemWithLock = poemModel.get(
				id = poem.id,
				withLock = "readonly"
			);
			var shareWithLock = shareModel.get(
				id = share.id,
				withLock = "exclusive"
			);

			shareModel.update(
				id = shareWithLock.id,
				snapshotName = poemWithLock.name,
				snapshotContent = poemWithLock.content,
				updatedAt = updatedAt
			);

		}

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

		transaction {

			var poemWithLock = poemModel.get(
				id = poem.id,
				withLock = "readonly"
			);
			var shareWithLock = shareModel.get(
				id = share.id,
				withLock = "exclusive"
			);

			// Only capture snapshot if enabled, otherwise the cached values will be cleared.
			if ( isSnapshot ) {

				snapshotName = poemWithLock.name;
				snapshotContent = poemWithLock.content;

			}

			if ( ! name.len() ) {

				name = DEFAULT_SHARE_NAME;

			}

			shareModel.update(
				id = shareWithLock.id,
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

}
