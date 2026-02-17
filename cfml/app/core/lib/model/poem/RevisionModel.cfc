component {

	// Define properties for dependency-injection.
	property name="gateway" ioc:type="core.lib.model.poem.RevisionGateway";
	property name="validation" ioc:type="core.lib.model.poem.RevisionValidation";

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

		// Note: we're not running any validation on these inputs because none of this is
		// user-generated content (revisions are copies of the poem, which has already
		// been validated).
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
		numeric poemID,
		string withSort
		) {

		return gateway.getByFilter( argumentCollection = arguments );

	}


	/**
	* I maybe get the most recent revision for the given poem.
	*/
	public struct function maybeGetMostRecentByPoemID( required numeric poemID ) {

		return maybeArrayFirst( gateway.getMostRecentByPoemID( poemID ) );

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

		// Note: we're not running any validation on these inputs because none of this is
		// user-generated content (revisions are copies of the poem, which has already
		// been validated).
		gateway.update(
			id = id,
			name = name,
			content = content,
			updatedAt = updatedAt
		);

	}

}
