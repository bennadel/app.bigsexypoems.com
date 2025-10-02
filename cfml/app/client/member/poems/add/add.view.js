
window.spbiun = {
	ContentController
};

function ContentController( localStorageKey ) {

	return {
		// Life-Cycle Methods.
		init
	};

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I initialize the component.
	*/
	function init() {

		// If the input already has a value, that should take precedence. We only want to
		// import the poem from the playground (into the form) on the first load.
		if ( this.$el.value || ! localStorageKey ) {

			return;

		}

		try {

			this.$el.value = localStorage.getItem( localStorageKey );

		} catch ( error ) {

			console.error( error );

		}

	}

}
