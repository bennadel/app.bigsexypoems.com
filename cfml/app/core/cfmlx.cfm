<cfscript>

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// These are CFML e(X)tensions. These are intended to be runtime extensions for CFML
	// template execution. As such, they should pertain almost entirely to polyfills, data
	// structure manipulation, and short-hand aliases for existing functions. There should
	// be NOTHING in here that is coupled to the application business logic.

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I return a shallow copy / slice of the given array.
	*/
	private array function arrayCopy( required array collection ) {

		return [ ...collection ];

	}


	/**
	* I group the given collection using the given key as the associative entry.
	*/
	private struct function arrayGroupBy(
		required array collection,
		required string key
		) {

		var index = {};

		for ( var element in collection ) {

			var groupKey = element[ key ];

			if ( ! index.keyExists( groupKey ) ) {

				index[ groupKey ] = [];

			}

			index[ groupKey ].append( element );

		}

		return index;

	}


	/**
	* I index the given collection using the given key as the associative entry.
	*/
	private struct function arrayIndexBy(
		required array collection,
		required string key
		) {

		var index = {};

		for ( var element in collection ) {

			index[ element[ key ] ] = element;

		}

		return index;

	}


	/**
	* I return an array of plucked values using the given key.
	*/
	private array function arrayPluck(
		required array collection,
		required string key
		) {

		return arrayPluckPath( collection, [ key ] );

	}


	/**
	* I return an array of plucked values using the given key path.
	*/
	private array function arrayPluckPath(
		required array collection,
		required array keyPath
		) {

		return collection.map(
			( element ) => {

				return keyPath.reduce(
					( reduction, key ) => {

						return reduction[ key ];

					},
					element
				);

			}
		);

	}


	/**
	* I return an array of plucked values using the given key. Duplicate values will be
	* omitted from the result.
	*/
	private array function arrayPluckUnique(
		required array collection,
		required string key
		) {

		var results = [];
		var valueIndex = {};

		for ( var element in collection ) {

			var value = element[ key ];

			if ( ! valueIndex.keyExists( value ) ) {

				valueIndex[ value ] = true;
				results.append( value );

			}

		}

		return results;

	}


	/**
	* I return an index of the values reflected as struct keys.
	*/
	private struct function arrayReflect( required array collection ) {

		var index = {};

		for ( var element in collection ) {

			index[ element ] = element;

		}

		return index;

	}


	/**
	* I clamp the given value to the given bounds.
	*/
	private numeric function clamp(
		required numeric value,
		required numeric minValue,
		required numeric maxValue
		) {

		return max( min( value, maxValue ), minValue );

	}


	/**
	* I polyfill the dump() function in Adobe ColdFusion.
	*/
	private void function dump(
		required any var,
		boolean expand = true,
		string format = "html",
		string hide = "",
		numeric keys = 9999,
		string label = "",
		string output = "browser",
		string show = "all",
		boolean showUDFs = true,
		numeric top = 9999,
		boolean abort = false
		) {

		// Note: under the hood, Adobe ColdFusion seems to be compiling this down into an
		// instance of the CFDump tag (based on error messages). As such, it's much more
		// temperamental than a normal function invocation. We have to be much more
		// explicit in our argument pass-through; and, certain attributes CANNOT be passed
		// in as NULL.
		writeDump(
			var = var,
			expand = expand,
			format = format,
			hide = hide,
			keys = keys,
			label = label,
			output = output,
			show = show,
			showUDFs = showUDFs,
			top = top,
			abort = abort
		);

	}


	/**
	* I dump the top N entries of the given value.
	*/
	private void function dumpN(
		required any var,
		numeric top = 10
		) {

		dump( argumentCollection = arguments );

	}


	/**
	* Alias for native method: encodeForHtml().
	*/
	private string function e( required string value ) {

		return encodeForHtml( value );

	}


	/**
	* Alias for native method: encodeForHtmlAttribute().
	*/
	private string function e4a( required string value ) {

		return encodeForHtmlAttribute( value );

	}


	/**
	* Alias for native method: encodeForJavaScript().
	*/
	private string function e4j( required string value ) {

		return encodeForJavaScript( value );

	}


	/**
	* I serialize the given value as JSON and encode for JavaScript. This is intended to
	* be consumed in a `JSON.parse( "#e4Json()#" )` call.
	*/
	private string function e4json( required any value ) {

		return encodeForJavaScript( serializeJson( value ) );

	}


	/**
	* Alias for native method: encodeForUrl().
	*/
	private string function e4u( required string value ) {

		return encodeForUrl( value );

	}


	/**
	* I polyfill the echo() function in Adobe ColdFusion.
	*/
	private void function echo( any value = "" ) {

		writeOutput( value );

	}


	/**
	* I determine if the given value is a ColdFusion component instance.
	*/
	private boolean function isComponent( required any value ) {

		if ( ! isObject( value ) ) {

			return false;

		}

		// The isObject() function will return true for both components and Java objects.
		// As such, we need to go one step further to see if we can get at the component
		// metadata before we can truly determine if the value is a ColdFusion component.
		try {

			var metadata = getMetadata( value );

			return ( metadata?.type == "component" );

		} catch ( any error ) {

			return false;

		}

	}


	/**
	* Polyfill Lucee CFML's isInThread() function using Adobe ColdFusion's page-context.
	*/
	private boolean function isInThread() {

		return getPageContext().isUnderCFThread();

	}


	/**
	* I determine if the given value is a native string.
	*/
	private boolean function isString( required any value ) {

		return isInstanceOf( value, "java.lang.String" );

	}


	/**
	* I return a closure that binds given method to the given source component, allowing
	* the closure to be passed-around without scoping.
	*/
	private function function methodBind(
		required any source,
		required string methodName,
		any methodArguments
		) {

		return () => invoke( source, methodName, ( methodArguments ?: arguments ) );

	}


	/**
	* I create a new range with the given indicies.
	*/
	private array function rangeNew(
		required numeric start,
		numeric end
		) {

		// If only one index is provided, assume start from 1.
		if ( isNull( end ) ) {

			arguments.end = arguments.start;
			arguments.start = 1;

		}

		var size = ( end - start + 1 );
		var range = [];
		range.resize( size );

		for ( var i = 1 ; i <= size ; i++ ) {

			range[ i ] = ( start + i - 1 );

		}

		return range;

	}


	/**
	* I create a directory at the given path if it doesn't exist.
	*/
	private string function safeDirectoryCreate( required string path ) {

		if ( ! directoryExists( path ) ) {

			directoryCreate( path );

		}

		return path;

	}


	/**
	* I delete the given file if exists.
	*/
	private void function safeFileDelete( required string path ) {

		if ( ! path.len() || ! fileExists( path ) ) {

			return;

		}

		fileDelete( path );

	}


	/**
	* I implement a safe insertAt in which the given value is appended if the index is
	* beyond the end of the collection.
	*/
	private array function safeInsertAt(
		required array input,
		required numeric index,
		required any value
		) {

		if ( index <= input.len() ) {

			input.insertAt( index, value );

		} else {

			input.append( value );

		}

		return input;

	}


	/**
	* I polyfill the systemOutput() function in Adobe ColdFusion.
	*/
	private void function systemOutput(
		required any value,
		boolean addNewline = false, // Ignored.
		boolean doErrorStream = false // Ignored.
		) {

		if ( isString( value ) && value.find( "<print-stack-trace>" ) ) {

			var stacktrace = callStackGet()
				.map( ( frame ) => "#frame.template#:#frame.lineNumber#" )
				.prepend( "Stacktrace:" )
				.toList( chr( 10 ) )
			;

			value = value.replace( "<print-stack-trace>", stacktrace );

		}

		dump(
			var = value,
			format = "text",
			output = "console"
		);

	}


	/**
	* I convert the given collection to an array of entries. Each entry has (index, key,
	* and value) properties. This is intended as a sort-of polyfill for the fact that
	* Lucee can provide key/value and index/item during collection iteration. ColdFusion
	* has some of this; but, the implementation is not complete. This would at least
	* provide some sort of unified way to get at this data.
	*/
	private array function toEntries( required any collection ) {

		if ( isArray( collection ) ) {

			return collection.map(
				( value, i ) => {

					return {
						index: i,
						key: i,
						value: value
					};

				}
			);

		}

		if ( isStruct( collection ) ) {

			return collection.keyArray().map(
				( key, i ) => {

					return {
						index: i,
						key: key,
						value: collection[ key ]
					};

				}
			);

		}

		throw(
			type = "CFMLX.UnsupportedCollectionType",
			message = "Cannot get entries for unsupported collection type."
		);

	}


	/**
	* I polyfill the ucFirst() function in Adobe ColdFusion.
	*/
	private string function ucFirst( required string input ) {

		if ( len( input ) <= 1 ) {

			return ucase( input );

		}

		return ( ucase( left( input, 1 ) ) & right( input, -1 ) );

	}

</cfscript>
