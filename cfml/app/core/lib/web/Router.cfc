component {

	// Define properties for dependency-injection.
	property name="requestMetadata" ioc:type="core.lib.web.RequestMetadata";
	property name="site" ioc:get="config.site";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I set up the core request structure used internally by the router.
	*/
	public any function setupRequest( string scriptName = "/index.cfm" ) {

		lock
			type = "exclusive"
			scope = "request"
			timeout = 1
			{

			// If the request has already been configured, throw an error since this is
			// likely a developer mistake that needs to be corrected.
			if ( request.keyExists( "$$routerVariables" ) ) {

				throw(
					type = "App.Conflict",
					message = "You cannot call setupRequest() more than once per request."
				);

			}

			var event = listToArray( url?.event, "." );

			request.$$routerVariables = {
				scriptName: scriptName,
				event: event,
				queue: duplicate( event ),
				currentSegment: "",
				persistedSearchParams: []
			};

			return this;

		}

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I return the post-back value for form action attributes. This URL is encoded and is
	* safe to output to the view without additional encoding.
	*/
	public string function buildPostBackAction() {

		// Some URL parameters are intended to be transient. As such, we don't want them
		// to be persisted in the post-back.
		// --
		// Note: we're parsing the query-string instead of iterating over the URL scope in
		// order to make sure that the order parameters doesn't change. This is strictly
		// for vanity reasons.
		var queryString = requestMetadata.getQueryString()
			.listToArray( "&" )
			.filter(
				( pair ) => {

					// Note: the query-string will contain URL-encoded values. However,
					// since we know that the keys we want to omit contain no special
					// characters, we don't have to bother URL-decoding the key before
					// inspecting it.
					switch ( pair.listFirst( "=" ) ) {
						case "flash":
						case "flashData":
						case "init":
							return false;
						break;
						default:
							return true;
						break;
					}

				}
			)
			.toList( "&" )
		;

		var resource = requestMetadata.getResource();
		var internalUrl = queryString.len()
			? "#resource#?#queryString#"
			: resource
		;

		return encodeForHtmlAttribute( internalUrl );

	}


	/**
	* I return the external (ie, fully qualified) URL for the given search parameters.
	*/
	public string function externalUrlFor( required struct searchParams ) {

		return ( site.url & urlFor( searchParams ) );

	}


	/**
	* I return the URL to be used for an internal redirect.
	*/
	public string function getInternalUrl() {

		var resource = requestMetadata.getResource();
		var queryString = requestMetadata.getQueryString();

		return queryString.len()
			? "#resource#?#queryString#"
			: resource
		;

	}


	/**
	* I goto the application URL defined by the given parameters.
	*/
	public void function goto( required struct searchParams ) {

		gotoUrl( urlFor( searchParams ) );

	}


	/**
	* I go to the given URL. This is just a short-hand for the native location() method
	* using a default addToken argument. No additional logic should be added here.
	*/
	public void function gotoUrl( required string nextUrl ) {

		location( url = nextUrl, addToken = false );

	}


	/**
	* I perform very light-weight validation to make sure the given input starts with a
	* slash (ie, is not an external URL).
	*/
	public boolean function isInternalUrl( required string input ) {

		// Note: it's possible to define protocol-less URLs that start with "//". As such,
		// we need to determine that the string starts with a slash, but NOT double-slash.
		return !! canonicalize( input, false, false )
			.reFind( "^/([^/]|$)" )
		;

	}


	/**
	* I return the next event segment, or the given fallback if there is no next segment.
	*/
	public string function next( string fallback = "" ) {

		// Note: this isn't thread-safe; however, since the code is for routing, we can
		// implicitly guarantee that it will only ever be accessed by one point of control
		// in a given request.
		var segment = $variables().currentSegment = $variables().queue.isDefined( 1 )
			? $variables().queue.shift()
			: fallback
		;

		return segment;

	}


	/**
	* I return the next relative template path used by the view routing.
	*/
	public string function nextTemplate( boolean nested = true ) {

		return nested
			? "./#segment()#/#segment()#.cfm"
			: "./#segment()#.cfm"
		;

	}


	/**
	* I add a persisted search parameter that will be automatically included when URLs are
	* generated using the router methods.
	*/
	public void function persistSearchParam(
		required string eventPrefix,
		required string paramName,
		required string paramValue
		) {

		$variables().persistedSearchParams.append({
			eventPrefix: eventPrefix,
			eventPattern: "^#reEscape( eventPrefix )#(\.|$)",
			paramName: paramName,
			paramValue: toString( paramValue )
		});

	}


	/**
	* I add a set of persisted search parameters that will be automatically included when
	* URLs are generated using the router methods.
	*/
	public void function persistSearchParams(
		required string eventPrefix,
		required array searchParams
		) {

		for ( var entry in searchParams ) {

			persistSearchParam(
				eventPrefix = eventPrefix,
				paramName = entry.name,
				paramValue = entry.value
			);

		}

	}


	/**
	* I return the current event segment as of the latest route traversal.
	*/
	public string function segment() {

		return $variables().currentSegment;

	}


	/**
	* I generate a URL for the given search parameters.
	*/
	public string function urlFor( required struct searchParams ) {

		if ( isNull( searchParams.event ) ) {

			throw(
				type = "App.Router.MissingEvent",
				message = "Router methods called without required search parameter.",
				detail = "Parameter: [event]"
			);

		}

		var augmentedParams = searchParams.copy();

		for ( var entry in $variables().persistedSearchParams ) {

			// Never override a passed-in parameter.
			if ( augmentedParams.keyExists( entry.paramName ) ) {

				continue;

			}

			// If we're generating a URL for the scoped event, append the persisted
			// parameter.
			if ( augmentedParams.event.reFind( entry.eventPattern ) ) {

				augmentedParams[ entry.paramName ] = entry.paramValue;

			}

		}

		var queryString = augmentedParams
			.keyArray()
			.map(
				( key ) => {

					return "#encodeForUrl( key )#=#encodeForUrl( augmentedParams[ key ] )#";

				}
			)
			.toList( "&" )
		;
		var scriptName = $variables().scriptName;

		return queryString.len()
			? "#scriptName#?#queryString#"
			: scriptName
		;

	}


	/**
	* I generate a url for the given segments. This is a convenience method that allows a
	* URL to be generated from N-arguments without an enclosing structure. It assumes that
	* the first argument is the event; then, ever two arguments after that represent key-
	* value pairs in the search string; and, if there's an argument remaining, it's used
	* as the url fragment.
	*/
	public string function urlForParts(
		required string event
		/* [ , key, value ] */
		/* [ , key, value ] */
		/* [ , key, value ] */
		/* [ , fragment ] */
		) {

		var inputs = arrayMap( arguments, ( element ) => element );
		var searchParams = [
			event: inputs.shift()
		];

		// Continue taking from the inputs while there are pairs of two.
		while ( inputs.isDefined( 2 ) ) {

			searchParams[ inputs.shift() ] = inputs.shift();

		}

		// If there's a single item left over, assume it will be the fragment.
		var fragment = inputs.isDefined( 1 )
			? "###inputs.shift()#"
			: ""
		;

		return "#urlFor( searchParams )##fragment#";

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I am a convenience method to access internal variables scoped to the request.
	*/
	private struct function $variables() {

		return request.$$routerVariables;

	}

}
