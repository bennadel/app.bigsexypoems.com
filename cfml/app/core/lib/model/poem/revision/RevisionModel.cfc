component {

	// Define properties for dependency-injection.
	property name="gateway" ioc:type="core.lib.model.poem.revision.RevisionGateway";
	property name="validation" ioc:type="core.lib.model.poem.revision.RevisionValidation";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create a new revision.
	*/
	public numeric function create(
		required numeric poemID,
		required string name,
		required string content,
		required date createdAt
		) {

		return gateway.create(
			poemID = poemID,
			name = name,
			content = content,
			createdAt = createdAt,
			updatedAt = createdAt
		);

	}


	/**
	* I delete the revisions that match the given filters.
	*/
	public void function deleteByFilter(
		numeric id,
		numeric poemID
		) {

		gateway.deleteByFilter( argumentCollection = arguments );

	}


	/**
	* I get a revision by ID.
	*/
	public struct function get( required numeric id ) {

		var results = getByFilter( argumentCollection = arguments );

		if ( ! results.len() ) {

			validation.throwNotFoundError();

		}

		return results.first();

	}


	/**
	* I get the revisions that match the given filters.
	*/
	public array function getByFilter(
		numeric id,
		numeric poemID
		) {

		return gateway.getByFilter( argumentCollection = arguments );

	}


	/**
	* I get the most recent revision for the given poem.
	*/
	public struct function getMostRecentByPoemID( required numeric poemID ) {

		var results = gateway.getMostRecentByPoemID( poemID );

		if ( results.len() ) {

			return results.first();

		}

		return {};

	}


	/**
	* I update a revision.
	*/
	public void function update(
		required numeric id,
		required string name,
		required string content,
		required date updatedAt
		) {

		gateway.update(
			id = id,
			name = name,
			content = content,
			updatedAt = updatedAt
		);

	}

}
