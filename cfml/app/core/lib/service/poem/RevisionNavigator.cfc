component {

	// Define properties for dependency-injection.
	property name="revisionModel" ioc:type="core.lib.model.poem.RevisionModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I get the position of the given revision within its sibling revisions. Returns the
	* chronological revision number, total count, and maybe-links to older/newer siblings.
	*/
	public struct function getPosition( required struct revision ) {

		var siblings = revisionModel
			.getByFilter( poemID = revision.poemID )
			.sort( ( a, b ) => sgn( b.id - a.id ) )
		;

		var i = siblings.find( ( element ) => ( element.id == revision.id ) );
		// The siblings are sorted newest-first. As such, the revision number is the
		// inverse of the index (index 1 is actually the highest revision number).
		var revisionCount = siblings.len();
		var revisionNumber = ( revisionCount - i + 1 );
		var maybeOlder = maybeNew( siblings[ i + 1 ] ?: nullValue() );
		var maybeNewer = maybeNew( siblings[ i - 1 ] ?: nullValue() );

		return {
			revisionNumber,
			revisionCount,
			maybeOlder,
			maybeNewer
		};

	}

}
