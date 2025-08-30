
window.jy2g1b = {
	HtxmError
};

function HtxmError() {

	return {
		isActive: false,

		init: init,

		close,
		handleResponse,
	};

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I initialize the component.
	*/
	function init() {

	}

	// ---
	// PUBLIC METHODS.
	// ---

	function close() {

		this.isActive = false;


	}

	function handleResponse( event ) {

		if ( event.detail.isError ) {

			event.detail.shouldSwap = true;
			event.detail.target = this.$refs.errorContent;
			this.isActive = true;

		}

	}

}
