/**
* CAUTION: The payloads consumed in this service are tightly coupled to the Logger
* service. Which means that when they payloads change shape, the logic here may need to be
* updated or it will (may) break. I am OK with this tight / fragile coupling because this
* is a development-only feature and does NOT have to have production-ready robustness.
*/
component hint = "I provide access to file-based logs in the development environment." {

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I log the given payload to the local log directory.
	*/
	public void function create( required struct payload ) {

		var stub = now().dateTimeFormat( "yyyy-mm-dd-HH-nn-ss" );
		var suffix = lcase( payload.error.type ?: payload.level ?: "unknown" );

		fileWrite(
			file = expandPath( "/log/#stub#-#suffix#.json" ),
			data = serializeJson( payload ),
			charset = "utf-8"
		);

	}


	/**
	* I delete all the log files from the local log directory.
	*/
	public void function deleteAll() {

		for ( var filepath in getFiles() ) {

			fileDelete( filepath );

		}

	}


	/**
	* I get all the log files from the local log directory.
	*/
	public array function getAll() {

		return getFiles().map(
			( filepath ) => {

				var data = simplifyData( parseJsonFile( filepath ) );
				var summary = coalesceTruthy(
					data.error?.message,
					data.error?.type,
					data?.message,
					getFileFromPath( filepath )
				);

				return {
					summary,
					data,
				};

			}
		);

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I get the list of log filepaths (in date descending order - newest first).
	*/
	private array function getFiles() {

		var filepaths = directoryList(
			path = expandPath( "/log" ),
			listInfo = "path",
			filter = "*.json"
		);

		// The files are written using datetime stamps. Which means that when they are
		// listed, they come back in date-ascending order. Since this utility is tightly
		// coupled to DEBUGGING, let's return then in descending order since the developer
		// will almost certainly want to see the newest logs first.
		return filepaths.sort( "textnocase", "desc" );

	}


	/**
	* There's a bug in Adobe ColdFusion in which some JSON payloads are malformed. As
	* such, we need to wrap the JSON parsing in a try-catch so that we don't let these
	* outliers become "poisoned pills" in the log viewer. If the parsing fails, the return
	* will fall-back to using something that is log-viewer-friendly.
	* 
	* Read more:
	* https://www.bennadel.com/blog/4878-java-lang-character-json-bug-in-adobe-coldfusion-2025.htm
	*/
	private struct function parseJsonFile( required string filepath ) {

		var fileContent = fileRead( filepath, "utf-8" );

		try {

			return deserializeJson( fileContent );

		} catch ( any error ) {

			return [
				message: "Could not parse JSON file.",
				filename: getFileFromPath( filepath ),
				json: fileContent
			];

		}

	}


	/**
	* I attempt to simplify the structure of the given data, making it easier for the
	* developer to read (prioritizing higher importance keys at the top by using an
	* ordered struct to recreate the data structure).
	*/
	private struct function simplifyData( required struct data ) {

		var simplified = [:];
		var keys = [
			"error",
			"level",
			"type",
			"message",
			"detail",
			"extendedInfo",
			"tagContext",
			"data",
			"context",
			"url",
			"form",
			"cgi",
		];

		// Prioritize order of selected keys (for visual consumption).
		for ( var key in keys ) {

			if ( ! data.keyExists( key ) ) {

				continue;

			}

			if ( isStruct( data[ key ] ) ) {

				simplified[ key ] = simplifyData( data[ key ] );

			} else {

				simplified[ key ] = data[ key ];

			}

		}

		// Pick up any left-over keys.
		for ( var key in data.keyArray() ) {

			// Special skip-cases.
			switch ( key ) {
				case "errorcode":
				case "stacktrace":
				case "suppressed":
					continue;
				break;
			}

			if ( ! data.keyExists( key ) ) {

				continue;

			}

			if ( simplified.keyExists( key ) ) {

				continue;

			}

			simplified[ key ] = data[ key ];

		}

		return simplified;

	}

}
