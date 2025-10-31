component {

	// Define properties for dependency-injection.
	property name="collectionModel" ioc:type="core.lib.model.collection.CollectionModel";
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I cascade delete the given collection.
	*/
	public void function deleteCollection(
		required struct user,
		required struct collection
		) {

		unlinkPoems( user, collection );

		collectionModel.deleteByFilter( id = collection.id );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I break the link between the given collection and poems.
	*/
	private void function unlinkPoems(
		required struct user,
		required struct collection
		) {

		var poems = poemModel.getByFilter(
			userID = user.id,
			collectionID = collection.id
		);

		for ( var poem in poems ) {

			poemModel.deleteByFilter( id = poem.id );

		}

	}

}
