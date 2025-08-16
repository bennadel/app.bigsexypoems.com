component
	output = false
	hint = "I provide miscellaneous utility functions."
	{

	/**
	* I return a shallow copy / slice of the given array.
	*/
	public array function arrayCopy( required array collection ) {

		return [ ...collection ];

	}


	/**
	* I clamp the given value to the given bounds.
	*/
	public numeric function clamp(
		required numeric value,
		required numeric minValue,
		required numeric maxValue
		) {

		return max( min( value, maxValue ), minValue );

	}


	/**
	* I return an abbreviated, flattened version of the given component metadata.
	*/
	public struct function getFlatMetadataIndex( required any input ) {

		var rootMetadata = getMetadata( input );
		// In order to make the chain visiting easier, let's create a fake "root" that
		// uses the input as a "parent". This way, the first step in our do-while loop can
		// always be an ".extends" navigation.
		var target = {
			extends: rootMetadata
		};
		// Stylistic choice, I'm using ordered structs here so that the "more concrete"
		// entries will be higher-up in the final collections. And, the "more abstract"
		// entries will be lower-down in the final collections.
		var propertyIndex = [:];
		var functionIndex = [:];

		do {

			target = target.extends;

			for ( var entry in target.properties ) {

				// Since we're walking up the component chain from more concrete to more
				// abstract, only include properties that haven't already been defined at
				// a more concrete level.
				if ( ! propertyIndex.keyExists( entry.name ) ) {

					propertyIndex[ entry.name ] = entry;

				}

			}

			for ( var entry in target.functions ) {

				// Since we're walking up the component chain from more concrete to more
				// abstract, only include functions that haven't already been defined at
				// a more concrete level.
				if ( ! functionIndex.keyExists( entry.name ) ) {

					functionIndex[ entry.name ] = entry;

				}

			}

		} while ( target.keyExists( "extends" ) );

		return {
			name: rootMetadata.name,
			propertyIndex: propertyIndex,
			functionIndex: functionIndex
		};

	}


	/**
	* I extract a temporary name from the given email address.
	*/
	public string function getNameFromEmail(
		required string email,
		string fallbackName = "New User"
		) {

		var name = email
			.listFirst( "@" )
			.reReplace( "[._-]+", " ", "all" )
			.trim()
			.reReplace( "(?:^|\b)(\S)", "\U\1", "all" )
		;

		if ( name.len() ) {

			return name.left( 50 );

		}

		return fallbackName;

	}


	/**
	* I group the given collection using the given key as the associative entry.
	*/
	public struct function groupBy(
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
	public struct function indexBy(
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
	* I determine if the given value is a ColdFusion component instance.
	*/
	public boolean function isComponent( required any value ) {

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
	public boolean function isInThread() {

		return getPageContext().isUnderCFThread();

	}


	/**
	* I return an array of plucked values using the given key.
	*/
	public array function pluck(
		required array collection,
		required string key
		) {

		return pluckPath( collection, [ key ] );

	}


	/**
	* I return an array of plucked values using the given key path.
	*/
	public array function pluckPath(
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
	public array function pluckUnique(
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
	public struct function reflect( required array collection ) {

		var index = {};

		for ( var element in collection ) {

			index[ element ] = element;

		}

		return index;

	}


	/**
	* I create a directory at the given path if it doesn't exist.
	*/
	public string function safeDirectoryCreate( required string path ) {

		if ( ! directoryExists( path ) ) {

			directoryCreate( path );

		}

		return path;

	}


	/**
	* I delete the given file if exists.
	*/
	public void function safeFileDelete( required string path ) {

		if (
			! path.len() ||
			! fileExists( path )
			) {

			return;

		}

		fileDelete( path );

	}


	/**
	* I implement a safe insertAt in which the given value is appended if the index is
	* beyond the end of the collection.
	*/
	public array function safeInsertAt(
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
	* SHIM: I'm hoping this can be removed in future versions of ColdFusion.
	*/
	public array function structValueArray( required struct input ) {

		return input.keyArray().map(
			( key ) => {

				return input[ key ];

			}
		);

	}


	/**
	* I convert the given collection to an array of entries. Each entry has (index, key,
	* and value) properties.
	*/
	public array function toEntries( required any collection ) {

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
			type = "UnsupportedCollectionType",
			message = "Cannot get entries for unsupported collection type."
		);

	}


	/**
	* I uppercase the first letter in the given input.
	*/
	public string function ucFirst( required string input ) {

		if ( len( input ) <= 1 ) {

			return ucase( input );

		}

		return ( ucase( left( input, 1 ) ) & right( input, -1 ) );

	}

}
