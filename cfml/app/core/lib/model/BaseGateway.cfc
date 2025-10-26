component output = false {

	// Define properties for dependency-injection.
	property name="DEBUGGING_COMMENT" ioc:skip;
	property name="DOT_PATH" ioc:skip;

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the database gateway.
	*/
	public void function init() {

		variables.DOT_PATH = getMetadata( this ).fullName;
		// This comment can be placed at the top of each SQL statement to help identify
		// where a slow-running query might be coming from. This is really only needed for
		// view-partials since CRUD methods should never be slow.
		variables.DEBUGGING_COMMENT = "/* DEBUG: #DOT_PATH# */";

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* When storing data in the database, we often have to use constructs that don't
	* exactly match the intent of the modeled data. This method provides a high-level way
	* to map common database values back into their ColdFusion counterparts.
	*/
	private array function decodeColumns(
		required array results,
		required struct mappings
		) {

		for ( var row in results ) {

			for ( var key in mappings ) {

				switch ( mappings[ key ] ) {
					case "boolean":
						row[ key ] = !! row[ key ];
					break;
					case "json":
						row[ key ] = deserializeJson( row[ key ] );
					break;
				}

			}

		}

		return results;

	}


	/**
	* I split each row (within a cross-join) into a collection of separate objects. This
	* transformation is performed in-place.
	*/
	private array function normalizeCrossJoin( required array results ) {

		return results.each( ( row ) => normalizeCrossJoinNamespaces( row ) )
			?: results // Hack because ACF doesn't return a collection from .each().
		;

	}


	/**
	* I split the given cross-product struct into multiple structs. The name of each
	* sub-struct is determined by the first element in the delimited list. This
	* transformation is performed in-place.
	*/
	private void function normalizeCrossJoinNamespaces( required struct input ) {

		for ( var key in input.keyArray() ) {

			// Expects most entries to be in the form of `{subName}_{subKey}`.
			var parts = key.listToArray( "_" );

			// If there's no namespace, or the delimiter occurs too many times, skip over
			// the key - it's unclear how to process it.
			if ( parts.len() != 2 ) {

				continue;

			}

			var subName = parts[ 1 ];
			var subKey = parts[ 2 ];
			// MOVE KEY into sub-key. Note that ColdFusion will create a new struct as-
			// needed. We don't have to perform any special check for the namespace.
			input[ subName ][ subKey ] = input[ key ];
			input.delete( key );

			// Edge-case: if we're normalizing the ID column in a LEFT join, it would be
			// more convenient for consumption in the view if a failed join had a ZERO id.
			// This way, it could be treated as truthy.
			switch ( subKey ) {
				case "id":
					input[ subName ][ subKey ] = val( input[ subName ][ subKey ] );
				break;
			}

		}

	}

}
