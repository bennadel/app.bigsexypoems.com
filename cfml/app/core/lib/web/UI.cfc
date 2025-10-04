component {

	// Define properties for dependency-injection.
	property name="router" ioc:type="core.lib.web.Router";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I return the given attribute based on the given "parts" inputs.
	*/
	public string function attr(
		required string attributeName,
		required any attributeArguments
		) {

		return '#attributeName#="#router.urlForParts( argumentCollection = attributeArguments )#"';

	}


	/**
	* I return the form action attribute based on the given inputs.
	*/
	public string function attrAction( required string event ) {

		return attr( "action", arguments );

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
	* I return the href attribute based on the given inputs.
	*/
	public string function attrHref( required string event ) {

		return attr( "href", arguments );

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

		return attr( "src", arguments );

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
