component {

	// Define properties for dependency-injection.
	property name="revisionModel" ioc:type="core.lib.model.poem.RevisionModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I delete the given revision.
	*/
	public void function deleteRevision( required struct revision ) {

		revisionModel.deleteByFilter( id = revision.id );

	}

}
