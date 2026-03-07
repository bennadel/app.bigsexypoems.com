component {

	// Define properties for dependency-injection.
	property name="ioc" ioc:type="core.lib.util.Injector";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I discover and run test suites, returning aggregated results.
	*/
	public struct function runAll(
		string suiteFilter = "",
		string testFilter = ""
		) {

		var suitePaths = discoverSuites( suiteFilter );
		// When running the test suites, we are going to SHUFFLE the array to ensure that
		// we don't accidentally have the order of the test suites depending on each other.
		// --
		// Note: parallel execution is NOT used because parallel iteration causes issues
		// with closures farther down in the stack. I've already ran into this bug twice.
		// It's marked as "fixed" in the Adobe tracker; so hopefully we can move to async
		// iteration in the next updater (7).
		// --
		// https://www.bennadel.com/blog/4879-adobe-coldfusion-bug-nested-closures-with-parallel-array-iteration-destroys-arguments.htm
		var suiteManifests = arrayShuffle( suitePaths ).map(
			( suitePath ) => {

				return runSuite( suitePath, testFilter );

			},
			false // Parallel iteration - disabled until Adobe fixes bug.
		);

		var manifest = arrayFlatten( suiteManifests );
		var failures = [];
		var passCount = 0;
		var failCount = 0;
		var errorCount = 0;

		for ( var entry in manifest ) {

			if ( entry.pass ) {

				passCount++;

			} else if ( entry.failure.type == "failure" ) {

				failCount++;
				failures.append( entry );

			} else if ( entry.failure.type == "error" ) {

				errorCount++;
				failures.append( entry );

			}

		}

		return {
			pass: ( ! failCount && ! errorCount ),
			manifest,
			failures,
			passCount,
			failCount,
			errorCount,
		};

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I discover test suite CFC paths.
	*/
	private array function discoverSuites( string suiteFilter = "" ) {

		if ( suiteFilter.len() ) {

			return [ suiteFilter ];

		}

		var filenames = directoryList(
			path = expandPath( "/spec/suite/" ),
			recurse = false,
			listInfo = "name",
			filter = "*.cfc"
		);

		return filenames.map(
			( filename ) => {

				return ( "spec.suite." & filename.reReplace( "\.cfc$", "" ) );

			}
		);

	}


	/**
	* I discover public test methods on the given suite.
	*/
	private array function discoverTestMethods(
		required any suite,
		string testFilter = ""
		) {

		var metadata = getMetadata( suite );
		var methods = [];

		for ( var entry in ( metadata.functions ?: [] ) ) {

			if (
				( entry.name.left( 4 ) == "test" ) &&
				( entry.access == "public" )
				) {

				methods.append( entry.name );

			}

		}

		if ( testFilter.len() ) {

			methods = methods.filter( ( name ) => ( name == testFilter ) );

		}

		return methods;

	}


	/**
	* I run all test methods in the given suite and return the testing manifest. The
	* manifest contains information about each test, including the failure (if exists).
	*
	* Note: the suitePath is expected to be a dot-delimited component path.
	*/
	private array function runSuite(
		required string suitePath,
		string testFilter = ""
		) {

		var suite = ioc.get( suitePath );
		var manifest = discoverTestMethods( suite, testFilter ).map(
			( methodName ) => {

				return {
					suite: suitePath,
					test: methodName,
					pass: true,
					failure: nullValue(),
				};

			}
		);

		suite.beforeAll();

		for ( var entry in manifest ) {

			try {

				suite.beforeEach();
				invoke( suite, entry.test );

			} catch ( TestRunner.Assertion error ) {

				entry.pass = false;
				entry.failure = {
					type: "failure",
					message: error.message,
					detail: ""
				};

			} catch ( any error ) {

				entry.pass = false;
				entry.failure = {
					type: "error",
					message: error.message,
					detail: error.detail
				};

			}

		}

		return manifest;

	}

}
