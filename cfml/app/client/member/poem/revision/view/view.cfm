<cfscript>

	// Define properties for dependency-injection.
	revisionAccess = request.ioc.get( "core.lib.service.poem.RevisionAccess" );
	revisionNavigator = request.ioc.get( "core.lib.service.poem.RevisionNavigator" );
	revisionService = request.ioc.get( "core.lib.service.poem.RevisionService" );
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
	position = partial.position;
	maybeOlder = position.maybeOlder;
	maybeNewer = position.maybeNewer;
	isRevisionStale = revisionService.isRevisionStale( revision, poem );
	title = "Revision #position.revisionNumber# of #position.revisionCount#";

	request.response.title = title;
	request.response.breadcrumbs.append( request.breadcrumbForPoem( poem ) );
	request.response.breadcrumbs.append( request.breadcrumbForRevisions( poem ) );
	request.response.breadcrumbs.append( request.breadcrumbForRevision( revision, position ) );

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
		var position = revisionNavigator.getPosition( revision );

		return {
			poem,
			revision,
			position
		};

	}

</cfscript>
