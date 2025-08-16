<cfscript>

	poemAccess = request.ioc.get( "core.lib.service.poem.PoemAccess" );
	poemService = request.ioc.get( "core.lib.service.poem.PoemService" );
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
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

	title = "Delete Poem";
	errorResponse = "";

	request.response.title = title;

	if ( form.submitted ) {

		try {

			if ( ! form.isConfirmed ) {

				throw( type = "App.ConfirmationRequired" );

			}

			// Todo: requestHelper.testFormToken( form.formToken );
			poemService.deletePoem(
				authContext = request.authContext,
				poemID = poem.id
			);

			router.goto([
				event: "member.poems",
				flash: "member.poem.deleted"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./delete.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I provide the primary partial for the view.
	*/
	private struct function getPrimary(
		required struct authContext,
		required numeric poemID
		) {

		var context = poemAccess.getContext( authContext, poemID, "canDelete" );
		var poem = context.poem;

		return {
			poem
		};

	}

</cfscript>
