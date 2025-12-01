
window.r2mwmx = {
	ProseContent
};

function ProseContent( localStorageKey ) {

	return {
		// Properties.
		storageKey: localStorageKey,
		// Life-Cycle Methods.
		init,
		// Public Methods.
		loadContent,
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
