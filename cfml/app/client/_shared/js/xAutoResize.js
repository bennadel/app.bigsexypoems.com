
document.addEventListener(
	"alpine:init",
	function setupAlpineBindings() {

		Alpine.directive( "auto-resize", AutoResizeDirective );

	}
);

/**
* I auto-resize the textarea as the user types.
*/
function AutoResizeDirective( element, metadata, framework ) {

	var lineCount = 1;
	var timer = null;
	var delay = 250;

	init();

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I setup the directive.
	*/
	function init() {

		framework.cleanup( destroy );
		element.addEventListener( "input", handleInput );

		resizeTextarea();

	}


	/**
	* I tear down the directive.
	*/
	function destroy() {

		element.removeEventListener( "input", handleInput );
		clearTimeout( timer );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I handle the input event.
	*/
	function handleInput( event ) {

		clearTimeout( timer );
		timer = setTimeout( resizeTextarea, delay );

	}


	/**
	* I apply the debounced resizing of the textarea.
	*/
	function resizeTextarea() {

		var lineBreaks = element.value.match( /\r\n?|\n/g );
		var newLineCount = lineBreaks
			? ( lineBreaks.length + 1 )
			: 1
		;

		// Only attempt resize if the line-count has changed.
		if ( lineCount === newLineCount ) {

			return;

		}

		lineCount = newLineCount;
		// Setting the height to 0 will get the browser to resize the textarea to it's
		// smallest possible dimensions (taking into account the min-height property).
		element.style.height = 0;
		// Then, reading the scrollHeight will force a repaint and will give us the actual
		// height of the content, which we then store back into the element. Thankfully,
		// this control-flow doesn't appear to cause any UI flashing on the desktop.
		// --
		// Note: adding a few pixels because the scrollHeight doesn't seem into include
		// the border-width; but the box-sizing settings will include border-width when
		// adjusting the height. As such, we have to add the border-width to the new
		// height assignment.
		element.style.height = `${ element.scrollHeight + 2 }px`;

	}

}
