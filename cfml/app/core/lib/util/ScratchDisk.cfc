component hint = "I provide access to temporary folders and files for scratch work." {

	// Define properties for dependency-injection.
	property name="rootDirectory" ioc:skip;

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the scratch disk utilities.
	*/
	public void function init() {

		variables.rootDirectory = expandPath( "/upload/temp/" );

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I execute the given callback, passing in a temporary directory that can be used for
	* transient file IO. The temporary directory is deleted, recursively, after the
	* callback has been executed.
	*/
	public any function withDirectory( required function callback ) {

		var path = getNextDirectory();

		try {

			directoryCreate( path );

			return callback( path );

		} finally {

			directoryDelete( path, true );

		}

	}


	/**
	* I execute the given callback, passing in a temporary file with the given name.
	*/
	public any function withFile(
		required string filename,
		required function callback
		) {

		return withDirectory( ( tempDirectory ) => callback( "#tempDirectory#/#filename#" ) );

	}


	/**
	* I execute the given callback, passing in a temporary PNG file.
	*/
	public any function withPngFile( required function callback ) {

		return withFile( "image.png", callback );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I return a uniquely named folder path within the temp directory.
	*/
	private string function getNextDirectory() {

		return "#rootDirectory##createUuid()#";

	}

}
