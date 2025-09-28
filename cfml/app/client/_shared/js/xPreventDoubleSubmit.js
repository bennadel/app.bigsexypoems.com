
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
	* I handle the submit event.
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
