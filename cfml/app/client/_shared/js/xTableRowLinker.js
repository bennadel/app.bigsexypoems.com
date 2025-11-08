
document.addEventListener(
	"alpine:init",
	function setupAlpineBindings() {

		Alpine.directive( "table-row-linker", TableRowLinkerDirective );

	}
);

/**
* I make the rows in the table clickable based on the existence of an isRowLinker link.
* This will not effect table cells that contain other actionable items (in order to remove
* the possible confusion of a misclick).
*/
function TableRowLinkerDirective( element, metadata, framework ) {

	var attribute = "x-table-row-linker";
	var selector = ".isRowLinker";

	init();

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I setup the directive.
	*/
	function init() {

		if ( ! element.matches( ".uiTable" ) ) {

			throw new Error( `${ attribute } must be applied to .uiTable` );

		}

		framework.cleanup( destroy );
		element.addEventListener( "mousedown", handleMousedown );

	}


	/**
	* I tear down the directive.
	*/
	function destroy() {

		element.removeEventListener( "mousedown", handleMousedown );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I handle the mousedown event on the table.
	*/
	function handleMousedown( event ) {

		// Since we're using event delegation in this directive, it's possible that
		// another directive or event binding will have already been applied (and should
		// take precedence). If the event's default behavior has been canceled, we don't
		// want to interfere with that control flow.
		if ( event.defaultPrevented ) {

			return;

		}

		var target = event.target;
		var cell = target.closest( "td" );

		// If the event didn't originate from within a table cell interaction, ignore. It
		// must have come from a header or a caption.
		if ( ! cell ) {

			return;

		}

		var row = cell.closest( "tr" );
		var rowLinker = row.querySelector( selector );

		// If there's no row linker, then this directive is likely being applied to a
		// table accidentally. Throw an error so that this configuration is logged.
		if ( ! rowLinker ) {

			throw new Error( `${ attribute } can't find ${ selector }` );

		}

		// If the event originated from an actionable element, ignore.
		if ( target.closest( "a, button" ) ) {

			return;

		}

		// If the event did NOT originate from an actionable element BUT the target cell
		// contains other actionable items, ignore. If the user clicked in that cell, but
		// didn't click one of said actionable items, then there's a good chance this was
		// just a mis-click on the user's end. We don't want to confuse the user by now
		// navigating to a page that is unrelated to the intended target.
		if ( cell.querySelector( `a:not(${ selector }), button` ) ) {

			return;

		}

		// Translate row event into link event.
		rowLinker.click();

	}

}
