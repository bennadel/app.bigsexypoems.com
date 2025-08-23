component {

	// Define properties for dependency-injection.
	property name="authenticationEmailer" ioc:type="core.lib.service.authentication.AuthenticationEmailer";
	property name="authenticationUrlSigner" ioc:type="core.lib.service.authentication.AuthenticationUrlSigner";
	property name="clock" ioc:type="core.lib.util.Clock";
	property name="isLive" ioc:get="config.isLive";
	property name="logger" ioc:type="core.lib.util.Logger";
	property name="oneTimeTokens" ioc:type="core.lib.util.OneTimeTokens";
	property name="rateLimitService" ioc:type="core.lib.util.RateLimitService";
	property name="requestMetadata" ioc:type="core.lib.web.RequestMetadata";
	property name="router" ioc:type="core.lib.web.Router";
	property name="secureRandom" ioc:type="core.lib.util.SecureRandom";
	property name="site" ioc:get="config.site";
	property name="userModel" ioc:type="core.lib.model.user.UserModel";
	property name="userProvisioner" ioc:type="core.lib.service.user.UserProvisioner";
	property name="userValidation" ioc:type="core.lib.model.user.UserValidation";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I identify the given email. This will create a new user if the email is not
	* recognized. The user ID is returned.
	*/
	public numeric function identify(
		required string name,
		required string email,
		required numeric offsetInMinutes
		) {

		return userProvisioner.ensureUser(
			name = name,
			email = email,
			offsetInMinutes = offsetInMinutes
		);

	}


	/**
	* I initiate a magic link workflow for the given email.
	*/
	public void function requestMagicLink(
		required string email,
		numeric offsetInMinutes = 0,
		string redirectTo = ""
		) {

		var ipAddress = requestMetadata.getIpAddress();

		// TEMPORARY: Long term, I don't need to be logging this information; however,
		// while we're still getting things up-and-running, I want to have my finger on
		// the pulse so I can get a sense of whether or not this feature is being abused.
		logger.info(
			"Magic link workflow requested.",
			{
				email: email,
				ipAddress: ipAddress
			}
		);

		email = userValidation.testEmail( email );

		// Since we're going to redirect the user after the login, we want to make very
		// sure that we don't accidentally redirect them to an external / malicious site.
		if ( ! router.isInternalUrl( redirectTo ) ) {

			redirectTo = "/";

		}

		// Since this login workflow is the most likely area of the application to be
		// misused as a malicious attack vector (it sends out an email to an arbitrary
		// address), I want to try and lock it down in a variety of ways. But, I don't
		// want to negatively impact a user that has already signed-up. As such, we're
		// going to have different rate-limiting characteristics for a known user vs. a
		// new user.
		var maybeUser = userModel.maybeGetByFilter( email = email );

		// KNOWN USER rate-limiting.
		if ( maybeUser.exists ) {

			rateLimitService.testRequest( "login-request-by-known-email", email );

		// NEW USER rate-limiting.
		} else {

			rateLimitService.testRequest( "login-request-by-app", "app" );
			rateLimitService.testRequest( "login-request-by-ip", ipAddress );
			rateLimitService.testRequest( "login-request-by-unknown-email", email );

		}

		// Note: the expiration of the one-time token will IMPLICITLY create an overall
		// expiration for the login URL itself.
		var expiresInMinutes = 30;
		var salt = secureRandom.getToken( 16 );
		var token = oneTimeTokens.createToken( expiresInMinutes, email, salt );
		var signature = authenticationUrlSigner.generateSignature(
			email = email,
			offsetInMinutes = offsetInMinutes,
			redirectTo = redirectTo,
			token = token,
			salt = salt
		);
		var loginUrl = router.externalUrlFor([
			event: "auth.login.verify",
			email: email,
			offsetInMinutes: offsetInMinutes,
			redirectTo: redirectTo,
			token: token,
			signature: signature
		]);

		// In order to make local development less tedious, I'm going to output the login
		// URL directly in the "sent" page.
		if ( ! isLive ) {

			cookie.loginUrlForLocalDevelopment = {
				value: loginUrl,
				encodeValue: true,
				httpOnly: true,
				secure: false,
				sameSite: "lax",
				preserveCase: true
			};

		}

		// In order to differentiate one subject line from the next (to prevent grouping
		// in email clients such as Gmail), let's include the expiration date in the
		// subject. This isn't a fool-proof plan; but, will likely create a unique subject
		// between two subsequent login requests for the same user.
		var expiresAt = clock.utcNow()
			.add( "n", offsetInMinutes )
			.add( "n", expiresInMinutes )
		;
		var expiresAtString = dateTimeFormat( expiresAt, "h:nn TT '('mmm d')'" );

		authenticationEmailer.sendMagicLink(
			email = email,
			subject = "Log into #site.name# - Expires at #expiresAtString#",
			loginUrl = loginUrl,
			loginExpiration = "#expiresInMinutes# minutes"
		);

	}


	/**
	* I verify the magic link for the given email. This will create a new user account if
	* the email is not recognized. The verified user ID is returned.
	*/
	public numeric function verifyMagicLink(
		required string email,
		required numeric offsetInMinutes,
		required string redirectTo,
		required string token,
		required string signature
		) {

		// Since this login workflow is the most likely point of attack on the system, we
		// want to limit a malicious actor from pounding the server with guesses.
		rateLimitService.testRequest( "login-verify-by-email", email );

		var maybeToken = oneTimeTokens.maybeGetToken( token, email );

		if ( ! maybeToken.exists ) {

			throw(
				type = "App.Authentication.VerifyLogin.Expired",
				message = "Login verification token has expired."
			);

		}

		var salt = maybeToken.value.value;

		authenticationUrlSigner.testSignature(
			email = email,
			offsetInMinutes = offsetInMinutes,
			redirectTo = redirectTo,
			token = token,
			salt = salt,
			signature = signature
		);

		return userProvisioner.ensureUserAccount(
			email = email,
			offsetInMinutes = offsetInMinutes
		);

	}

}
