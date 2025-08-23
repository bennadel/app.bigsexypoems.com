component
	hint = "I try to polyfill the parameter grouping functionality used by Lucee CFML"
	{

	// Define properties for dependency-injection.
	property name="requestMetadata" ioc:type="core.lib.web.RequestMetadata";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I apply the parameter grouping polyfill to the CFML scopes.
	*/
	public void function apply() {

		// Inspect the URL scope.
		var keysToFix = findKeysToFix( url );

		if ( keysToFix.len() ) {

			fixScopeKeys( url, keysToFix, getRawUrlScope() );

		}

		// Inspect the FORM scope.
		var keysToFix = findKeysToFix( form );

		if ( keysToFix.len() ) {

			fixScopeKeys( form, keysToFix, getRawFormScope() );
			fixFieldNames();

		}

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I identify which keys in the given scope need to be fixed. These are the keys that
	* still have the "[]" suffix, indicating that the CFML engine didn't handle the
	* grouping properly.
	*/
	private array function findKeysToFix( required struct cfmlScope ) {

		return cfmlScope
			.keyArray()
			.filter( ( key ) => ( key.right( 2 ) == "[]" ) )
		;

	}


	/**
	* I remove any "[]" notation from the fieldnames property of the form.
	*/
	private void function fixFieldNames() {

		form.fieldNames = form.fieldNames
			.reReplace( "\[\](,|$)", "\1", "all" )
		;

	}


	/**
	* I replace the list-based value concatenation of the CFML scope with the array-based
	* value aggregation in the given raw servlet parameters.
	*/
	private void function fixScopeKeys(
		required struct cfmlScope,
		required array keysToFix,
		required struct rawParameters
		) {

		for ( var key in keysToFix ) {

			// Remove the "[]" suffix from the key and create a new entry.
			cfmlScope[ key.left( -2 ) ] =
				// The underlying Java value is a native Java array. We need to convert
				// that value to a native ColdFusion array (ArrayList) so that it will
				// behave like any other array, complete with member methods.
				arrayNew( 1 ).append( rawParameters[ key ], true )
			;

			// Swap the raw scope key-value pairs with the normalized versions.
			cfmlScope.delete( key );

		}

	}


	/**
	* I get the underlying servlet form parameters.
	* 
	* Caution: at this time, we assume this is the Adobe ColdFusion engine servlet
	* implementation since it's the only one we can polyfill at this time.
	*/
	private struct function getRawFormScope() {

		// Note: we're creating an intermediary struct in order to convert the raw servlet
		// parameters into a CASE-INSENSITIVE collection. Without this, the key-casing in
		// the corresponding CFML scope may not be accessible in the raw parameters.
		var caseInsensitive = {};

		if ( requestMetadata.isGet() ) {

			return caseInsensitive;

		}

		return caseInsensitive
			.append( getServletRequest().getParameterMap() )
		;

	}


	/**
	* I get the underlying servlet search parameters.
	* 
	* Caution: at this time, we assume this is the Adobe ColdFusion engine servlet
	* implementation since it's the only one we can polyfill at this time.
	*/
	private struct function getRawUrlScope() {

		// Note: we're creating an intermediary struct in order to convert the raw servlet
		// parameters into a CASE-INSENSITIVE collection. Without this, the key-casing in
		// the corresponding CFML scope may not be accessible in the raw parameters.
		var caseInsensitive = {};

		if ( requestMetadata.isPost() ) {

			return caseInsensitive
				.append( getServletRequest().getRequest().getParameterMap() )
			;

		}

		// Note: For a GET request, this will contain just the URL parameters. However,
		// for PUT/PATCH/DELETE, this will be a combination of both URL and FORM values.
		return caseInsensitive
			.append( getServletRequest().getParameterMap() )
		;

	}


	/**
	* I get the underlying servlet request.
	*/
	private any function getServletRequest() {

		return getPageContext().getRequest();

	}

}
