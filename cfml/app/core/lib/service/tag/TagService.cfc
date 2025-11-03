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
	public numeric function create(
		required struct authContext,
		required numeric userID,
		required string name,
		required string slug,
		required string fillHex,
		required string textHex
		) {

		var context = tagAccess.getContextForParent( authContext, userID, "canCreateAny" );
		var user = context.user;

		var tagID = tagModel.create(
			userID = user.id,
			name = name,
			slug = slug,
			fillHex = fillHex,
			textHex = textHex,
			createdAt = utcNow()
		);

		return tagID;

	}


	/**
	* I delete the given tag.
	*/
	public void function delete(
		required struct authContext,
		required numeric id
		) {

		var context = tagAccess.getContext( authContext, id, "canDelete" );
		var user = context.user;
		var tag = context.tag;

		tagCascade.delete( user, tag );

	}


	/**
	* I update the given tag.
	*/
	public void function update(
		required struct authContext,
		required numeric id,
		string name,
		string slug,
		string fillHex,
		string textHex
		) {

		var context = tagAccess.getContext( authContext, id, "canUpdate" );
		var tag = context.tag;

		tagModel.update(
			id = tag.id,
			name = arguments?.name,
			slug = arguments?.slug,
			fillHex = arguments?.fillHex,
			textHex = arguments?.textHex,
			updatedAt = utcNow()
		);

	}

}
