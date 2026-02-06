<cfscript>

	// Define properties for dependency-injection.
	shareAccess = request.ioc.get( "core.lib.service.poem.share.ShareAccess" );
	shareModel = request.ioc.get( "core.lib.model.poem.share.ShareModel" );
	shareService = request.ioc.get( "core.lib.service.poem.share.ShareService" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.poemID" type="numeric";

	partial = getPartial(
		authContext = request.authContext,
		poemID = val( url.poemID )
	);
	poem = partial.poem;
	shares = partial.shares;
	title = poem.name;

	request.response.title = title;
	request.response.breadcrumbs.append( request.breadcrumbForPoem( poem ) );
	request.response.breadcrumbs.append( request.breadcrumbForShareLinks( poem ) );
	// Note: no terminal breadcrumb for default views.

	include "./list.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial(
		required struct authContext,
		required numeric poemID
		) {

		var context = shareAccess.getContextForParent( authContext, poemID, "canViewAny" );
		var poem = context.poem;
		var shares = shareModel.getByFilter( poemID = poem.id );

		// Inject isOutdated property for snapshot shares.
		for ( var share in shares ) {

			share.isOutdated = shareService.isSnapshotStale( share, poem );

		}

		return {
			poem,
			shares
		};

	}

</cfscript>
