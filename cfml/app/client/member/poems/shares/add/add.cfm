<cfscript>

	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	shareAccess = request.ioc.get( "core.lib.service.poem.share.ShareAccess" );
	shareService = request.ioc.get( "core.lib.service.poem.share.ShareService" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.poemID" type="numeric";

	payload = getPrimary(
		authContext = request.authContext,
		poemID = val( url.poemID )
	);
	poem = payload.poem;
	title = "Create New Share";
	errorResponse = "";

	request.response.title = title;

	if ( form.submitted ) {

		try {

			shareID = shareService.createShare(
				authContext = request.authContext,
				poemID = poem.id
			);

			router.goto([
				event: "member.poems.shares",
				poemID: poem.id,
				flash: "member.poem.shareLink.created"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./add.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I provide the primary partial for the view.
	*/
	private struct function getPrimary(
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
