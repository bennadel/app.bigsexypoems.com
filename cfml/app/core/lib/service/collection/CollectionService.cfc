component {

	// Define properties for dependency-injection.
	property name="collectionAccess" ioc:type="core.lib.service.collection.CollectionAccess";
	property name="collectionCascade" ioc:type="core.lib.service.collection.CollectionCascade";
	property name="collectionDescriptionParser" ioc:type="core.lib.model.collection.CollectionDescriptionParser";
	property name="collectionDescriptionSanitizer" ioc:type="core.lib.model.collection.CollectionDescriptionSanitizer";
	property name="collectionModel" ioc:type="core.lib.model.collection.CollectionModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create a new collection.
	*/
	public numeric function create(
		required struct authContext,
		required numeric userID,
		required string name,
		required string descriptionMarkdown
		) {

		var context = collectionAccess.getContextForParent( authContext, userID, "canCreateAny" );
		var user = context.user;
		var descriptionHtml = parseDescriptionMarkdown( descriptionMarkdown );
		var createdAt = utcNow();

		var id = collectionModel.create(
			userID = user.id,
			name = name,
			descriptionMarkdown = descriptionMarkdown,
			descriptionHtml = descriptionHtml,
			createdAt = utcNow()
		);

		return id;

	}


	/**
	* I delete the given collection.
	*/
	public void function delete(
		required struct authContext,
		required numeric id
		) {

		var context = collectionAccess.getContext( authContext, id, "canDelete" );
		var user = context.user;
		var collection = context.collection;

		collectionCascade.delete( user, collection );

	}


	/**
	* I parse the collection description markdown into sanitized HTML.
	*/
	public string function parseDescriptionMarkdown( required string descriptionMarkdown ) {

		var unsafeHtml = collectionDescriptionParser.parse( descriptionMarkdown );
		var sanitizedResults = collectionDescriptionSanitizer.sanitize( unsafeHtml );

		// When the HTML is sanitized, untrusted tags and attributes are quietly removed.
		// We can safely ignore the attributes; but, if tags are going to be removed, we
		// need to turn that into an error so that the user understands what is and is not
		// allowed in the markdown.
		if ( sanitizedResults.unsafeMarkup.tags.len() ) {

			collectionValidation.throwUnsafeDescriptionError( sanitizedResults.unsafeMarkup );

		}

		return sanitizedResults.safeHtml;

	}


	/**
	* I update the given collection.
	*/
	public void function update(
		required struct authContext,
		required numeric id,
		string name,
		string descriptionMarkdown
		) {

		var context = collectionAccess.getContext( authContext, id, "canUpdate" );
		var collection = context.collection;

		if ( ! isNull( descriptionMarkdown ) ) {

			var descriptionHtml = parseDescriptionMarkdown( descriptionMarkdown );

		}

		collectionModel.update(
			id = collection.id,
			name = arguments?.name,
			descriptionMarkdown = arguments?.descriptionMarkdown,
			descriptionHtml = local?.descriptionHtml,
			updatedAt = utcNow()
		);

	}

}
