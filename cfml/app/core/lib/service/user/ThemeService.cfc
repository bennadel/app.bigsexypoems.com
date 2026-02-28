component {

	// Define properties for dependency-injection.
	property name="themeCookies" ioc:type="core.lib.service.user.ThemeCookies";
	property name="themes" ioc:skip;
	property name="themesIndex" ioc:skip;

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the theme service.
	*/
	public void function $init() {

		// Note: the "id" value is what gets stored in the cookie.
		variables.themes = [
			[
				id: "light",
				name: "Light"
			],
			[
				id: "dark",
				name: "Dark"
			]
		];
		variables.themesIndex = arrayIndexBy( themes, "id" );

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I get the current theme preference as a struct with value and name keys.
	*/
	public struct function getTheme() {

		var id = themeCookies.getCookie();

		return ( themesIndex[ id ] ?: themes[ 1 ] );

	}


	/**
	* I get the list of available themes.
	*/
	public array function getThemes() {

		return themes;

	}


	/**
	* I set the current theme preference.
	*/
	public void function setTheme( required string id ) {

		if ( ! themesIndex.keyExists( id ) ) {

			return;

		}

		themeCookies.setCookie( themesIndex[ id ].id );

	}

}
