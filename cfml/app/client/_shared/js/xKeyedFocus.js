
document.addEventListener(
	"alpine:init",
	function setupAlpineBindings() {

		Alpine.directive( "keyed-focus", KeyedFocusDirective );

	}
);

/**
* I listen to the `F` key as a means to move focus to the first input within the form.
* This is being done to allow convenient focus without the accessibility concerns that
* come with the `autofocus` directive.
*/
function KeyedFocusDirective( element, metadata, framework ) {

	var triggerKey = "f";

	// CSS selector used to find eligible fields to focus.
	var selector = `
		input:not(:disabled, [hidden], [type='hidden'], [type='button'], [type='submit'], [type='image']),
		textarea:not(:disabled, [hidden]),
		select:not(:disabled, [hidden])
	`;

	init();

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I setup the directive.
	*/
	function init() {

		framework.cleanup( destroy );

		// If the directive has an expression, use this as the CSS selector when finding
		// eligible elements to focus.
		if ( metadata.expression ) {

			selector = metadata.expression;

		}

		window.addEventListener( "keydown", handleKeydown );

	}


	/**
	* I tear down the directive.
	*/
	function destroy() {

		window.removeEventListener( "keydown", handleKeydown );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I handle the keydown event on the window.
	*/
	function handleKeydown( event ) {

		// If the event was triggered for any other key, ignore event.
		if ( event.key !== triggerKey ) {

			return;

		}

		// If the key is modified in any way, ignore event. The user is doing something
		// specific and we don't want to interfere.
		if ( event.altKey || event.ctrlKey || event.metaKey || event.shiftKey ) {

			return;

		}

		// If the currently active element is an input variation, ignore event. The user
		// may be working in a sibling form container and we don't want to steal focus.
		if ( document.activeElement?.matches( "button, input, select, textarea" ) ) {

			return;

		}

		var newTarget = element.querySelector( selector );

		if ( newTarget ) {

			// We're about to move focus to an input before the key life-cycle has
			// completed. If we don't prevent the default behavior, the browser will
			// render a character into the focused form control.
			event.preventDefault();
			newTarget.focus();

		}

	}

}
