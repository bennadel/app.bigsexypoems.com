
// Import app modules.
import "../_shared/js/tzHelper.js";
import "../_shared/less/theme.less";
import "../_shared/less/ui.less";
import "../_shared/tag/errorMessage.view.{js,less}";
import "../_shared/tag/flashMessage.view.{js,less}";
import "../_shared/tag/localDevelopment.view.{js,less}";
import "../_shared/tag/svgSprite.view.{js,less}";
import "./*/**/*.{js,less}";

// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

htmx.config.responseHandling = [
	{ code: "204",    swap: false },
	{ code: "[23]..", swap: true },

	// Adding this one to allow 404 responses to be merged into the page.
	{ code: "404",    swap: true, error: true },
	// Adding this one to allow 422 responses to be merged into the page.
	{ code: "422",    swap: true },

	{ code: "[45]..", swap: false, error: true },
	{ code: "...",    swap: true }
];

// Note: by starting Alpine after the DOM is ready, it should give any other deferred
// scripts time to load and register components before Alpine is bootstrapped.
document.addEventListener(
	"DOMContentLoaded",
	( event ) => {

		Alpine.start();

	}
);
