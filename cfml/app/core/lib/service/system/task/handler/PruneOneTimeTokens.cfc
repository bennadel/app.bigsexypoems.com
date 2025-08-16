component {

	// Define properties for dependency-injection.
	property name="clock" ioc:type="core.lib.util.Clock";
	property name="oneTimeTokenModel" ioc:type="core.lib.model.oneTimeToken.OneTimeTokenModel";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I handle the scheduled task execution.
	*/
	public struct function executeTask() {

		var expiresAt = clock.utcNow();
		var tokens = oneTimeTokenModel.getByFilter( expiresAtBefore = expiresAt );

		for ( var token in tokens ) {

			oneTimeTokenModel.deleteByFilter( id = token.id );

		}

		return {
			expiredCount: tokens.len()
		};

	}

}
