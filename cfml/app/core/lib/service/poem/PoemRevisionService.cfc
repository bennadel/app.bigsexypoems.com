component {

	// Define properties for dependency-injection.
	property name="poemAccess" ioc:type="core.lib.service.poem.PoemAccess";
	property name="poemRevisionModel" ioc:type="core.lib.model.poem.revision.PoemRevisionModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create an initial revision for a newly created poem.
	*/
	public numeric function createInitialRevision(
		required numeric poemID,
		required string content,
		required date createdAt
		) {

		return poemRevisionModel.create(
			poemID = poemID,
			revisionNumber = 1,
			content = content,
			createdAt = createdAt
		);

	}


	/**
	* I create a revision for the given poem if the content has changed since the last
	* revision.
	*/
	public void function createRevision(
		required struct authContext,
		required numeric poemID
		) {

		var context = poemAccess.getContext( authContext, poemID, "canUpdate" );
		var poem = context.poem;

		var latestRevision = poemRevisionModel.getLatestByPoemID( poemID );

		// No-op guard: skip if content hasn't changed since the last revision.
		if (
			! latestRevision.isEmpty() &&
			! compare( poem.content, latestRevision.content )
			) {

			return;

		}

		var nextRevisionNumber = poemRevisionModel.getNextRevisionNumber( poemID );

		poemRevisionModel.create(
			poemID = poemID,
			revisionNumber = nextRevisionNumber,
			content = poem.content,
			createdAt = utcNow()
		);

	}

}
