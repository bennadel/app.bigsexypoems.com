component {

	// Define properties for dependency-injection.
	property name="clock" ioc:type="core.lib.util.Clock";
	property name="router" ioc:type="core.lib.web.Router";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I return the form action attribute based on the given inputs.
	*/
	public string function attrAction( required string event ) {

		return attrForUrlParts( "action", arguments );

	}


	/**
	* I return the checked attribute based on the given condition.
	*/
	public string function attrChecked( required boolean input ) {

		if ( input ) {

			return "checked";

		}

		return "";

	}


	/**
	* I return a list of class names that map to truthy values in the given options.
	*/
	public string function attrClass( required struct options ) {

		var classNames = [];

		for ( var className in options ) {

			if ( ! options.keyExists( className ) ) {

				continue;

			}

			if ( isBoolean( options[ className ] ) ) {

				if ( options[ className ] ) {

					classNames.append( className );

				}

			} else if ( isSimpleValue( options[ className ] ) ) {

				if ( len( options[ className ] ) ) {

					classNames.append( className );

				}

			}

		}

		return 'class="#classNames.toList( " " )#"';

	}


	/**
	* I return the given attribute based on the given "parts" inputs.
	*/
	public string function attrForUrlParts(
		required string attributeName,
		required any attributeArguments
		) {

		return '#attributeName#="#urlForParts( argumentCollection = attributeArguments )#"';

	}


	/**
	* I return the href attribute based on the given inputs.
	*/
	public string function attrHref( required string event ) {

		return attrForUrlParts( "href", arguments );

	}


	/**
	* I return the selected attribute based on the given condition.
	*/
	public string function attrSelected( required boolean input ) {

		if ( input ) {

			return "selected";

		}

		return "";

	}


	/**
	* I return the src attribute based on the given inputs.
	*/
	public string function attrSrc( required string event ) {

		return attrForUrlParts( "src", arguments );

	}


	/**
	* I return the relative time element for the given input. 
	*/
	public string function elemFromNow( required date input ) {

		var datetime = input.dateTimeFormat( "iso" );
		var title = userDateTime( input );

		return "<time title=""#title#"" datetime=""#datetime#"">#clock.fromNow( input )#</time>";

	}


	/**
	* I return an external (ie, fully qualified) URL for the given segments. This is
	* convenient short-cut to the Router method of the same name.
	*/
	public string function externalUrlForParts(
		required string event
		/* [ , key, value ] */
		/* [ , key, value ] */
		/* [ , key, value ] */
		/* [ , fragment ] */
		) {

		return router.externalUrlForParts( argumentCollection = arguments );

	}


	/**
	* I get the most recently created field ID token. If a space / comma delimited string
	* is passed-in, a compound token will be returned.
	*/
	public string function fieldId( string after = "" ) {

		var token = "fid$#request?.$$fieldIdCounter#";

		if ( ! after.len() ) {

			return token;

		}

		return after
			.listToArray( ",; " )
			.map( ( suffix ) => "#token##suffix#" )
			.toList( " " )
		;

	}


	/**
	* I format the given date relative to now - all dates are assumed to be in UTC. This
	* is convenient short-cut to the Clock method of the same name.
	*/
	public string function fromNow( required date input ) {

		return clock.fromNow( input );

	}


	/**
	* I create a new field ID token and return it.
	*/
	public string function nextFieldId() {

		// Ensure that the counter exists and is incremented on every call. This is
		// intended to be used within the context of a single request thread and is NOT
		// meant to be thread-safe or globally unique.
		request.$$fieldIdCounter = ( ( request.$$fieldIdCounter ?: 0 ) + 1 );

		return fieldId();

	}


	/**
	* I generate a URL for the given segments. This is convenient short-cut to the Router
	* method of the same name.
	*/
	public string function urlForParts(
		required string event
		/* [ , key, value ] */
		/* [ , key, value ] */
		/* [ , key, value ] */
		/* [ , fragment ] */
		) {

		return router.urlForParts( argumentCollection = arguments );

	}


	/**
	* I format the date in the user's local timezone.
	*/
	public string function userDate(
		required date input,
		string mask = "mmm d, yyyy"
		) {

		return dateFormat( dateAdd( "n", request.authContext.timezone.offsetInMinutes, input ), mask );

	}


	/**
	* I format the date/time in the user's local timezone. This combines the userDate()
	* and the userTime() method using the given separator.
	*/
	public string function userDateTime(
		required date input,
		string separator = " at "
		) {

		return ( userDate( input ) & separator & userTime( input ) );

	}


	/**
	* I format the time in the user's local timezone.
	*/
	public string function userTime(
		required date input,
		string mask = "h:nntt"
		) {

		return timeFormat( dateAdd( "n", request.authContext.timezone.offsetInMinutes, input ), mask )
			.lcase()
		;

	}

}
