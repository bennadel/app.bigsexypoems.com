component {

	// Define properties for dependency-injection.
	property name="rateLimitService" ioc:type="core.lib.util.RateLimitService";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

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
