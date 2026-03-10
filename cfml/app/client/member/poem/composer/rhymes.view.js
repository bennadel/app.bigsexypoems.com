
window.rk4m2t = {
	Rhymes,
};

function Rhymes() {

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
