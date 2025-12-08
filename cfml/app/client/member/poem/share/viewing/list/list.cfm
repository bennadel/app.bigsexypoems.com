<cfscript>

	// Define properties for dependency-injection.
	viewingAccess = request.ioc.get( "core.lib.service.poem.share.ViewingAccess" );
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
	title = "Viewings For #share.name#";

	request.response.title = title;
	request.response.breadcrumbs.append( request.breadcrumbForPoem( poem ) );
	request.response.breadcrumbs.append( request.breadcrumbForShareLinks( poem ) );
	request.response.breadcrumbs.append( "Viewings" );

	include "./list.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial(
		required struct authContext,
		required numeric shareID
		) {

		var context = viewingAccess.getContextForParent( authContext, shareID, "canViewAny" );
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
