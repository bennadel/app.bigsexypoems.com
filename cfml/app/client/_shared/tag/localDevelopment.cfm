<cfscript>

	// Define properties for dependency-injection.
	config = request.ioc.get( "config" );
	requestMetadata = request.ioc.get( "core.lib.web.RequestMetadata" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// ONLY SHOW IN THE LOCAL DEVELOPMENT ENVIRONMENT.
	if ( config.isLive ) {

		exit;

	}

	error = getRequestError();
	urlWithInit = getInitUrl();
	slug = generateSlug();

	include "./localDevelopment.view.cfm";
	exit;

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
		var flag = "init=#e4u( config.initPassword )#";
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


	/**
	* I get the (simplified) error object from the request, if available. Otherwise, I
	* return an empty string.
	*/
	private any function getRequestError() {

		if ( isNull( request.error ) ) {

			return "";

		}

		// If there's an error, I'm copying the populated keys into an ordered struct for
		// easier debugging. This is just a visual preference and has no bearing on the
		// functionality of the error.
		var errorLite = [:];
		var keys = [
			"type",
			"message",
			"detail",
			"extendedInfo",
			"errorCode",
			"code",
			"tagContext",
		];

		// Copy over populated keys.
		for ( var key in keys ) {

			var value = ( request.error[ key ] ?: "" );

			if ( isSimpleValue( value ) && ! len( value ) ) {

				continue;

			}

			errorLite[ key ] = value;

		}

		// Strip out noise in tag context.
		errorLite.tagContext = errorLite.tagContext.map(
			( element ) => {

				return [
					template: element.template,
					line: element.line
				];

			}
		);

		return errorLite;

	}

</cfscript>
