component hint = "I provide a way to instantiate jSoup Java classes." {

	// Define properties for dependency-injection.
	property name="jarPaths" ioc:skip;

	/**
	* I initialize the class loader.
	*/
	public void function init() {

		variables.jarPaths = [
			expandPath( "/core/vendor/jsoup/1.18.3/jsoup-1.18.3.jar" )
		];

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create an instance of the given class.
	*/
	public any function create( required string classPath ) {

		return createObject( "java", classPath, jarPaths );

	}

}
