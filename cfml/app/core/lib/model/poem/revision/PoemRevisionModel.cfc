component {

	// Define properties for dependency-injection.
	property name="gateway" ioc:type="core.lib.model.poem.revision.PoemRevisionGateway";
	property name="validation" ioc:type="core.lib.model.poem.revision.PoemRevisionValidation";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create a new model.
	*/
	public numeric function create(
		required numeric poemID,
		required numeric revisionNumber,
		required string content,
		required date createdAt
		) {

		content = validation.contentFrom( content );

		return gateway.create(
			poemID = poemID,
			revisionNumber = revisionNumber,
			content = content,
			createdAt = createdAt
		);

	}


	/**
	* I delete the models that match the given filters.
	*/
	public void function deleteByFilter(
		numeric id,
		numeric poemID
		) {

		gateway.deleteByFilter( argumentCollection = arguments );

	}


	/**
	* I get the models that match the given filters.
	*/
	public array function getByFilter(
		numeric id,
		numeric poemID
		) {

		return gateway.getByFilter( argumentCollection = arguments );

	}


	/**
	* I get the latest revision for the given poem. Returns an empty struct if no
	* revisions exist.
	*/
	public struct function getLatestByPoemID( required numeric poemID ) {

		var results = gateway.getLatestByPoemID( poemID );

		return maybeArrayFirst( results );

	}


	/**
	* I get the next revision number for the given poem.
	*/
	public numeric function getNextRevisionNumber( required numeric poemID ) {

		return gateway.getNextRevisionNumber( poemID );

	}

}
