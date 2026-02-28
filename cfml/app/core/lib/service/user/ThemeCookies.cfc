component hint = "I provide methods for managing the theme cookies for the current request." {

	// Define properties for dependency-injection.
	property name="cookieDomain" ioc:get="config.site.cookieDomain";
	property name="cookieName" ioc:skip;
	property name="isLive" ioc:get="config.isLive";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the theme cookies service.
	*/
	public void function $init() {

		variables.cookieName = "bigsexy_theme";

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I get the current theme preference. Returns "light" or "dark".
	*/
	public string function getTheme() {

		var value = ( cookie[ cookieName ] ?: "" );

		if ( value == "dark" ) {

			return "dark";

		}

		return "light";

	}


	/**
	* I set / store the current theme preference.
	*
	* Note: this will cause a SET-COOKIE header to be sent in the HTTP response.
	*/
	public void function setTheme( required string theme ) {

		switch ( theme ) {
			case "dark":
			case "light":
				// Theme is valid.
			break;
			default:
				theme = "light";
			break;
		}

		cookie[ cookieName ] = buildCookieSettings({
			value: theme,
			expires: "never"
		});

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I build the theme cookies using the given overrides.
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
