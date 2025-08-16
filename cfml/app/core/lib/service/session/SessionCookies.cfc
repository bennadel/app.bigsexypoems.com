component
	output = false
	hint = "I provide methods for managing the session cookies for the current request."
	{

	// Define properties for dependency-injection.
	property name="cookieDomain" ioc:get="config.site.cookieDomain";
	property name="cookieName" ioc:skip;
	property name="isLive" ioc:get="config.isLive";

	/**
	* I initialize the session cookies service.
	*/
	public void function $init() {

		variables.cookieName = "bigsexy";

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I delete / expire the current session cookies.
	* 
	* Note: this will cause a SET-COOKIE header to be sent in the HTTP response.
	*/
	public void function deleteCookie() {

		cookie[ cookieName ] = buildCookieSettings({
			value: "",
			expires: "now"
		});

	}


	/**
	* I get the current session cookies (in a normalized structure).
	*/
	public struct function getCookie() {

		var encodedValue = ( cookie[ cookieName ] ?: "" );
		var decodedValue = [
			sessionID: 0,
			sessionToken: ""
		];
		var parts = encodedValue.listToArray( "." );

		if ( parts.len() != 2 ) {

			return decodedValue;

		}

		decodedValue.sessionID = val( parts[ 1 ] );
		decodedValue.sessionToken = trim( parts[ 2 ] );

		return decodedValue;

	}


	/**
	* I get the current session cookies (in a normalized structure) and then set the
	* cookie to be expired. This is a convenience method used during logouts.
	*/
	public struct function getAndDeleteCookie() {

		var payload = getCookie();
		deleteCookie();

		return payload;

	}


	/**
	* I set / store the current session cookies.
	* 
	* Note: this will cause a SET-COOKIE header to be sent in the HTTP response.
	*/
	public void function setCookie(
		required numeric sessionID,
		required string sessionToken
		) {

		cookie[ cookieName ] = buildCookieSettings({
			value: "#sessionID#.#sessionToken#",
			expires: "never"
		});

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I build the session cookies using the given overrides.
	*/
	private struct function buildCookieSettings( required struct overrides ) {

		var payload = [
			name: cookieName,
			domain: cookieDomain,
			encodeValue: false,
			httpOnly: true,
			secure: isLive, // I don't have an SSL locally.
			sameSite: "lax",
			preserveCase: true
		];

		return payload.append( overrides );

	}

}
