component {

	// Define properties for dependency-injection.
	property name="oneTimeTokenModel" ioc:type="core.lib.model.oneTimeToken.OneTimeTokenModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I handle the scheduled task execution.
	*/
	public struct function executeTask() {

		var expiresAt = utcNow();
		var tokens = oneTimeTokenModel.getByFilter( expiresAtBefore = expiresAt );

		for ( var token in tokens ) {

			oneTimeTokenModel.deleteByFilter( id = token.id );

		}

		return {
			expiredCount: tokens.len()
		};

	}

}
