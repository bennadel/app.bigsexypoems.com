component {

	// Define properties for dependency-injection.
	property name="accountModel" ioc:type="core.lib.model.user.AccountModel";
	property name="timezoneModel" ioc:type="core.lib.model.user.TimezoneModel";
	property name="userModel" ioc:type="core.lib.model.user.UserModel";
	property name="userValidation" ioc:type="core.lib.model.user.UserValidation";
	property name="utilities" ioc:type="core.lib.util.Utilities";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I ensure the creation of a standalone user.
	*/
	public numeric function ensureUser(
		required string name,
		required string email,
		required numeric offsetInMinutes
		) {

		name = userValidation.testName( name );
		email = userValidation.testEmail( email );

		var maybeUser = userModel.maybeGetByFilter( email = email );

		if ( maybeUser.exists ) {

			var userID = maybeUser.value.id;

		} else {

			var userID = userModel.create(
				name = name,
				email = email
			);

		}

		var maybeTimezone = timezoneModel.maybeGet( userID );

		if ( maybeTimezone.exists ) {

			timezoneModel.update( userID, offsetInMinutes );

		} else {

			timezoneModel.create( userID, offsetInMinutes );

		}

		return userID;

	}


	/**
	* I ensure the creation of a full user account. Any existing standalone user will be
	* upgraded to full account status.
	*/
	public numeric function ensureUserAccount(
		required string email,
		required numeric offsetInMinutes
		) {

		var name = utilities.getNameFromEmail( email );
		var userID = ensureUser( name, email, offsetInMinutes );

		var user = userModel.get( userID );
		var maybeAccount = accountModel.maybeGet( user.id );

		if ( ! maybeAccount.exists ) {

			accountModel.create( user.id );

		}

		return user.id;

	}

}
