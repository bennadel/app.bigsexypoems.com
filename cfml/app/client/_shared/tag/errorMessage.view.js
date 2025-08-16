
window.pm14ud = {
	ErrorMessage
};

function ErrorMessage() {

	return {
		init: $init
	};

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I initialize the component.
	*/
	function $init() {

		this.$el.focus();
		this.$refs.scrollTarget.scrollIntoView({
			behavior: "smooth",
			block: "start"
		});

	}

}
