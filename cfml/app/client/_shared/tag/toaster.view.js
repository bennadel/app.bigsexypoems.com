
window.jy2g1b = {
	Toaster
};

function Toaster() {

	var host = this.$el;

	return {
		// Public properties.
		items: [],
		previouslyActiveElement: null,

		// Life-cycle methods.
		init: init,

		// Public Methods.
		addItem,
		handleKeydown,
		handleToast,
		removeItem,
		shiftFocus,
		unshiftFocus,
	};

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I initialize the component.
	*/
	function init() {
		// ...
	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I add a new item to the toast queue.
	*/
	function addItem( message, isError = false ) {

		this.items.unshift({
			uid: Date.now(),
			message,
			isError
		});
		this.shiftFocus();

	}


	/**
	* I handle the keydown event when the dismiss button is focused.
	*/
	function handleKeydown( event, index ) {

		if ( event.key === "Escape" ) {

			event.preventDefault();
			this.removeItem( index );

		}

	}


	/**
	* I add a new toast item based on the given event.
	*/
	function handleToast( event ) {

		this.addItem(
			event.detail.message,
			event.detail.isError
		);

	}


	/**
	* I remove the item at the given index.
	*/
	function removeItem( index ) {

		this.items.splice( index, 1 );

		if ( this.items.length ) {

			this.shiftFocus();

		} else {

			this.unshiftFocus();

		}

	}


	/**
	* I shift the focus to the next most recent toast item.
	*/
	function shiftFocus() {

		if ( ! this.previouslyActiveElement ) {

			this.previouslyActiveElement = ( document.activeElement || null );

		}

		// Note: in Chrome (at least), there seems to be an issue where calling focus on
		// repeatedly-shown items doesn't always allow the focus to be transferred. So,
		// I'm using the next tick to give the browser a chance to chill out.
		this.$nextTick(() => {

			host.querySelector( ".item .dismiss" )?.focus();

		});

	}


	/**
	* I shift the focus back to the previously active element what was in focus before the
	* toaster stole focus.
	*/
	function unshiftFocus() {

		if ( this.previouslyActiveElement ) {

			this.previouslyActiveElement.focus();
			this.previouslyActiveElement = null;

		}

	}

}
