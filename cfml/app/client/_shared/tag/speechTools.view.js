
window.rifvd5 = {
	SpeechTools
};

function SpeechTools( inputID ) {

	var localStorageKey = "speechTools-settings";
	var timer = null;

	return {
		// Properties.
		isSpeaking: false,
		selectedName: "",
		selectedRate: 0.9,
		voices: [],
		// Life-cycle methods.
		init,
		// Public methods.
		handleToggle,
		handleVoice,
		// Private methods.
		getSourceText,
		loadSettings,
		loadVoices,
		start,
		stop,
		storeSettings,
	};

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I initialize the component.
	*/
	function init() {

		this.loadSettings();
		this.loadVoices();

		// The voices are sometimes delayed. Watch for the change event and reload the
		// voices if they become available.
		speechSynthesis.addEventListener( "voiceschanged", ( event ) => {

			this.loadVoices();

		});

		// Stop playing voice synthesis when page is unloaded. Since the voice synthesis
		// API is part of the browser, not the app, it will continue playing even if the
		// user navigates away from the current page. As such, if the page is hidden, we
		// need to stop playing any active utterance.
		window.addEventListener( "pagehide", ( event ) => {

			this.stop();

		});

		// Stop playing voice synthesis when page becomes invisible (ie, user changes to a
		// different tab). This is a bit of a judgement call; but if the page is hidden,
		// I want to stop the playing as well.
		window.addEventListener( "visibilitychange", ( event ) => {

			this.stop();

		});

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I handle the toggle button click.
	*/
	function handleToggle() {

		if ( this.isSpeaking ) {

			this.stop();

		} else {

			this.start();

		}

	}


	/**
	* I handle the voice selection.
	*/
	function handleVoice() {

		this.selectedName = this.$refs.voiceSelect.value;
		this.storeSettings();
		this.stop();
		this.start();

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I get the text to read from the source input.
	*/
	function getSourceText( allowSubstring = false ) {

		var node = document.querySelector( `#${ inputID }` );

		if ( ! node || ! node.value ) {

			return "";

		}

		// Note: this substring check is a noop at the moment because it wasn't always
		// clear (visually) what parts of the text were selected. But, I'm leaving it in
		// because I like the idea; but it will need some refinement to work as I might
		// hope.
		if ( allowSubstring && ( node.selectionStart != node.selectionEnd ) ) {

			return node.value
				.slice( node.selectionStart, node.selectionEnd )
				.trim()
			;

		}

		return node.value.trim();

	}


	/**
	* I load the stored settings into the current runtime.
	*/
	function loadSettings() {

		try {

			var settings = JSON.parse( localStorage.getItem( localStorageKey ) )
				|| {}
			;

			this.selectedName = ( settings.name || this.selectedName );
			// Tood: allow user to select playback rate.
			// this.selectedRate = ( settings.rate || this.selectedRate );

		} catch ( error ) {

			console.warn( "Couldn't parse voice tool settings." );
			console.error( error );

		}

	}


	/**
	* I load the voice options.
	*/
	function loadVoices() {

		// Note: since this tool has been built to be catered to the English language, I'm
		// only loading the voices that will work well(er) with English words.
		this.voices = speechSynthesis
			.getVoices()
			.filter( ( voice ) => voice.lang.startsWith( "en-" ) )
			.sort( ( a, b ) => a.name.localeCompare( b.name ) )
		;

	}


	/**
	* I start the reading of the input text.
	*/
	function start() {

		var text = this.getSourceText();

		if ( ! text ) {

			return;

		}

		var utterance = new SpeechSynthesisUtterance( text );
		utterance.rate = this.selectedRate;
		utterance.voice = this.voices.find(
			( voice ) => ( voice.name === this.$refs.voiceSelect.value )
		);

		speechSynthesis.speak( utterance );

		// Start watching the synthesis API to see if the speaking has stopped. Since the
		// interaction with the API might happen outside of our control, I think it might
		// just be best to brute-force it, and have the timer clear itself.
		timer = setInterval(
			() => {

				this.isSpeaking = speechSynthesis.speaking;

				if ( ! this.isSpeaking ) {

					clearInterval( timer );

				}

			},
			100
		);

	}


	/**
	* I stop the reading of the input text.
	*/
	function stop() {

		speechSynthesis.cancel();

	}


	/**
	* I store the speech settings to be applied on page reload. 
	*/
	function storeSettings() {

		try {

			localStorage.setItem(
				localStorageKey,
				JSON.stringify({
					name: this.selectedName,
					rate: this.selectedRate,
				})
			);

		} catch ( error ) {

			console.warn( "Couldn't store voice tool settings." );
			console.error( error );

		}

	}

}
