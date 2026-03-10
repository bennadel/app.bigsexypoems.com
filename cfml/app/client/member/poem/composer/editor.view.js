
window.z6s31p = {
	WordTools,
};

function WordTools() {

	return {
		// Public methods.
		handleRhyme,
		handleSynonym,

		// Private methods.
		loadDefinitions,
		loadRhymes,
	};

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I trigger a related searches for the given word.
	*/
	function handleRhyme( event ) {

		var word = event.detail.word;

		this.loadDefinitions( word );
		// this.loadRhymes( word );

	}


	/**
	* I trigger a related searches for the given word.
	*/
	function handleSynonym( event ) {

		var word = event.detail.word;

		this.loadDefinitions( word );
		// this.loadRhymes( word );

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

}
