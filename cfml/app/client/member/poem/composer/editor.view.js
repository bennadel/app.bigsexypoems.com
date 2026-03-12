
window.z6s31p = {
	WordTools,
};

function WordTools() {

	return {
		// Public methods.
		handleBeforeResults,
		handleRhyme,
		handleSynonym,

		// Private methods.
		loadDefinitions,
		loadRhymes,
		loadSynonyms,
	};

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I inspect the beforeSwap event when rendering results to see if we need to override
	* the swap behavior. If there's no triggering event (ex, load trigger) or there's no
	* submitter (ex, .requestSubmit()), it means that the AJAX request was triggered
	* without a direct user interaction on the parent form. In that case, we don't want
	* the page to automatically scroll down to the form as that would be jarring.
	*/
	function handleBeforeResults( event ) {

		if ( ! event.detail.requestConfig.triggeringEvent?.submitter ) {

			event.detail.swapOverride = "innerHTML";

		}

	}


	/**
	* I trigger a related searches for the given word.
	*/
	function handleRhyme( event ) {

		var word = event.detail.word;

		this.loadSynonyms( word );
		this.loadDefinitions( word );

	}


	/**
	* I trigger a related searches for the given word.
	*/
	function handleSynonym( event ) {

		var word = event.detail.word;

		this.loadRhymes( word );
		this.loadDefinitions( word );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I submit a definition search for the given word.
	*/
	function loadDefinitions( word ) {

		var form = this.$refs.definitionForm;
		var input = form.elements.word;

		input.value = word;
		form.requestSubmit();

	}


	/**
	* I submit a rhyme search for the given word.
	*/
	function loadRhymes( word ) {

		var form = this.$refs.rhymeForm;
		var input = form.elements.word;

		input.value = word;
		form.requestSubmit();

	}


	/**
	* I submit a synonym search for the given word.
	*/
	function loadSynonyms( word ) {

		var form = this.$refs.synonymForm;
		var input = form.elements.word;

		input.value = word;
		form.requestSubmit();

	}

}
