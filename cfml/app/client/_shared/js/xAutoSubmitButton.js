
document.addEventListener(
	"alpine:init",
	function setupAlpineBindings() {

		Alpine.directive( "auto-submit-button", AutoSubmitButtonDirective );

	}
);

/**
* I automatically submit the contextual form using the host button.
* 
* Note: This needs to be used on a button element (as opposed to a form element) so that
* any directives on the form itself (ex, x-prevent-double-submit) have time to initialize
* first (Alpine initializes from the top-down). 
*/
function AutoSubmitButtonDirective( element, metadata, framework ) {

	element.form.requestSubmit( element );

}
