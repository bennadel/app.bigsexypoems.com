
document.addEventListener(
	"alpine:init",
	function setupAlpineBindings() {

		Alpine.directive( "meta-enter-submit", MetaEnterSubmitDirective );

	}
);

/**
* I allow a form to be submitted with the meta-enter keyboard combo.
*/
function MetaEnterSubmitDirective( element, metadata, framework ) {

	init();

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I setup the directive.
	*/
	function init() {

		framework.cleanup( destroy );
		element.addEventListener( "keydown", handleKeydown );

	}


	/**
	* I tear down the directive.
	*/
	function destroy() {

		element.removeEventListener( "keydown", handleKeydown );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I handle the keydown event.
	*/
	function handleKeydown( event ) {

		if (
			( event.key === "Enter" ) &&
			( event.metaKey || event.ctrlKey )
			) {

			event.preventDefault();
			element.form.requestSubmit();

		}

	}

}
