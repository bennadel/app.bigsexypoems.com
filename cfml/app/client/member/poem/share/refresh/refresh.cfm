<cfscript>

	// Define properties for dependency-injection.
	myersDiff = request.ioc.get( "core.lib.util.MyersDiff" );
	poemService = request.ioc.get( "core.lib.service.poem.PoemService" );
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

	diffOperations = getDiffResult( poem, share );

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


	/**
	* I compute the line-by-line diff between the snapshot and live poem.
	*/
	private array function getDiffResult(
		required struct poem,
		required struct share
		) {

		// Prepend title as first line so title changes appear in the diff naturally.
		var snapshotLines = poemService.splitLines( share.snapshotContent );
		snapshotLines.prepend( "" );
		snapshotLines.prepend( share.snapshotName );

		var poemLines = poemService.splitLines( poem.content );
		poemLines.prepend( "" );
		poemLines.prepend( poem.name );

		var lineDiff = myersDiff.diffElements(
			original = snapshotLines,
			modified = poemLines
		);

		// Add word-level tokens for single-line mutations.
		return myersDiff.tokenizeOperations( lineDiff.operations );

	}

</cfscript>
