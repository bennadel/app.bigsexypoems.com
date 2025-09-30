
window.r2mwmx = {
	ProseContent
};

function ProseContent() {

	return {
		// Properties.
		lineCount: 0,
		storageKey: "playground-poem",
		// Life-Cycle Methods.
		init,
		// Public Methods.
		loadContent,
		resizeContent,
		saveContent,
	};

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I initialize the component.
	*/
	function init() {

		this.loadContent();
		this.resizeContent();

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I load any persisted poem from LocalStorage into the element.
	*/
	function loadContent() {

		try {

			this.$el.value = ( localStorage.getItem( this.storageKey ) || this.$el.dataset.defaultValue );

		} catch ( error ) {

			console.warn( "Couldn't load poem from local storage." );
			console.error( error );

		}

	}


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


	/**
	* I persist the poem to the localStorage for future loads.
	*/
	function saveContent() {

		try {

			localStorage.setItem( this.storageKey, this.$el.value );

		} catch ( error ) {

			console.warn( "Couldn't persist poem to local storage." );
			console.error( error );

		}

	}

}
