
document.addEventListener(
	"alpine:init",
	function setupAlpineBindings() {

		Alpine.directive( "copy-to-clipboard", CopyToClipboardDirective );

	}
);

/**
* I copy the attribute value to the native clipboard (or fallback to using a prompt).
*/
function CopyToClipboardDirective( element, metadata, framework ) {

	var content = metadata.expression;
	var confirmationMessage = ( element.dataset.confirmationMessage || "Your text has been copied." );

	// Inside the directive, we don't have direct access to the magic utils. But, we can
	// get the scope associates with the host element; which gives us indirect access.
	var dispatch = Alpine.$data( element ).$dispatch;

	init();

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I setup the directive.
	*/
	function init() {

		framework.cleanup( destroy );
		element.addEventListener( "click", handleClick );

	}


	/**
	* I teardown the directive.
	*/
	function destroy() {

		element.removeEventListener( "click", handleClick );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I handle the click on the host.
	*/
	async function handleClick( event ) {

		try {

			await navigator.clipboard.writeText( content );

			dispatch(
				"app:toast",
				{
					message: confirmationMessage
				}
			);

		// If the clipboard isn't available or hasn't been granted transient write-access
		// (based on the user's interaction), it may throw an error. In that case, we'll
		// fall-back to using an old-school prompt.
		} catch ( error ) {

			prompt( "Copy to Clipboard:", content );
			console.error( error );

		}

	}

}
