
window.nq3j8v = {
	Synonyms,
};

function Synonyms() {

	return {
		handleClick,
	};

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I handle the button click and dispatch the corresponding word.
	*/
	function handleClick( event ) {

		this.$dispatch(
			"app:word",
			{
				word: event.target.textContent
			}
		);

	}

}
