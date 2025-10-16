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
	* I split each row (within a cross-join) into a collection of separate objects.
	*/
	private array function normalizeCrossProduct( required array results ) {

		return results.map( ( row ) => structSplit( row ) );

	}

}
