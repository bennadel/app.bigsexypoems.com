<cfscript>

	config = request.ioc.get( "config" );
	requestMetadata = request.ioc.get( "core.lib.web.RequestMetadata" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// ONLY SHOW IN THE LOCAL DEVELOPMENT ENVIRONMENT.
	if ( config.isLive ) {

		exit;

	}

	error = ( request.error ?: "" );
	urlWithInit = getInitUrl();
	slug = generateSlug();

	include "./localDevelopment.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I generate a slug to be used with the emulated encapsulation. The slug will always
	* start with a letter so that it can be used as a JavaScript variable.
	*/
	private string function generateSlug( numeric length = 6 ) {

		var letters = "abcdefghijklmnopqrstuvwxyz";
		var numbers = "0123456789";
		var both = "#letters##numbers#";

		// Always start with a letter.
		var chars = [ letters[ randRange( 1, letters.len(), "sha1prng" ) ] ];

		while ( chars.len() < length ) {

			chars.append( both[ randRange( 1, both.len(), "sha1prng" ) ] );

		}

		return chars.toList( "" );

	}


	/**
	* I return the URL that will re-init the application and bring the user back to the
	* same/current page.
	*/
	private string function getInitUrl() {

		var currentUrl = requestMetadata.getUrl();
		var flag = "init=#encodeForUrl( config.initPassword )#";
		var flagPattern = "[?&]init=";

		// If query-string already contains init flag, just return as-is.
		if ( currentUrl.reFind( flagPattern ) ) {

			return currentUrl;

		}

		return currentUrl.find( "?" )
			? "#currentUrl#&#flag#"
			: "#currentUrl#?#flag#"
		;

	}

</cfscript>
