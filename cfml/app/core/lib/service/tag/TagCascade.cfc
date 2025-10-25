component {

	// Define properties for dependency-injection.
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";
	property name="tagModel" ioc:type="core.lib.model.tag.TagModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I delete the given tag and any data contained under it.
	*/
	public void function deleteTag(
		required struct user,
		required struct tag
		) {

		unlinkPoems( user, tag );

		tagModel.deleteByFilter( id = tag.id );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I break the link between the given tag and poems.
	*/
	private void function unlinkPoems(
		required struct user,
		required struct tag
		) {

		var poems = poemModel.getByFilter(
			userID = user.id,
			tagID = tag.id
		);

		for ( var poem in poems ) {

			poemModel.deleteByFilter( id = poem.id );

		}

	}

}
