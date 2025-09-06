<cfscript>

	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	shareAccess = request.ioc.get( "core.lib.service.poem.share.ShareAccess" );
	shareService = request.ioc.get( "core.lib.service.poem.share.ShareService" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.poemID" type="numeric";
	param name="form.name" type="string" default="";
	param name="form.noteMarkdown" type="string" default="";

	partial = getPartial(
		authContext = request.authContext,
		poemID = val( url.poemID )
	);
	poem = partial.poem;
	title = "Create New Share";
	errorResponse = "";

	request.response.title = title;

	if ( request.isPost ) {

		try {

			shareID = shareService.createShare(
				authContext = request.authContext,
				poemID = poem.id,
				shareName = form.name,
				shareNoteMarkdown = form.noteMarkdown
			);

			router.goto([
				event: "member.poems.shares",
				poemID: poem.id,
				flash: "your.poem.share.created"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./add.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial(
		required struct authContext,
		required numeric poemID
		) {

		var context = shareAccess.getContextForParent( authContext, poemID, "canCreateAny" );
		var poem = context.poem;

		return {
			poem
		};

	}

</cfscript>
