component {

	// Define properties for dependency-injection.
	property name="accountModel" ioc:type="core.lib.model.user.AccountModel";
	property name="collectionCascade" ioc:type="core.lib.service.collection.CollectionCascade";
	property name="collectionModel" ioc:type="core.lib.model.collection.CollectionModel";
	property name="poemCascade" ioc:type="core.lib.service.poem.PoemCascade";
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";
	property name="sessionCascade" ioc:type="core.lib.service.session.SessionCascade";
	property name="sessionModel" ioc:type="core.lib.model.session.SessionModel";
	property name="timezoneModel" ioc:type="core.lib.model.user.TimezoneModel";
	property name="userModel" ioc:type="core.lib.model.user.UserModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I delete the given user and any data contained under it.
	*/
	public void function delete( required struct user ) {

		deletePoems( user );
		deleteCollections( user );
		deleteSessions( user );

		transaction {
			timezoneModel.deleteByFilter( userID = user.id );
			accountModel.deleteByFilter( userID = user.id );
			userModel.deleteByFilter( id = user.id );
		}

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I delete the collections associated with the given user.
	*/
	private void function deleteCollections( required struct user ) {

		var collections = collectionModel.getByFilter( userID = user.id );

		for ( var collection in collections ) {

			collectionCascade.delete( user, collection );

		}

	}


	/**
	* I delete the poems associated with the given user.
	*/
	private void function deletePoems( required struct user ) {

		var poems = poemModel.getByFilter( userID = user.id );

		for ( var poem in poems ) {

			poemCascade.delete( user, poem );

		}

	}


	/**
	* I delete the sessions associated with the given user.
	*/
	private void function deleteSessions( required struct user ) {

		var sessions = sessionModel.getByFilter( userID = user.id );

		for ( var entry in sessions ) {

			sessionCascade.delete( user, entry );

		}

	}

}
