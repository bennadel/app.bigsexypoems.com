component {

	// Define properties for dependency-injection.
	property name="authContext" ioc:skip;
	property name="userModel" ioc:type="core.lib.model.user.UserModel";
	property name="userProvisioner" ioc:type="core.lib.service.user.UserProvisioner";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I run once before any of the tests in the current test suite have been executed. I
	* provide a way to run a per-suite setup.
	*/
	public void function beforeAll() {

		// Each test suite is given a fresh user to work with and a mock session. Since
		// the application doesn't really inspect the session object (other than to see
		// that the user is authenticated), we should be able to mock one (until the
		// complexity of the application increases).
		variables.authContext = provisionAuthContext();

	}


	/**
	* I run before each test method in the current test suite.
	*/
	public void function beforeEach() {

		// No-op — override in subclasses as needed.

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I assert that the actual value equals the expected value.
	* 
	* Note: this only works with simple value.
	*/
	private void function assertEqual(
		required any actual,
		required any expected,
		string message = ""
		) {

		if ( actual != expected ) {

			if ( message.len() ) {

				fail( message );

			}

			fail( "Expected [#expected#] but got [#actual#]." );

		}

	}


	/**
	* I assert that the given callback throws an error of the expected type.
	*/
	private void function assertThrows(
		required any callback,
		required string expectedType
		) {

		try {

			callback();

		} catch ( any error ) {

			if ( error.type == expectedType ) {

				return;

			}

			fail( "Expected throw type [#expectedType#] but got [#error.type#]: #error.message#" );

		}

		fail( "Expected [#expectedType#] to be thrown but no error occurred." );

	}


	/**
	* I assert that the given value is truthy.
	* 
	* Note: this only works with simple value.
	*/
	private void function assertTrue(
		required any actual,
		string message = ""
		) {

		if ( ! actual ) {

			if ( message.len() ) {

				fail( message );

			}

			fail( "Expected a truthy value but got [#actual#]." );

		}

	}


	/**
	* I fail the current test with the given message.
	*/
	private void function fail( required string message ) {

		throw(
			type = "TestRunner.Assertion",
			message = message
		);

	}


	/**
	* I provision a new test user and return an auth context for it.
	*/
	private struct function provisionAuthContext() {

		var userID = userProvisioner.ensureUserAccount(
			email = uniqueEmail(),
			offsetInMinutes = 0
		);

		return {
			session: {
				id: 0,
				isIdentified: true,
				isAuthenticated: true
			},
			user: userModel.get( userID ),
			timezone: {
				offsetInMinutes: 0
			}
		};

	}


	/**
	* I generate a unique email address for testing.
	*/
	private string function uniqueEmail() {

		return "test-#createUUID()#@bennadel.com";

	}

}
