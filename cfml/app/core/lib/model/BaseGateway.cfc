component output = false {

	// Define properties for dependency-injection.
	property name="decodeMappings" ioc:skip;
	property name="indexPrefixes" ioc:skip;

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the database gateway.
	*/
	public void function init(
		array indexPrefixes = [],
		struct decodeMappings = {}
		) {

		// An array of column names that act as index prefixes.
		variables.indexPrefixes = arguments.indexPrefixes;
		// A mapping of column names to more specific ColdFusion types.
		variables.decodeMappings = arguments.decodeMappings;

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
	* exactly match the intent of the modeled data (ex, using a TinyInt column to model a
	* ColdFusion Boolean). This method provides a way to map common database values back
	* into their ColdFusion counterparts.
	* 
	* Note: you should only be calling this method AS NEEDED. We don't have to use it for
	* every gateway method call.
	*/
	private array function decodeColumns( required array results ) {

		for ( var row in results ) {

			for ( var key in decodeMappings ) {

				switch ( decodeMappings[ key ] ) {
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
