component hint="I handle redirects for legacy/retired URL patterns." {

	// Define properties for dependency-injection.
	property name="logger" ioc:type="core.lib.util.Logger";
	property name="router" ioc:type="core.lib.web.Router";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I check the current request for legacy URL patterns and redirect if matched. If no
	* legacy pattern is found, I return without action.
	*/
	public void function handleInvalidEvent( required any error ) {

		switch ( router.getEvent() ) {
			case "playground":
				logger.info( "Legacy redirect: playground" );
				router.goto([
					event: "marketing.playground"
				]);
			break;
		}

	}

}
