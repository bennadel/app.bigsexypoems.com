
document.addEventListener(
	"alpine:init",
	function setupAlpineBindings() {

		Alpine.directive( "keyed-focus", KeyedFocusDirective );

	}
);

/**
* I listen to the `F` key as a means to move focus to the host element. This is being done
* to allow convenient focus without the accessibility concerns that come with the global
* `autofocus` attribute.
*/
function KeyedFocusDirective( element, metadata, framework ) {

	var triggerKey = "f";

	init();

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I setup the directive.
	*/
	function init() {

		framework.cleanup( destroy );
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

		// If the host element is already focused, there's nothing to do.
		if ( document.activeElement === element ) {

			return;

		}

		// If the currently active element is an input variation, ignore event. The user
		// may be working in a sibling input and we don't want to steal focus.
		if ( document.activeElement?.matches( "button, input, select, textarea" ) ) {

			return;

		}

		// We're about to move focus to the host element before the key life-cycle has
		// completed. If we don't prevent the default behavior, the browser will render a
		// character (f) into the host element.
		event.preventDefault();
		element.focus();

	}

}
