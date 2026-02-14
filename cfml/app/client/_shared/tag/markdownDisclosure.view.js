window.kg8mkb = {
	MarkdownDisclosure
};

function MarkdownDisclosure() {

	return {
		// Public methods.
		applyHashEventToSummary
	};

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I expand the details element if it's the URL target.
	*/
	function applyHashEventToSummary() {

		var summary = this.$el;
		var details = summary.parentElement;

		// The ":target" pseudo selector matches the element linked-to via the hash.
		if ( ! summary.matches( ":target" ) ) {

			return;

		}

		if ( ! details.open ) {

			details.open = true;
			details.scrollIntoView();

		}

	}

}
