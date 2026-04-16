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
	* I delete the given collection and any data that's logically contained under it.
	* 
	* Caution: this method must be called within a transaction block. All withLock usage
	* contained herein will be scoped to said transaction block and will create mutual
	* exclusion with other row-locking workflows. All passed-in entities must be locked.
	*/
	public void function delete(
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
			collectionID = collection.id,
			withLock = "exclusive"
		);

		for ( var poem in poems ) {

			poemModel.update(
				id = poem.id,
				collectionID = 0
			);

		}

	}

}
