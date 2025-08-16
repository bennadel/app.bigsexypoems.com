component
	output = false
	hint = "I provide methods for rate-limiting around a given property."
	{

	/**
	* I initialize the rate limiting with the given configurations.
	*/
	public void function init() {

		variables.ONE_MINUTE = ( 60 * 1000 );
		variables.ONE_HOUR = ( 60 * ONE_MINUTE );

		// Features hold the settings for the workflows being rate-limited.
		variables.features = {
			"login-request-by-app": createSettings( 3, ONE_MINUTE ),
			"login-request-by-known-email": createSettings( 2, ONE_MINUTE ),
			"login-request-by-unknown-email": createSettings( 1, ONE_MINUTE ),
			"login-request-by-ip": createSettings( 1, ONE_MINUTE ),
			"login-verify-by-email": createSettings( 10, ONE_MINUTE ),
			"poem-share-by-ip": createSettings( 10, ONE_MINUTE )
		};
		// Windows hold specific instances of a feature being rate-limited for a specific
		// window ID (ie, the user/client/thing uniquely identifying the request).
		variables.windows = [:];

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I purge expired rate limit windows.
	* 
	* NOTE: This whole concept can be replaced eventually if we move these keys into a
	* volatile store like Redis.
	*/
	public void function purgeExpiredWindows() {

		lock
			name = "RateLimitService.PurgeWindows"
			type = "exclusive"
			timeout = 5
			{

			var timestamp = getTickCount();
			var keys = windows.keyArray();

			for ( var key in keys ) {

				if ( windows[ key ].expiresAt <= timestamp ) {

					windows.delete( key );

				}

			}

		} // END: Lock.

	}


	/**
	* I apply the given request against the associated feature window. If the count
	* exceeds the current window, an error is thrown.
	*/
	public struct function testRequest(
		required string featureID,
		required string windowID
		) {

		if ( ! features.keyExists( featureID ) ) {

			throw(
				type = "App.RateLimit.NotFound",
				message = "Rate limit feature not found.",
				detail = "The rate limit service does not have a feature with ID [#featureID#]."
			);

		}

		var feature = features[ featureID ];
		var windowKey = lcase( "#featureID#:#windowID#" );

		lock
			name = "RateLimitService.PurgeWindows"
			type = "readonly"
			timeout = 5
			{

			lock
				name = "RateLimitService.Windows.#windowKey#"
				type = "exclusive"
				timeout = 5
				{

				var timestamp = getTickCount();

				// Ensure that a window exists (and has not expired) for the given key so
				// that we can treat the windows uniformly down below.
				if (
					! windows.keyExists( windowKey ) ||
					( windows[ windowKey ].expiresAt <= timestamp )
					) {

					windows[ windowKey ] = {
						limit: feature.limit,
						expiresAt: ( timestamp + feature.duration ),
						count: 0
					};

				}

				var window = windows[ windowKey ];

				if ( ++window.count > window.limit ) {

					throw(
						type = "App.RateLimit.TooManyRequests",
						message = "Rate limit feature window exceeded.",
						detail = "The rate limit window [#windowKey#] has exceeded [#window.limit#], current count: [#window.count#]."
					);

				}

				return( window.copy() );

			} // END: Key lock.

		} // END: Purge lock.

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I create a settings structure with the given properties.
	*/
	private struct function createSettings(
		required numeric limit,
		required numeric duration
		) {

		return({
			limit: limit,
			duration: duration
		});

	}

}
