<cfscript>

	// Define properties for dependency-injection.
	shareAccess = request.ioc.get( "core.lib.service.poem.share.ShareAccess" );
	shareService = request.ioc.get( "core.lib.service.poem.share.ShareService" );
	viewingModel = request.ioc.get( "core.lib.model.poem.share.ViewingModel" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.shareID" type="numeric";

	partial = getPartial(
		authContext = request.authContext,
		shareID = val( url.shareID )
	);
	poem = partial.poem;
	share = partial.share;
	viewings = partial.viewings;
	isSnapshotStale = shareService.isSnapshotStale( share, poem );
	title = share.name;

	request.response.title = title;
	request.response.breadcrumbs.append( request.breadcrumbForPoem( poem ) );
	request.response.breadcrumbs.append( request.breadcrumbForShareLinks( poem ) );
	request.response.breadcrumbs.append( title );

	include "./view.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial(
		required struct authContext,
		required numeric shareID
		) {

		var context = shareAccess.getContext( authContext, shareID, "canView" );
		var share = context.share;
		var poem = context.poem;

		var viewings = viewingModel
			.getByFilter(
				poemID = poem.id,
				shareID = share.id
			)
			.sort( ( a, b ) => sgn( b.id - a.id ) )
		;

		return {
			poem,
			share,
			viewings
		};

	}

</cfscript>
