
document.addEventListener(
	"alpine:init",
	function setupAlpineBindings() {

		Alpine.directive( "prevent-double-submit", PreventDoubleSubmitDirective );

	}
);

/**
* I prevent accidental double-form submissions.
*/
function PreventDoubleSubmitDirective( element, metadata, framework ) {

	var isSubmitting = false;

	window.addEventListener( "pageshow", handlePageshow );
	element.addEventListener( "submit", handleSubmit );

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I get the relevant submission buttons.
	*/
	function getButtons() {

		return element.querySelectorAll( "button[type='submit'], input[type='submit']" );

	}


	/**
	* I handle the pageshow event which is triggered when the page is rendered due to
	* browser navigation. This puts the form back into a submittable state so that the
	* user can re-submit it.
	*/
	function handlePageshow( event ) {

		// If the page wasn't pulled from the bfcache (Back/Forward), then the controller
		// is already in a good state.
		if ( ! event.persisted ) {

			return;

		}

		isSubmitting = false;

		for ( var node of getButtons() ) {

			node.classList.remove( "isDisabled" );
			node.disabled = false;

		}

	}


	/**
	* I handle the submit event, disabling buttons to prevent double-submission.
	*/
	function handleSubmit( event ) {

		if ( isSubmitting ) {

			event.preventDefault();
			console.info( "Double form-submission prevented (x-prevent-double-submit)." );
			return;

		}

		isSubmitting = true;

		for ( var node of getButtons() ) {

			// All buttons are safe to "visually disable" since the above logic will act
			// as the ultimate control flow. The button rendering is just a UX issue.
			node.classList.add( "isDisabled" );

			// Note: we can't disable buttons that have a "name" attribute otherwise the
			// button "value" may not get submitted back to the server.
			if ( ! node.hasAttribute( "name" ) ) {

				node.disabled = true;

			}

		}

	}

}
