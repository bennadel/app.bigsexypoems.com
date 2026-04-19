component {

	// Define properties for dependency-injection.
	property name="accountModel" ioc:type="core.lib.model.user.AccountModel";
	property name="timezoneModel" ioc:type="core.lib.model.user.TimezoneModel";
	property name="userModel" ioc:type="core.lib.model.user.UserModel";
	property name="userValidation" ioc:type="core.lib.model.user.UserValidation";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I ensure the creation of a standalone user.
	* 
	* Caution: this method must be called within a transaction block. All withLock usage
	* contained herein will be scoped to said transaction block and will create mutual
	* exclusion with other row-locking workflows.
	*/
	public numeric function ensureUser(
		required string name,
		required string email,
		required numeric offsetInMinutes
		) {

		name = userValidation.nameFrom( name );
		email = userValidation.emailFrom( email );

		// Note: the maybe* methods never provide any locking, since a non-existent row
		// provides no hook for locking. Instead, this workflow relies on the uniqueness
		// constraints at the database level to ensure "serialization" of access.
		var maybeUser = userModel.maybeGetByFilter( email = email );

		if ( maybeUser.exists ) {

			var userID = maybeUser.value.id;

		} else {

			var userID = userModel.create(
				name = name,
				email = email,
				createdAt = utcNow()
			);

		}

		// Using an exclusive lock to serialize access to aggregate root while we check
		// for a conditionally-existent child relationship.
		var userWithLock = userModel.get(
			id = userID,
			withLock = "exclusive"
		);
		var maybeTimezone = timezoneModel.maybeGet( userWithLock.id );

		if ( maybeTimezone.exists ) {

			timezoneModel.update( userWithLock.id, offsetInMinutes );

		} else {

			timezoneModel.create( userWithLock.id, offsetInMinutes );

		}

		return userWithLock.id;

	}


	/**
	* I ensure the creation of a full user account. Any existing standalone user will be
	* upgraded to full account status.
	* 
	* Caution: this method must be called within a transaction block. All withLock usage
	* contained herein will be scoped to said transaction block and will create mutual
	* exclusion with other row-locking workflows.
	*/
	public numeric function ensureUserAccount(
		required string email,
		required numeric offsetInMinutes
		) {

		var name = getNameFromEmail( email );
		var userID = ensureUser( name, email, offsetInMinutes );

		// Using an exclusive lock to serialize access to aggregate root while we check
		// for a conditionally-existent child relationship.
		var userWithLock = userModel.get(
			id = userID,
			withLock = "exclusive"
		);
		var maybeAccount = accountModel.maybeGet( userWithLock.id );

		if ( ! maybeAccount.exists ) {

			accountModel.create( userWithLock.id, utcNow() );

		}

		return userWithLock.id;

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I extract a temporary name from the given email address.
	*/
	private string function getNameFromEmail(
		required string email,
		string fallbackName = "New User"
		) {

		var name = email
			.listFirst( "@" )
			.reReplace( "[._-]+", " ", "all" )
			.trim()
			.reReplace( "(?:^|\b)(\S)", "\U\1", "all" )
		;

		if ( name.len() ) {

			return name.left( 50 );

		}

		return fallbackName;

	}

}
