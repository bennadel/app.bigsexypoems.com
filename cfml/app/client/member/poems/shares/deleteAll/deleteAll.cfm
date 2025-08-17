<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	shareAccess = request.ioc.get( "core.lib.service.poem.share.ShareAccess" );
	shareService = request.ioc.get( "core.lib.service.poem.share.ShareService" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.poemID" type="numeric";
	param name="form.isConfirmed" type="boolean" default=false;

	payload = getPrimary(
		authContext = request.authContext,
		poemID = val( url.poemID )
	);
	poem = payload.poem;
	title = "Delete All Shares";
	errorResponse = "";

	request.response.title = title;

	if ( form.submitted ) {

		try {

			if ( ! form.isConfirmed ) {

				throw( type = "App.ConfirmationRequired" );

			}

			shareService.deleteSharesForPoem(
				authContext = request.authContext,
				poemID = poem.id
			);

			router.goto([
				event: "member.poems.shares",
				poemID: poem.id,
				flash: "member.poem.shareLink.allDeleted"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./deleteAll.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I provide the primary partial for the view.
	*/
	private struct function getPrimary(
		required struct authContext,
		required numeric poemID
		) {

		var context = shareAccess.getContextForParent( authContext, poemID, "canDelete" );
		var poem = context.poem;

		return {
			poem
		};

	}

</cfscript>
