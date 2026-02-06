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
	param name="form.isConfirmed" type="boolean" default=false;

	partial = getPartial(
		authContext = request.authContext,
		shareID = val( url.shareID )
	);
	poem = partial.poem;
	share = partial.share;
	title = "Refresh Snapshot";
	errorResponse = "";

	request.response.title = title;
	request.response.breadcrumbs.append( request.breadcrumbForPoem( poem ) );
	request.response.breadcrumbs.append( request.breadcrumbForShareLinks( poem ) );
	request.response.breadcrumbs.append( request.breadcrumbForShare( share ) );
	request.response.breadcrumbs.append( "Refresh" );

	if ( request.isPost ) {

		try {

			if ( ! form.isConfirmed ) {

				throw( type = "App.ConfirmationRequired" );

			}

			shareService.refreshSnapshot(
				authContext = request.authContext,
				id = share.id
			);

			router.goto([
				event: "member.poem.share.view",
				shareID: share.id,
				flash: "your.poem.share.snapshotRefreshed"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./refresh.view.cfm";

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
