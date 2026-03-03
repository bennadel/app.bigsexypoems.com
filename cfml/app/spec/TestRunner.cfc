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
		var suiteResults = arrayShuffle( suitePaths ).map(
			( suitePath ) => {

				return runSuite( suitePath, testFilter );

			},
			false // Parallel iteration - disabled until Adobe fixes bug.
		);

		var passCount = 0;
		var failCount = 0;
		var errorCount = 0;
		var failures = [];

		for ( var result in suiteResults ) {

			passCount += result.passCount;
			failCount += result.failCount;
			errorCount += result.errorCount;
			failures.append( result.failures, true );

		}

		return {
			ok: ( ! failCount && ! errorCount ),
			passCount,
			failCount,
			errorCount,
			failures
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
	* I run all test methods in the given suite and return per-suite results.
	*
	* Note: the suitePath is expected to be a dot-delimited component path.
	*/
	private struct function runSuite(
		required string suitePath,
		string testFilter = ""
		) {

		var suite = ioc.get( suitePath );
		var testMethods = discoverTestMethods( suite, testFilter );
		var passCount = 0;
		var failCount = 0;
		var errorCount = 0;
		var failures = [];

		suite.beforeAll();

		for ( var methodName in testMethods ) {

			try {

				suite.beforeEach();
				invoke( suite, methodName );
				passCount++;

			} catch ( TestRunner.Assertion error ) {

				failCount++;
				failures.append({
					suite: suitePath,
					test: methodName,
					type: "failure",
					message: error.message,
					detail: ""
				});

			} catch ( any error ) {

				errorCount++;
				failures.append({
					suite: suitePath,
					test: methodName,
					type: "error",
					message: error.message,
					detail: error.detail
				});

			}

		}

		return {
			passCount,
			failCount,
			errorCount,
			failures
		};

	}

}
