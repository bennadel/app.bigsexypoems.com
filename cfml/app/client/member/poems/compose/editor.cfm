<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	poemService = request.ioc.get( "core.lib.service.poem.PoemService" );
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	poemAccess = request.ioc.get( "core.lib.service.poem.PoemAccess" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.poemID" type="numeric";

	payload = getPrimary(
		authContext = request.authContext,
		poemID = val( url.poemID )
	);
	poem = payload.poem;
	title = poem.name;
	errorResponse = "";

	request.response.title = title;

	if ( form.submitted ) {

		try {

			poemService.updatePoem(
				authContext = request.authContext,
				poemID = poem.id,
				poemName = form.name,
				poemContent = form.content
			);

			router.goto([
				event: "member.poems.view",
				poemID: poem.id,
				flash: "member.poem.updated"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	} else {

		form.name = poem.name;
		form.content = poem.content;

	}

	include "./editor.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I provide the primary partial for the view.
	*/
	private struct function getPrimary(
		required struct authContext,
		required numeric poemID
		) {

		var context = poemAccess.getContext( authContext, poemID, "canUpdate" );
		var poem = context.poem;

		return {
			poem
		};

	}

</cfscript>
