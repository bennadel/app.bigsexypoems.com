component output = false {

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the database gateway.
	*/
	public void function init() {
		// ...
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

}
