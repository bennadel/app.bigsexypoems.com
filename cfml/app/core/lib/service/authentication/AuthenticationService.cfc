component {

	// Define properties for dependency-injection.
	property name="authenticationEmailer" ioc:type="core.lib.service.authentication.AuthenticationEmailer";
	property name="authenticationUrlSigner" ioc:type="core.lib.service.authentication.AuthenticationUrlSigner";
	property name="config" ioc:type="config";
	property name="logger" ioc:type="core.lib.util.Logger";
	property name="oneTimeTokens" ioc:type="core.lib.util.OneTimeTokens";
	property name="rateLimitService" ioc:type="core.lib.util.RateLimitService";
	property name="requestMetadata" ioc:type="core.lib.web.RequestMetadata";
	property name="router" ioc:type="core.lib.web.Router";
	property name="secureRandom" ioc:type="core.lib.util.SecureRandom";
	property name="userModel" ioc:type="core.lib.model.user.UserModel";
	property name="userProvisioner" ioc:type="core.lib.service.user.UserProvisioner";
	property name="userValidation" ioc:type="core.lib.model.user.UserValidation";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

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

		email = userValidation.emailFrom( email );

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
		var ipAddress = requestMetadata.getIpAddress();

		// KNOWN USER rate-limiting.
		if ( maybeUser.exists ) {

			rateLimitService.testRequest( "login-request-by-known-email", email );
			rateLimitService.testRequest( "login-request-by-known-email-hourly", email );

		// NEW USER rate-limiting.
		} else {

			// Rate limit new user emails across ALL users in the entire app.
			rateLimitService.testRequest( "login-request-by-app" );
			// Rate limit new user emails for the given IP address.
			rateLimitService.testRequest( "login-request-by-ip", ipAddress );
			// Rate limit new user emails for the given email address. Note that we're
			// using a canonicalized version of the email for rate-limiting so that we can
			// collapse dynamic emails into a single form. This won't affect the email
			// that's ultimately stored with the user record.
			rateLimitService.testRequest( "login-request-by-unknown-email", canonicalizeEmail( email ) );

		}

		// TEMPORARY: Long term, I don't need to be logging this information; however,
		// while we're still getting things up-and-running, I want to have my finger on
		// the pulse so I can get a sense of whether or not this feature is being abused.
		logger.info(
			"Magic link workflow requested.",
			{
				email,
				ipAddress
			}
		);

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
		if ( ! config.isLive ) {

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
		var expiresAt = utcNow()
			.add( "n", offsetInMinutes )
			.add( "n", expiresInMinutes )
		;
		var expiresAtString = dateTimeFormat( expiresAt, "h:nn TT '('mmm d')'" );

		authenticationEmailer.sendMagicLink(
			email = email,
			subject = "Log into #config.site.name# - Expires at #expiresAtString#",
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
		rateLimitService.testRequest( "login-verify-by-email", canonicalizeEmail( email ) );

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

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I canonicalize the given email address for SECURITY CHECKS ONLY. The return values
	* isn't meant to be persisted (it might not even be valid) - it's only meant to
	* represent the notion of an email address that can be used in course-grain checks
	* like rate-limiting.
	*/
	private string function canonicalizeEmail( required string email ) {

		// Note: the email address has already been validated for basic formatting by the
		// time this method is called. But we're not assuming that here in order to leave
		// it open to moving this method elsewhere later on. Plus, it makes the method
		// easier to reason about when we address it in totality.
		var parts = email
			.lcase()
			.reMatch( "[^@]+" )
		;
		var user = trim( parts[ 1 ] ?: "" );
		var domain = trim( parts[ 2 ] ?: "" );

		user = user
			// GMail uses "plus style" addressing for dynamic emails.
			.listFirst( "+" )
			// Yahoo uses "dash style" addressing for dynamic emails.
			.listFirst( "-" )
			// Remove any non-word characters (including dots which GMail ignores).
			.reReplace( "\W+", "", "all" )
		;

		return "#user#@#domain#";

	}

}
