component {

	// Define properties for dependency-injection.
	property name="WINDOW_IN_SECONDS" ioc:skip;
	property name="revisionModel" ioc:type="core.lib.model.poem.revision.RevisionModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the service.
	*/
	public void function init() {

		variables.WINDOW_IN_SECONDS = 120;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I get a specific revision.
	*/
	public struct function get(
		required numeric id,
		required numeric poemID
		) {

		var results = revisionModel.getByFilter( id = id, poemID = poemID );

		if ( ! results.len() ) {

			revisionModel.get( 0 ); // Trigger not-found error.

		}

		return results.first();

	}


	/**
	* I get all revisions for the given poem.
	*/
	public array function getByPoemID( required numeric poemID ) {

		return revisionModel.getByFilter( poemID = poemID );

	}


	/**
	* I save a revision for the given poem. If the most recent revision was updated within
	* the windowing period, I update it in place. Otherwise, I create a new revision.
	*/
	public void function saveRevision(
		required numeric poemID,
		required string name,
		required string content
		) {

		var now = utcNow();
		var lastRevision = revisionModel.getMostRecentByPoemID( poemID );

		// If there's no previous revision, or the window has closed, create a new one.
		if (
			lastRevision.isEmpty() ||
			dateDiff( "s", lastRevision.updatedAt, now ) >= WINDOW_IN_SECONDS
			) {

			revisionModel.create(
				poemID = poemID,
				name = name,
				content = content,
				createdAt = now
			);

		// Otherwise, update the existing revision within the window.
		} else {

			revisionModel.update(
				id = lastRevision.id,
				name = name,
				content = content,
				updatedAt = now
			);

		}

	}

}
