component hint = "I provide methods for rate-limiting around a given property." {

	// Define properties for dependency-injection.
	property name="features" ioc:skip;
	property name="windows" ioc:skip;

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the rate limiting with the given configurations.
	*/
	public void function init() {

		// Setup some convenience rate-limit window duration values.
		var ONE_MINUTE = ( 60 * 1000 );
		var FIVE_MINUTES = ( 5 * ONE_MINUTE );
		var TEN_MINUTES = ( 10 * ONE_MINUTE );
		var ONE_HOUR = ( 60 * ONE_MINUTE );

		// Features hold the settings for the workflows being rate-limited.
		variables.features = {
			"login-request-by-app": createSettings( 30, ONE_HOUR ),
			"login-request-by-known-email": createSettings( 3, ONE_MINUTE ),
			"login-request-by-known-email-hourly": createSettings( 5, ONE_HOUR ),
			"login-request-by-unknown-email": createSettings( 2, ONE_HOUR ),
			"login-request-by-ip": createSettings( 3, ONE_MINUTE ),
			"login-verify-by-email": createSettings( 10, ONE_MINUTE ),
			"poem-share-by-ip": createSettings( 20, ONE_MINUTE ),
			"poem-share-og-image-by-app": createSettings( 10, ONE_MINUTE ),
		};
		// Windows hold specific instances of a feature being rate-limited for a specific
		// window ID (ie, the user/client/thing uniquely identifying the request).
		variables.windows = [:];

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I provide a disconnected copy of the underlying rate-limit state FOR DEBUGGING.
	*/
	public struct function getDataForDebugging() {

		// Note: since this is just for debugging, I'm not worrying about synchronization.
		return duplicate( windows );

	}


	/**
	* I purge expired rate limit windows.
	* 
	* Note: This whole concept can be replaced eventually if we move these keys into a
	* volatile store like Redis.
	*/
	public numeric function purgeExpiredWindows() {

		var expiredCount = 0;

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
					expiredCount++;

				}

			}

		} // END: Lock.

		return expiredCount;

	}


	/**
	* I apply the given request against the associated feature window. If the count
	* exceeds the current window, an error is thrown.
	*/
	public struct function testRequest(
		required string featureID,
		string windowID = "app"
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

		// The following is a hacky misuse of locking. Basically, we need to synchronize
		// access to the entire rate limiting service; but, it only needs to be single-
		// threaded when we're purging expired values. As such, we're overloading the
		// notion of a readonly lock to allow concurrent access UNTIL the scheduled task
		// comes through and performs the global purge. Again, this can all be cleaned-up
		// when/if we use something like Redis.
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

				return window.copy();

			} // END: Key lock.

		} // END: Purge lock.

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I create a normalized settings structure with the given properties. This is just a
	* convenience method to make settings easier to define.
	*/
	private struct function createSettings(
		required numeric limit,
		required numeric duration
		) {

		return {
			limit: limit,
			duration: duration
		};

	}

}
