<cfscript>

	// Define properties for dependency-injection.
	revisionAccess = request.ioc.get( "core.lib.service.poem.RevisionAccess" );
	revisionModel = request.ioc.get( "core.lib.model.poem.RevisionModel" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.revisionID" type="numeric";

	partial = getPartial(
		authContext = request.authContext,
		revisionID = val( url.revisionID )
	);
	poem = partial.poem;
	revision = partial.revision;
	revisionNumber = partial.revisionNumber;
	revisionCount = partial.revisionCount;
	maybeOlder = partial.maybeOlder;
	maybeNewer = partial.maybeNewer;
	isMatchingLivePoem = ( ! compare( revision.name, poem.name ) && ! compare( revision.content, poem.content ) );
	title = "Revision #revisionNumber# of #revisionCount#";

	request.response.title = title;
	request.response.breadcrumbs.append( request.breadcrumbForPoem( poem ) );
	request.response.breadcrumbs.append( request.breadcrumbForRevisions( poem ) );
	request.response.breadcrumbs.append( title );

	include "./view.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial(
		required struct authContext,
		required numeric revisionID
		) {

		var context = revisionAccess.getContext( authContext, revisionID, "canView" );
		var revision = context.revision;
		var poem = context.poem;

		// Fetch all sibling revisions to compute prev/next navigation and position. The
		// revisions are ordered newest first.
		var siblings = revisionModel.getByFilter( poemID = poem.id );
		var maybeOlder = maybeNew();
		var maybeNewer = maybeNew();
		var revisionNumber = 0;
		var revisionCount = siblings.len();

		for ( var i = 1 ; i <= siblings.len() ; i++ ) {

			if ( siblings[ i ].id == revision.id ) {

				// Chronological numbering: oldest = 1, newest = N.
				revisionNumber = ( siblings.len() - i + 1 );

				// The older revision is the next one in the array (lower index = newer).
				if ( i < siblings.len() ) {

					maybeOlder.set( siblings[ i + 1 ] );

				}

				// The newer revision is the previous one in the array.
				if ( i > 1 ) {

					maybeNewer.set( siblings[ i - 1 ] );

				}

				break;

			}

		}

		return {
			poem,
			revision,
			revisionNumber,
			revisionCount,
			maybeOlder,
			maybeNewer
		};

	}

</cfscript>
