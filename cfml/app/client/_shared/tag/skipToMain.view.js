
window.vn9w7t = {
	SkipToMain
};

function SkipToMain() {

	return {
		// Public properties.
		target: null,
		// Life-cycle methods.
		init,
		// Public methods.
		focusMain,
	};

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I initialize the component.
	*/
	function init() {

		this.target = document.querySelector( this.$el.getAttribute( "href" ) );

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I programmatically focus the main content area.
	*/
	function focusMain() {

		this.target.focus();
		this.target.scrollIntoView();

	}

}
