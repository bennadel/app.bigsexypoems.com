component
	output = false
	hint = "I provide utility methods for accessing metadata about the current request."
	{

	// Define properties for dependency-injection.
	property name="utilities" ioc:type="core.lib.util.Utilities";

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* Runs any request-based setup logic, as needed.
	*/
	public void function setupRequest() {

		// The HTTP request data isn't available after the request has ended. Which means
		// that any asynchronous code that needs this data MAY OR MAY NOT throw an error
		// depending on the incidental timing of the thread execution. As such, we're
		// going to grab the headers NOW, at the start of the request, just in case anyone
		// needs them later.
		var metadata = getHttpRequestData( false );

		request.$$requestMetadataVariables = {
			headers: metadata.headers
		};

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I return the ETag for the given request (or the empty string if none exists).
	*/
	public string function getETag() {

		return cgi.http_if_none_match;

	}


	/**
	* I return the fingerprint of the current client.
	*/
	public string function getFingerprint() {

		return lcase( hash( getIpAddress() & getUserAgent() ) );

	}


	/**
	* I return the HTTP headers.
	*/
	public struct function getHeaders( array includeOnly = [] ) {

		var headers = ( request.$$requestMetadataVariables.headers ?: {} );

		if ( ! includeOnly.len() ) {

			return headers.copy();

		}

		var includeIndex = utilities.reflect( includeOnly );

		return headers.filter(
			( key ) => {

				return includeIndex.keyExists( key );

			}
		);

	}


	/**
	* I return the HTTP host.
	*/
	public string function getHost() {

		return cgi.server_name;

	}


	/**
	* I return the most trusted IP address reported for the current request.
	*/
	public string function getIpAddress() {

		var headers = getHeaders();

		// Try to get the IP address being injected by the Cloudflare CDN. This is the
		// most "trusted" value since it's not being provided by the user - it's the last
		// external IP address outside of the Cloudflare network.
		if ( isHeaderPopulated( headers, "CF-Connecting-IP" ) ) {

			var ipValue = headers[ "CF-Connecting-IP" ].trim().lcase();

		// If the Cloudflare-provided IP isn't available, fallback to any proxy IP. This
		// is a user-provided value and should be used with caution - it can be spoofed
		// with little effort.
		} else if ( isHeaderPopulated( headers, "X-Forwarded-For" ) ) {

			var ipValue = headers[ "X-Forwarded-For" ].listFirst().trim().lcase();

		// If we have nothing else, defer to the standard CGI variable.
		} else {

			var ipValue = cgi.remote_addr.trim().lcase();

		}

		// Check to make sure the IP address only has valid characters. Since this is
		// user-provided data (for all intents and purposes), we should validate it.
		if ( ipValue.reFind( "[^0-9a-f.:]" ) ) {

			throw(
				type = "InvalidIpAddressFormat",
				message = "The reported IP address is invalid.",
				detail = "IP address: #ipValue#"
			);

		}

		return ipValue;

	}


	/**
	* I return the HTTP method.
	*/
	public string function getMethod() {

		return cgi.request_method.ucase();

	}


	/**
	* I return the HTTP protocol.
	*/
	public string function getProtocol() {

		if (
			( cgi.https == "on" ) ||
			( cgi.server_port_secure == 1 )
			) {

			return "https";

		}

		return "http";

	}


	/**
	* I return the HTTP query string.
	*/
	public string function getQueryString() {

		return cgi.query_string;

	}


	/**
	* I return the HTTP referer.
	*/
	public string function getReferer() {

		return cgi.http_referer;

	}


	/**
	* I return the executing script and any extra path information.
	*/
	public string function getResource() {

		return ( cgi.script_name & cgi.path_info );

	}


	/**
	* I return the HTTP scheme.
	*/
	public string function getScheme() {

		return ( getProtocol() & "://" );

	}


	/**
	* I return the executing script.
	*/
	public string function getScriptName() {

		return cgi.script_name;

	}


	/**
	* I return the HTTP URL.
	*/
	public string function getUrl() {

		var resource = ( getScheme() & getHost() & getResource() );

		if ( cgi.query_string.len() ) {

			return ( resource & "?" & cgi.query_string );

		}

		return resource;

	}


	/**
	* I return the client's user-agent.
	*/
	public string function getUserAgent() {

		return cgi.http_user_agent;

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I determine if the given header value is populated with a non-empty, SIMPLE value.
	*/
	private boolean function isHeaderPopulated(
		required struct headers,
		required string key
		) {

		return (
			headers.keyExists( key ) &&
			isSimpleValue( headers[ key ] ) &&
			headers[ key ].trim().len()
		);

	}

}
