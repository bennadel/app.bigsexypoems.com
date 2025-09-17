
window.z6s31p = {
	ProseContent
};

function ProseContent() {

	return {
		// Properties.
		lineCount: 0,
		// Life-Cycle Methods.
		init,
		// Private Methods.
		resizeContent,
	};

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I initialize the component.
	*/
	function init() {

		this.resizeContent();

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I update the textarea height to match the text height (within reason).
	*/
	function resizeContent() {

		var lineBreaks = this.$el.value.match( /\r\n?|\n/g );
		var lineCount = ( lineBreaks === null )
			? 1
			: ( lineBreaks.length + 1 )
		;

		// Only attempt resize if the line-count has changed.
		if ( this.lineCount === lineCount ) {

			return;

		}

		this.lineCount = lineCount;
		// Setting the height to 0 will get the browser to resize the textarea to it's
		// smallest possible dimensions (taking into account the min-height property).
		this.$el.style.height = 0;
		// Then, reading the scrollHeight will force a repaint and will give us the actual
		// height of the content, which we then store back into the element. Thankfully,
		// this control-flow doesn't appear to cause any UI flashing on the desktop.
		this.$el.style.height = `${ this.$el.scrollHeight }px`;

	}

}
