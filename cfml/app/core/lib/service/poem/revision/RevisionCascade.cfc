component {

	// Define properties for dependency-injection.
	property name="revisionModel" ioc:type="core.lib.model.poem.revision.RevisionModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I delete the revisions associated with the given poem.
	*/
	public void function deleteRevisions( required struct poem ) {

		revisionModel.deleteByFilter( poemID = poem.id );

	}

}
