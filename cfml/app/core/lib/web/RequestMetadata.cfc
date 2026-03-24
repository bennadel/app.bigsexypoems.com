component hint = "I provide utility methods for accessing metadata about the current request." {

	// Define properties for dependency-injection.
	property name="logger" ioc:type="core.lib.util.Logger";
	property name="scopedProxyKey" ioc:skip;

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the router service.
	*/
	public void function initAfterInjection() {

		// Even though this component is cached for the lifetime of the application, it
		// acts as a scoped proxy to each individual request. Request-specific state is
		// stored on the given request key.
		variables.scopedProxyKey = "$requestMetadata$variables";

		// EDGE-CASE: if the request metadata needs to be consumed during the application
		// boot-strapping process but before the per-request setup has been run (such as
		// when logging the app-initialization), calling an implicit setup will prevent
		// errors. This is very tight coupling; which may be a symptom of poor
		// architectural choices. But, for the moment, I'm just putting in this hacky-fix
		// while I think more deeply about the problem.
		setupRequest();

	}

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I set up the request-specific state for the scoped proxy. This method is intended to
	* be called once at the top of every request.
	*/
	public void function setupRequest() {

		// The HTTP request data isn't available after the request has ended. Which means
		// that any asynchronous code that needs this data MAY OR MAY NOT throw an error
		// depending on the incidental timing of the thread execution. As such, we're
		// going to grab the headers NOW, at the start of the request, just in case anyone
		// needs them later.
		var metadata = getHttpRequestData( false );

		request[ scopedProxyKey ] = {
			headers: metadata.headers
		};

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I determine if the given content type is accepted by the current request.
	*/
	public boolean function accepts( required string contentType ) {

		return !! getHeader( "Accept" ).findNoCase( contentType );

	}


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
	* I safely get the given HTTP header.
	*/
	public string function getHeader(
		required string name,
		string fallbackValue = ""
		) {

		var headers = $variables().headers;

		return ( headers[ name ] ?: fallbackValue );

	}


	/**
	* I return the HTTP headers.
	*/
	public struct function getHeaders( array includeOnly = [] ) {

		var headers = $variables().headers;

		if ( ! includeOnly.len() ) {

			return headers.copy();

		}

		var includeIndex = arrayReflect( includeOnly );

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
	* I get the HTTP headers sent by the HTMX JavaScript framework.
	*/
	public struct function getHtmxHeaders() {

		return {
			boosted: ( getHeader( "HX-Boosted" ) == "true" ),
			currentUrl: getHeader( "HX-Current-URL" ),
			historyRestoreRequest: getHeader( "HX-History-Restore-Request" ),
			prompt: getHeader( "HX-Prompt" ),
			request: ( getHeader( "HX-Request" ) == "true" ),
			target: getHeader( "HX-Target" ),
			triggerName: getHeader( "HX-Trigger-Name" ),
			trigger: getHeader( "HX-Trigger" ),
		};

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
	* I return the most trusted IP city reported for the current request.
	*/
	public string function getIpCity() {

		// This header value is being provided by the Cloudflare geolocation settings. As
		// such, let's only trust this value when the core IP address header is populated
		// by Cloudflare. This probably isn't a meaningful distinction. But, for now, it
		// makes it feel slightly defensive against user-provided values.
		if ( ! isHeaderPopulated( getHeaders(), "CF-Connecting-IP" ) ) {

			return "";

		}

		// Note: converting to UTF-8 for accented characters.
		return charsetConvert( getHeader( "CF-IPCity" ) );

	}


	/**
	* I return the most trusted IP country reported for the current request.
	*/
	public string function getIpCountry() {

		// This header value is being provided by the Cloudflare geolocation settings. As
		// such, let's only trust this value when the core IP address header is populated
		// by Cloudflare. This probably isn't a meaningful distinction. But, for now, it
		// makes it feel slightly defensive against user-provided values.
		if ( ! isHeaderPopulated( getHeaders(), "CF-Connecting-IP" ) ) {

			return "";

		}

		return getHeader( "CF-IPCountry" );

	}


	/**
	* I return the most trusted IP region reported for the current request.
	*/
	public string function getIpRegion() {

		// This header value is being provided by the Cloudflare geolocation settings. As
		// such, let's only trust this value when the core IP address header is populated
		// by Cloudflare. This probably isn't a meaningful distinction. But, for now, it
		// makes it feel slightly defensive against user-provided values.
		if ( ! isHeaderPopulated( getHeaders(), "CF-Connecting-IP" ) ) {

			return "";

		}

		// Note: converting to UTF-8 for accented characters.
		return charsetConvert( getHeader( "CF-Region" ) );

	}


	/**
	* I return the HTTP method.
	*/
	public string function getMethod() {

		return cgi.request_method.ucase();

	}


	/**
	* I return the HTTP path_info.
	*/
	public string function getPathInfo() {

		return cgi.path_info;

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

			return "#resource#?#cgi.query_string#";

		}

		return resource;

	}


	/**
	* I return the client's user-agent.
	*/
	public string function getUserAgent() {

		return cgi.http_user_agent;

	}


	/**
	* I determine if the current HTTP request is a get.
	*/
	public boolean function isGet() {

		return ( getMethod() == "get" );

	}


	/**
	* I determine if the current HTTP request is a post.
	*/
	public boolean function isPost() {

		return ( getMethod() == "post" );

	}


	/**
	* I determine if the current HTTP request is part of a test suite execution.
	*/
	public boolean function isTestRun() {

		return ( request?.isTestRun == true );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I return the scoped proxy variables (request-specific state).
	*/
	private struct function $variables() {

		return request[ scopedProxyKey ];

	}


	/**
	* I convert the given string between two encodings. This is intended to convert HTTP
	* headers as needed.
	*/
	private string function charsetConvert(
		required string input,
		string fromEncoding = "iso-8859-1",
		string toEncoding = "utf-8"
		) {

		if ( ! input.len() ) {

			return input;

		}

		try {

			return charsetEncode( charsetDecode( input, fromEncoding ), toEncoding );

		} catch ( any error ) {

			// ... I'm not sure if there's ever an error due to charset conversions. To
			// be safe, I'm just going to swallow any errors for now.
			logger.logException( error );
			return input;

		}

	}


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
