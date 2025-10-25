component {

	// Define properties for dependency-injection.
	property name="tagAccess" ioc:type="core.lib.service.tag.TagAccess";
	property name="tagCascade" ioc:type="core.lib.service.tag.TagCascade";
	property name="tagModel" ioc:type="core.lib.model.tag.TagModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create a new tag.
	*/
	public numeric function createTag(
		required struct authContext,
		required numeric userID,
		required string tagName,
		required string tagSlug,
		required string tagFillHex,
		required string tagTextHex
		) {

		var context = tagAccess.getContextForParent( authContext, userID, "canCreateAny" );
		var user = context.user;

		var tagID = tagModel.create(
			userID = user.id,
			name = tagName,
			slug = tagSlug,
			fillHex = tagFillHex,
			textHex = tagTextHex,
			createdAt = utcNow()
		);

		return tagID;

	}


	/**
	* I delete the given tag.
	*/
	public void function deleteTag(
		required struct authContext,
		required numeric tagID
		) {

		var context = tagAccess.getContext( authContext, tagID, "canDelete" );
		var user = context.user;
		var tag = context.tag;

		tagCascade.deleteTag( user, tag );

	}


	/**
	* I update the given tag.
	*/
	public void function updateTag(
		required struct authContext,
		required numeric tagID,
		required string tagName,
		required string tagSlug,
		required string tagFillHex,
		required string tagTextHex
		) {

		var context = tagAccess.getContext( authContext, tagID, "canUpdate" );
		var tag = context.tag;

		tagModel.update(
			id = tag.id,
			name = tagName,
			slug = tagSlug,
			fillHex = tagFillHex,
			textHex = tagTextHex,
			updatedAt = utcNow()
		);

	}

}
