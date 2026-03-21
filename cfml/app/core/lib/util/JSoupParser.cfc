component hint = "I provide a thin wrapper around jSoup DOM creation." {

	// Define properties for dependency-injection.
	property name="classLoader" ioc:type="core.lib.classLoader.JSoupClassLoader";
	property name="JSoupClass" ioc:skip;

	/**
	* I initialize the jsoup parser.
	*/
	public void function initAfterInjection() {

		variables.JSoupClass = classLoader.create( "org.jsoup.Jsoup" );

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create a new Cleaner instance with the given safelist.
	*/
	public any function createCleaner( required any safelist ) {

		return classLoader
			.create( "org.jsoup.safety.Cleaner" )
			.init( safelist )
		;

	}


	/**
	* I create a new, empty Safelist instance.
	*/
	public any function createSafelist() {

		return classLoader
			.create( "org.jsoup.safety.Safelist" )
			.init()
		;

	}


	/**
	* I parse the given HTML fragment and return the resultant BODY node.
	*/
	public any function parseFragment( required string input ) {

		return JSoupClass
			.parseBodyFragment( input )
			.body()
		;

	}


	/**
	* I parse the given HTML document and return the resultant DOCUMENT node.
	*/
	public any function parseHtml( required string input ) {

		return JSoupClass.parse( input );

	}

}
