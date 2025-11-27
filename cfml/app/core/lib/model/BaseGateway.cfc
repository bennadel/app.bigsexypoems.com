component output = false {

	// Define properties for dependency-injection.
	property name="indexPrefixes" ioc:skip;

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the database gateway.
	*/
	public void function init( array indexPrefixes = [] ) {

		// An array of column names that act as index prefixes.
		variables.indexPrefixes = arguments.indexPrefixes;

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I assert that one of the arguments in the given collection matches one of the index
	* prefixes on the table.
	*/
	private void function assertIndexPrefix( required any args ) {

		for ( var key in indexPrefixes ) {

			if ( args.keyExists( key ) ) {

				return;

			}

		}

		// If we made it this far, none of the arguments match an index prefix.
		throw(
			type = "Gateway.ForbiddenSql",
			message = "Gateway arguments must include at least one index prefix.",
			detail = "Available prefixes: #indexPrefixes.toList()#",
			extendedInfo = "Provided arguments: #structKeyList( args )#"
		);

	}


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

}
