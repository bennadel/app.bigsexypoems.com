<cfscript>

	poemAccess = request.ioc.get( "core.lib.service.poem.PoemAccess" );
	poemService = request.ioc.get( "core.lib.service.poem.PoemService" );
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.poemID" type="numeric";
	param name="form.name" type="string" default="";
	param name="form.content" type="string" default="";

	payload = getPrimary(
		authContext = request.authContext,
		poemID = val( url.poemID )
	);
	poem = payload.poem;

	title = "Update Poem";
	errorResponse = "";

	request.response.title = title;

	if ( form.submitted ) {

		try {

			poemID = poemService.updatePoem(
				authContext = request.authContext,
				poemID = poem.id,
				poemName = form.name.trim(),
				poemContent = form.content.trim()
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

	include "./edit.view.cfm";

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
