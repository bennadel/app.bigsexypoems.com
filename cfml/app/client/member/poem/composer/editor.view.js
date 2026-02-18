
window.z6s31p = {
	WordTools,
};

function WordTools() {

	return {
		handleSynonym,
	};

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I trigger a rhyme search for the given word.
	*/
	function handleSynonym( event ) {

		var form = this.$refs.rhymeForm;
		var input = form.elements.word;
		var word = event.detail.word;

		input.value = word;
		form.requestSubmit();

	}

}
