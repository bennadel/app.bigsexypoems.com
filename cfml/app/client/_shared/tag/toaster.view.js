
window.jy2g1b = {
	Toaster
};

function Toaster() {

	return {
		// Public properties.
		items: [],
		previouslyActiveElement: null,

		// Life-cycle methods.
		init: init,

		// Public Methods.
		addItem,
		handleHtmxBeforeSwap,
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
	function addItem( item ) {

		// Used for the ":key" rendering in x-for directive.
		item.uid = Date.now();

		this.items.unshift( item );
		this.shiftFocus();

	}


	/**
	* I inspect HTMX responses. If they are non-boosted errors, they will be rendered as
	* toast messages since the application doesn't currently render error responses on
	* non-boosted operations.
	*/
	function handleHtmxBeforeSwap( event ) {

		if ( event.detail.isError && ! event.detail.boosted ) {

			// When a response comes back as an error, it's not inherently obvious that
			// the error was caused by something in the application logic or if the error
			// was something else in between the client and the server. In order to
			// prevent server error pages (and the like) from being rendered into a toast,
			// we're going to look for the presence of a "htmx landmark" in the response
			// content. If it's there, we know that the response should be safe to render.
			var content = event.detail.serverResponse.includes( "[htmx-error-message]" )
				? event.detail.serverResponse
				: "An unexpected error occurred. Trying your action again may work; but, it may not."
			;

			// CAUTION: the content is assumed to be SAFE HTML.
			this.addItem({
				content: content,
				isError: true
			});

		}

	}


	/**
	* I add a new toast item based on the given event.
	*/
	function handleToast( event ) {

		// Todo: implement toast event.
		console.log( event );

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

			this.$el
				.querySelector( ".item .dismiss" )
				?.focus()
			;

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
