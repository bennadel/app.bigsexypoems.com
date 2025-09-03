
window.lzlbk2 = {
	FormController
};

function FormController() {

	return {
		// Public properties.
		isPrimaryting: false,

		// Public methods.
		init: $init,
		handleSubmit: handleSubmit
	};

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I initialize the form.
	*/
	function $init() {

		this.$el.requestSubmit( this.$refs.button );

	}

	/**
	* I handle the form submission, making sure a double-submission isn't possible.
	*/
	function handleSubmit( event ) {

		if ( this.isPrimaryting ) {

			event.preventDefault();
			return;

		}

		this.isPrimaryting = true;

	}

}
