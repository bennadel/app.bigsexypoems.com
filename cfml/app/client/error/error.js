
// Import app modules.
import "../_shared/less/ui.less";
import "../_shared/tag/errorMessage.view.{js,less}";
import "../_shared/tag/flashMessage.view.{js,less}";
import "../_shared/tag/localDevelopment.view.{js,less}";
import "../_shared/tag/svgSprite.view.{js,less}";
import "./**/*.view.{js,less}";

// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

// Note: by starting Alpine after the DOM is ready, it should give any other deferred
// scripts time to load and register components before Alpine is bootstrapped.
document.addEventListener(
	"DOMContentLoaded",
	( event ) => {

		Alpine.start();

	}
);
