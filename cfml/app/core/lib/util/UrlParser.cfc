component {

	// Define properties for dependency-injection.
	property name="URIClass" ioc:skip;

	/**
	* I initialize the parser.
	*/
	public void function init() {

		variables.URIClass = createObject( "java", "java.net.URI" );

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I get the host from the given URI. If a base is provided, the input URI is resolved
	* against the base URI before it's parsed.
	*/
	public string function getHost(
		required string input,
		string base = ""
		) {

		return parseUri( argumentCollection = arguments )
			.host
		;

	}


	/**
	* I parse the given URI into its component parts. If a base is provided, the input URI
	* is resolved against the base URI before it's parsed. URI components follow the given
	* semantics:
	*
	* Example:    "https://admin:test@example.com:80/users.cfm?id=4#details"
	* -------
	* scheme:     "https"
	* authority:  "admin:test@example.com:80"
	* userInfo:   "admin:test"
	* host:       "example.com"
	* port:       "80"
	* resource:   "//admin:test@example.com:80/users.cfm?id=4"
	* path:       "/users.cfm"
	* search:     "?id=4"
	* parameters: "id=4"
	* hash:       "#details"
	* fragment:   "details"
	*/
	public struct function parseUri(
		required string input,
		string base = ""
		) {

		// If a base is provided, we want to resolve the input against the base. This is
		// primarily helpful when the input lacks a scheme and/or authority. Resolution
		// will traverse "../" and "/" path segments as needed.
		var uri = base.len()
			? URIClass.create( base ).resolve( input )
			: URIClass.create( input )
		;

		// The URI object exposes a mix of encoded and decoded values. I've opted to
		// surface all of the ENCODED values as the common case since this more closely
		// aligns with the CGI scope that developers are used to consuming. The DECODED
		// values are included as the decoded sub-struct for anyone who needs them.
		return [
			input: input,
			base: base,
			source: uri.toString(),
			scheme: lcase( uri.getScheme() ?: "" ),
			authority: ( uri.getRawAuthority() ?: "" ),
			userInfo: ( uri.getRawUserInfo() ?: "" ),
			host: lcase( uri.getHost() ?: "" ),
			// Port defaults to -1 if it's not defined. I'd rather have it consistently be
			// reported as a string using the empty string as the fallback.
			port: ( uri.getPort() == -1 )
				? ""
				: toString( uri.getPort() )
			,
			resource: uri.getRawSchemeSpecificPart(),
			path: ( uri.getRawPath() ?: "" ),
			// Search is just a representation of the parameters prefixed with a "?". If
			// the parameters are empty, so is the search.
			search: len( uri.getRawQuery() )
				? "?#uri.getRawQuery()#"
				: ""
			,
			parameters: ( uri.getRawQuery() ?: "" ),
			// Hash is just a representation of the fragment prefixed with a "#". If the
			// fragment is empty, so is the hash.
			hash: len( uri.getRawFragment() )
				? "###uri.getRawFragment()#"
				: ""
			,
			fragment: ( uri.getRawFragment() ?: "" ),

			// An absolute URI starts with a scheme (http:, mailto:, etc). A non-absolute
			// URI would start with something like "/" or "../" or "my/path".
			isAbsolute: uri.isAbsolute(),
			// An opaque URI is one whose resource is not representative of a path. It's
			// for schemes like "mailto:" and "tel:". An opaque URI's resource isn't
			// parsed into smaller components (path, parameters, etc). All non-relevant
			// components will default to the empty string.
			isOpaque: uri.isOpaque(),

			// These decoded components include decoded character sequences. These aren't
			// always safe to use because embedded delimiters such as "/" and "&" can
			// corrupt the meaning of the string.
			decoded: [
				authority: ( uri.getAuthority() ?: "" ),
				userInfo: ( uri.getUserInfo() ?: "" ),
				resource: uri.getSchemeSpecificPart(),
				path: ( uri.getPath() ?: "" ),
				parameters: ( uri.getQuery() ?: "" ),
				fragment: ( uri.getFragment() ?: "" ),
			],
		];

	}


	/**
	* I parse the given parameters string into an ORDERED struct of key-values pairs. Each
	* value in the struct is an array of strings. Parameters are collected in the order in
	* which they are parsed and are appended the proper array. If a given parameter
	* doesn't have a value, the value will be parsed as an empty string. This provides a
	* consistent interface - every key is guaranteed to have at least one value.
	*
	* Example: "tag=fun&tag=adventure&medium=movie&favorites"
	* -------
	* tag:       [ "fun", "adventure" ]
	* medium:    [ "movie" ]
	* favorites: [ "" ]
	*/
	public struct function parseParameters(
		required string parameters,
		boolean caseSensitive = false
		) {

		var segments = parameters.listToArray( "&" );
		// By default, the casing of the parameter keys is insensitive; and is defined
		// coincidentally by the first key encountered. When case-sensitivity is enabled,
		// keys with different casing are collected into different entries.
		var parameterIndex = caseSensitive
			? structNew( "ordered-casesensitive" )
			: structNew( "ordered" )
		;

		for ( var segment in segments ) {

			// By using the list-methods, we're ensuring that we cover edge-cases in which
			// the key is empty or the value contains embedded "=" characters. Note that
			// the `true` in this case is `includeEmptyValues`.
			var key = urlDecode( segment.listFirst( "=", true ) );
			var value = urlDecode( segment.listRest( "=", true ) );

			if ( parameterIndex.keyExists( key ) ) {

				parameterIndex[ key ].append( value );

			} else {

				parameterIndex[ key ] = [ value ];

			}

		}

		return parameterIndex;

	}


	/**
	* I parse the given URI into its component parts. The search parameters are further
	* parsed into an ORDERED struct of key-values pairs. See parseParameters() for details
	* on how the parameters are returned.
	*/
	public struct function parseUriAndParameters(
		required string input,
		string base = "",
		boolean caseSensitive = false
		) {

		var uri = parseUri( input, base );
		// Swap out the parameters string with the newly parsed and constructed object.
		// But, let's keep the original string for posterity.
		uri.parametersString = uri.parameters;
		uri.parameters = parseParameters( uri.parameters, caseSensitive );

		return uri;

	}

}
