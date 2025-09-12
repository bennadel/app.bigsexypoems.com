
window.z6s31p = {
	ProseContent
};

function ProseContent() {

	return {
		// Life-Cycle Methods.
		init,
		// Methods.
		resizeContent
	};

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I initialize the component.
	*/
	function init() {

		this.resizeContent();

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I update the textarea height to match the text height (within reason).
	*/
	function resizeContent() {

		// Setting the height to auto will get the browser to resize the textarea to fit
		// the current content (taking into account the min-height property).
		// --
		// Note: we can't just do this in CSS because the `auto` dimensions are only
		// calculated on first render.
		this.$el.style.height = "auto";
		// Then, reading the scrollHeight will give us the actual height
		this.$el.style.height = `${ this.$el.scrollHeight }px`;

	}

}
