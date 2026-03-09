component extends="spec.BaseTest" {

	// Define properties for dependency-injection.
	property name="userModel" ioc:type="core.lib.model.user.UserModel";
	property name="userService" ioc:type="core.lib.service.user.UserService";

	// ---
	// HAPPY PATH TESTS.
	// ---

	/**
	* I test that updating a user persists the new name.
	*/
	public void function testUpdate() {

		var newName = "Updated #left( createUUID(), 8 )#";

		userService.update(
			authContext = variables.authContext,
			id = variables.authContext.user.id,
			name = newName
		);

		var user = userModel.get( variables.authContext.user.id );
		assertEqual( user.name, newName );

	}


	/**
	* I test that deleting a user removes the user record.
	*/
	public void function testDelete() {

		// Provision a dedicated auth context for deletion so we don't destroy the
		// shared test user that the rest of the suite depends on.
		var deleteAuthContext = provisionAuthContext();

		userService.delete(
			authContext = deleteAuthContext,
			id = deleteAuthContext.user.id
		);

		assertThrows(
			() => {

				userModel.get( deleteAuthContext.user.id );

			},
			"App.Model.User.NotFound"
		);

	}

	// ---
	// SAD PATH TESTS.
	// ---

	/**
	* I test that updating a user with invalid input throws a validation error.
	*/
	public void function testUpdateWithInvalidInputThrows() {

		// Empty name.
		assertThrows(
			() => {

				userService.update(
					authContext = variables.authContext,
					id = variables.authContext.user.id,
					name = ""
				);

			},
			"App.Model.User.Name.Empty"
		);

		// Name too long.
		assertThrows(
			() => {

				userService.update(
					authContext = variables.authContext,
					id = variables.authContext.user.id,
					name = repeatString( "x", 51 )
				);

			},
			"App.Model.User.Name.TooLong"
		);

		// Suspicious encoding in name.
		assertThrows(
			() => {

				userService.update(
					authContext = variables.authContext,
					id = variables.authContext.user.id,
					name = "Test %2525 Encoded"
				);

			},
			"App.Model.User.Name.SuspiciousEncoding"
		);

	}


	/**
	* I test that updating or deleting another user's account throws a not-found error.
	*/
	public void function testOtherUserThrowsNotFound() {

		var otherAuthContext = provisionAuthContext();

		// Update.
		assertThrows(
			() => {

				userService.update(
					authContext = variables.authContext,
					id = otherAuthContext.user.id,
					name = "Hacked"
				);

			},
			"App.Model.User.NotFound"
		);

		// Delete.
		assertThrows(
			() => {

				userService.delete(
					authContext = variables.authContext,
					id = otherAuthContext.user.id
				);

			},
			"App.Model.User.NotFound"
		);

	}

}
