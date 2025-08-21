component {

	// Define properties for dependency-injection.
	property name="rateLimitService" ioc:type="core.lib.util.RateLimitService";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I handle the scheduled task execution.
	*/
	public struct function executeTask() {

		return {
			expiredCount: rateLimitService.purgeExpiredWindows()
		};

	}

}
