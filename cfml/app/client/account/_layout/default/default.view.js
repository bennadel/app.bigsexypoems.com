
window.zm1em0 = {
	AppShell
};

function AppShell() {

	return {
		// Methods.
		focusMain: focusMain
	};

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I programmatically focus the main content area.
	*/
	function focusMain() {

		this.$refs.main.focus();
		this.$refs.main.scrollIntoView();

	}

}
