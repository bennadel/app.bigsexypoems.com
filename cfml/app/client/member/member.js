
// Import app modules.
import "../_shared/js/xAutoResize.js";
import "../_shared/js/xCopyToClipboard.js";
import "../_shared/js/xKeyedFocus.js";
import "../_shared/js/xMetaEnterSubmit.js";
import "../_shared/js/xPreventDoubleSubmit.js";
import "../_shared/js/xTableRowLinker.js";
import "../_shared/less/ui.less";
import "../_shared/tag/errorMessage.view.{js,less}";
import "../_shared/tag/flashMessage.view.{js,less}";
import "../_shared/tag/localDevelopment.view.{js,less}";
import "../_shared/tag/markdownDisclosure.view.{js,less}";
import "../_shared/tag/poemDiff.view.{js,less}";
import "../_shared/tag/poemPreviewInTable.view.{js,less}";
import "../_shared/tag/skipToMain.view.{js,less}";
import "../_shared/tag/speechTools.view.{js,less}";
import "../_shared/tag/svgSprite.view.{js,less}";
import "../_shared/tag/toaster.view.{js,less}";
import "./**/*.view.{js,less}";

// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

// Disable injection of CSS for htmx indicator styles.
htmx.config.includeIndicatorStyles = false;

// Note: by starting Alpine after the DOM is ready, it should give any other deferred
// scripts time to load and register components before Alpine is bootstrapped.
document.addEventListener(
	"DOMContentLoaded",
	( event ) => {

		Alpine.start();

	}
);
