component
	output = false
	hint = "I provide a way to create custom JAR-based class loaders."
	{

	// Define properties for dependency-injection.
	property name="javaLoaderFactory" ioc:skip;

	/**
	* I initialize the class loader factory.
	*/
	public void function init() {

		variables.javaLoaderFactory = new core.vendor.javaLoaderFactory.JavaLoaderFactory();

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I get the JAR-based class loader for the given paths.
	*/
	public any function createClassLoader( required array jarPaths ) {

		return javaLoaderFactory.getJavaLoader( jarPaths );

	}

}
