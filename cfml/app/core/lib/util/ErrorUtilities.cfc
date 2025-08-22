component hint = "I provide utility methods for generating and consuming errors data overloading." {

	// Define properties for dependency-injection.
	property name="causePrefix" ioc:skip;
	property name="metadataPrefix" ioc:skip;

	/**
	* I initialize the error utilities.
	*/
	public void function $init() {

		variables.causePrefix = "data:cause/json,";
		variables.metadataPrefix = "data:metadata/json,";

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I serialize the given error as the root cause to be embedded as an extendInfo
	* property overload.
	*/
	public string function embedCause( required any rootCause ) {

		var liteCause = [
			type: rootCause.type,
			message: rootCause.message,
			detail: rootCause.detail,
			extendedInfo: rootCause.extendedInfo
		];

		return ( causePrefix & serializeJson( liteCause ) );

	}


	/**
	* I serialize the given struct as the metadata to be embedded as an extendInfo
	* property overload.
	*/
	public string function embedMetadata( required struct metadata ) {

		return ( metadataPrefix & serializeJson( metadata ) );

	}


	/**
	* I extract the root cause from the given extendedInfo property overload.
	*/
	public struct function extractCause( required string extendedInfo ) {

		return deserializeJson( extendedInfo.right( -causePrefix.len() ) );

	}


	/**
	* I extract the root cause from the given extendedInfo property overload. If the given
	* property does not contain a cause, a null-error is returned.
	*/
	public struct function extractCauseSafely( required string extendedInfo ) {

		if ( isCause( extendedInfo ) ) {

			return deserializeJson( extendedInfo.right( -causePrefix.len() ) );

		}

		return {
			type: "",
			message: "",
			detail: "",
			extendedInfo: ""
		};

	}


	/**
	* I extract the metadata from the given extendedInfo property overload.
	*/
	public struct function extractMetadata( required string extendedInfo ) {

		return deserializeJson( extendedInfo.right( -metadataPrefix.len() ) );

	}


	/**
	* I extract the metadata from the given extendedInfo property overload. If the given
	* property does not contain metadata, an empty struct is returned.
	*/
	public struct function extractMetadataSafely( required string extendedInfo ) {

		if ( isMetadata( extendedInfo ) ) {

			return deserializeJson( extendedInfo.right( -metadataPrefix.len() ) );

		}

		return {};

	}


	/**
	* I determine if the given extendedInfo error property is being overloaded as a root
	* cause container.
	*/
	public boolean function isCause( required string extendedInfo ) {

		return !! ( extendedInfo.left( causePrefix.len() ) == causePrefix );

	}


	/**
	* I determine if the given extendedInfo error property is being overloaded as a
	* metadata container.
	*/
	public boolean function isMetadata( required string extendedInfo ) {

		return !! ( extendedInfo.left( metadataPrefix.len() ) == metadataPrefix );

	}

}
