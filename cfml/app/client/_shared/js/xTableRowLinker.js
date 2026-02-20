
document.addEventListener(
	"alpine:init",
	function setupAlpineBindings() {

		Alpine.directive( "table-row-linker", TableRowLinkerDirective );

	}
);

/**
* I make the rows in the table clickable. The primary gesture is to make the `isRowLinker`
* anchor the one that is activated on row-click. But, a secondary gesture, a whole cell
* will be make clickable if it contains a single link and no other actionable elements.
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
		element.addEventListener( "click", handleClick );

	}


	/**
	* I tear down the directive.
	*/
	function destroy() {

		element.removeEventListener( "click", handleClick );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I handle the mouse event on the table.
	*/
	function handleClick( event ) {

		// If the event was fired programmatically, ignore it.
		if ( ! event.isTrusted ) {

			return;

		}

		// Only process the main mouse button (ie, not if right-clicking).
		if ( event.button !== 0 ) {

			return;

		}

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

		// If the event originated from an actionable element, ignore.
		if ( target.closest( "a, button" ) ) {

			return;

		}

		var selection = window.getSelection();

		// If the user highlighted text in the table row, it will often trigger a click
		// event. As such, let's ignore events in which a non-empty selection exists.
		if ( selection && ! selection.isCollapsed ) {

			return;

		}

		var linkNodes = cell.querySelectorAll( "a" );
		var actionableNodes = cell.querySelectorAll( "a, button" );

		// If there's only a single LINK in the cell and NO OTHER actionable elements,
		// let's activate the link regardless of whether or not it's the row-linker.
		if (
			( linkNodes.length === 1 ) &&
			( actionableNodes.length === 1 )
			) {

			linkNodes[ 0 ].click();
			return;

		}

		// If there are any actionable elements in the cell, don't do anything at this
		// point since this event represents a miss-click on the user's behalf. We don't
		// want to activate the wrong link or button.
		if ( actionableNodes.length ) {

			return;

		}

		var row = cell.closest( "tr" );
		var rowLinker = row.querySelector( selector );

		// If there's no row linker, then no further action can be taken.
		if ( ! rowLinker ) {

			return;

		}

		// Translate row event into link event.
		rowLinker.click();

	}

}
