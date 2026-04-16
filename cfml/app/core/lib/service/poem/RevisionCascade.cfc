component {

	// Define properties for dependency-injection.
	property name="revisionModel" ioc:type="core.lib.model.poem.RevisionModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I delete the given revision and any data that's logically contained under it.
	* 
	* Caution: this method must be called within a transaction block. All withLock usage
	* contained herein will be scoped to said transaction block and will create mutual
	* exclusion with other row-locking workflows. All passed-in entities must be locked.
	*/
	public void function delete(
		required struct user,
		required struct poem,
		required struct revision
		) {

		revisionModel.deleteByFilter( id = revision.id );

	}

}
