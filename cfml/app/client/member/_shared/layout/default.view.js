
window.mpjwb9 = {
	AppShell,
	Header,
};

function AppShell() {

	// Note: I'm leaving this component in because the [x-data] in the root ensures that
	// the rest of the page is alpine aware (otherwise, custom directives may not fire).
	return {};

}

function Header() {

	var host = this.$el;

	return {
		// Public properties.
		isNavOpen: false,

		// Public methods.
		toggleNav,
	};

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I toggle the static rendering of the nav menu.
	*/
	function toggleNav() {

		this.isNavOpen = ! this.isNavOpen;

	}

}
