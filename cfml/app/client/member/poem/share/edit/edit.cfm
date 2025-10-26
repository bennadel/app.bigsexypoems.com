<cfscript>

	// Define properties for dependency-injection.
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	shareAccess = request.ioc.get( "core.lib.service.poem.share.ShareAccess" );
	shareService = request.ioc.get( "core.lib.service.poem.share.ShareService" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.shareID" type="numeric";
	param name="form.name" type="string" default="";
	param name="form.noteMarkdown" type="string" default="";

	partial = getPartial(
		authContext = request.authContext,
		shareID = val( url.shareID )
	);
	poem = partial.poem;
	share = partial.share;
	title = "Edit Share";
	errorResponse = "";

	request.response.title = title;

	if ( request.isGet ) {

		form.name = share.name;
		form.noteMarkdown = share.noteMarkdown;

	}

	if ( request.isPost ) {

		try {

			shareID = shareService.updateShare(
				authContext = request.authContext,
				id = share.id,
				name = form.name,
				noteMarkdown = form.noteMarkdown
			);

			router.goto([
				event: "member.poem.share",
				poemID: poem.id,
				flash: "your.poem.share.updated"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./edit.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial(
		required struct authContext,
		required numeric shareID
		) {

		var context = shareAccess.getContext( authContext, shareID, "canUpdate" );
		var poem = context.poem;
		var share = context.share;

		return {
			poem,
			share
		};

	}

</cfscript>
