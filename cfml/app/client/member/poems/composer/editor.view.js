
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

	function init() {

		this.resizeContent();

	}

	// ---
	// PUBLIC METHODS.
	// ---

	function resizeContent() {

		this.$el.style.height = `${ Math.max( 300, this.$el.scrollHeight ) }px`;

	}

}
