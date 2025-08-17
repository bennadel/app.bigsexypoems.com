<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	shareAccess = request.ioc.get( "core.lib.service.poem.share.ShareAccess" );
	shareModel = request.ioc.get( "core.lib.model.poem.share.ShareModel" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.poemID" type="numeric";

	payload = getPrimary(
		authContext = request.authContext,
		poemID = val( url.poemID )
	);
	poem = payload.poem;
	shares = payload.shares;
	title = poem.name;

	request.response.title = title;

	include "./list.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I provide the primary partial for the view.
	*/
	private struct function getPrimary(
		required struct authContext,
		required numeric poemID
		) {

		var context = shareAccess.getContextForParent( authContext, poemID, "canViewAny" );
		var poem = context.poem;
		var shares = shareModel.getByFilter( poemID = poem.id );

		return {
			poem,
			shares
		};

	}

</cfscript>
