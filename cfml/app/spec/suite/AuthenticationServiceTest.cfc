component extends="spec.BaseTest" {

	// Define properties for dependency-injection.
	property name="authenticationService" ioc:type="core.lib.service.authentication.AuthenticationService";
	property name="userModel" ioc:type="core.lib.model.user.UserModel";

	// ---
	// HAPPY PATH TESTS.
	// ---

	/**
	* I test that identify creates a new user for an unknown email and returns the same
	* user ID for a known email.
	*/
	public void function testIdentify() {

		var email = uniqueEmail();
		var userID = authenticationService.identify(
			name = "Test User",
			email = email,
			offsetInMinutes = 0
		);

		assertTrue( userID, "Expected a valid user ID." );

		var user = userModel.get( userID );
		assertEqual( user.email, email );
		assertEqual( user.name, "Test User" );

		// Calling identify again with the same email returns the same user.
		var sameUserID = authenticationService.identify(
			name = "Different Name",
			email = email,
			offsetInMinutes = 0
		);

		assertEqual( sameUserID, userID, "Expected same user ID for same email." );

	}


	/**
	* I test that createMagicLink generates a valid link and that verifyMagicLink
	* completes the round-trip, creating a user account.
	*/
	public void function testCreateAndVerifyMagicLink() {

		var email = uniqueEmail();
		var magicLink = authenticationService.createMagicLink(
			email = email,
			offsetInMinutes = 0,
			redirectTo = "/"
		);

		assertTrue( magicLink.signedUrl.len(), "Expected a non-empty signed URL." );
		assertTrue( magicLink.token.len(), "Expected a non-empty token." );
		assertTrue( magicLink.signature.len(), "Expected a non-empty signature." );

		var userID = authenticationService.verifyMagicLink(
			email = magicLink.email,
			offsetInMinutes = magicLink.offsetInMinutes,
			redirectTo = magicLink.redirectTo,
			token = magicLink.token,
			signature = magicLink.signature
		);

		assertTrue( userID, "Expected a valid user ID." );

		var user = userModel.get( userID );
		assertEqual( user.email, email );

	}


	/**
	* I test that requestMagicLink completes without error for a valid email.
	*/
	public void function testRequestMagicLink() {

		authenticationService.requestMagicLink(
			email = uniqueEmail(),
			offsetInMinutes = 0,
			redirectTo = "/"
		);

		// If we get here without error, the magic link was requested successfully
		// (email sent, token created, no rate limit hit).
		assertTrue( true );

	}

	// ---
	// SAD PATH TESTS.
	// ---

	/**
	* I test that requestMagicLink throws validation errors for invalid emails.
	*/
	public void function testRequestMagicLinkWithInvalidEmailThrows() {

		// Empty email.
		assertThrows(
			() => {

				authenticationService.requestMagicLink( email = "" );

			},
			"App.Model.User.Email.Empty"
		);

		// Email too long.
		assertThrows(
			() => {

				authenticationService.requestMagicLink(
					email = repeatString( "x", 70 ) & "@test.com"
				);

			},
			"App.Model.User.Email.TooLong"
		);

		// Invalid format.
		assertThrows(
			() => {

				authenticationService.requestMagicLink( email = "not-an-email" );

			},
			"App.Model.User.Email.Invalid"
		);

		// Example domain.
		assertThrows(
			() => {

				authenticationService.requestMagicLink( email = "test@example.com" );

			},
			"App.Model.User.Email.Example"
		);

		// Suspicious encoding.
		assertThrows(
			() => {

				authenticationService.requestMagicLink(
					email = "test%2525@bennadel.com"
				);

			},
			"App.Model.User.Email.SuspiciousEncoding"
		);

	}


	/**
	* I test that verifyMagicLink throws an expired error when the token does not exist.
	*/
	public void function testVerifyMagicLinkWithExpiredTokenThrows() {

		assertThrows(
			() => {

				authenticationService.verifyMagicLink(
					email = uniqueEmail(),
					offsetInMinutes = 0,
					redirectTo = "/",
					token = "0.nonexistent-token-slug",
					signature = "invalid-signature"
				);

			},
			"App.Authentication.VerifyLogin.Expired"
		);

	}


	/**
	* I test that verifyMagicLink throws when the signature has been tampered with.
	*/
	public void function testVerifyMagicLinkWithTamperedSignatureThrows() {

		var magicLink = authenticationService.createMagicLink(
			email = uniqueEmail(),
			offsetInMinutes = 0,
			redirectTo = "/"
		);

		assertThrows(
			() => {

				authenticationService.verifyMagicLink(
					email = magicLink.email,
					offsetInMinutes = magicLink.offsetInMinutes,
					redirectTo = magicLink.redirectTo,
					token = magicLink.token,
					signature = "tampered-signature"
				);

			},
			"App.Url.SignatureMismatch"
		);

	}

}
