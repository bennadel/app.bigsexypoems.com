window.z6s31p = {
	RevisionTracker,
};

function RevisionTracker( revisionUrl ) {

	var IDLE_DELAY = ( 30 * 1000 );
	var CAP_DELAY = ( 10 * 60 * 1000 );

	var idleTimer = null;
	var capTimer = null;
	var isRequestInFlight = false;

	return {
		// Life-Cycle Methods.
		destroy,

		// Public Methods.
		handleContentInput,
	};

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I teardown the component.
	*/
	function destroy() {

		clearTimeout( idleTimer );
		clearTimeout( capTimer );

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I handle input events from the content textarea.
	*/
	function handleContentInput() {

		resetIdleTimer();
		ensureCapTimer();

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I create a revision by posting to the server endpoint.
	*/
	function createRevision() {

		if ( isRequestInFlight ) {

			return;

		}

		clearTimeout( idleTimer );
		clearTimeout( capTimer );
		idleTimer = null;
		capTimer = null;

		var xsrfToken = getCookieValue( "XSRF-TOKEN" );

		if ( ! xsrfToken ) {

			return;

		}

		isRequestInFlight = true;

		var body = new FormData();
		body.append( "X-XSRF-TOKEN", xsrfToken );

		fetch(
			revisionUrl,
			{
				method: "POST",
				body: body,
			}
		)
			.catch(
				function() {
					// Silently ignore network errors for revision creation.
				}
			)
			.finally(
				function() {
					isRequestInFlight = false;
				}
			)
		;

	}


	/**
	* I start the cap timer if it isn't already running.
	*/
	function ensureCapTimer() {

		if ( capTimer === null ) {

			capTimer = setTimeout( createRevision, CAP_DELAY );

		}

	}


	/**
	* I get the value of the cookie with the given name.
	*/
	function getCookieValue( name ) {

		var match = document.cookie.match( new RegExp( "(^|;\\s*)" + name + "=([^;]*)" ) );

		return match
			? decodeURIComponent( match[ 2 ] )
			: ""
		;

	}


	/**
	* I reset the idle timer, restarting the countdown.
	*/
	function resetIdleTimer() {

		clearTimeout( idleTimer );
		idleTimer = setTimeout( createRevision, IDLE_DELAY );

	}

}
