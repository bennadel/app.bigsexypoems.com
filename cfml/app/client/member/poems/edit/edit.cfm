<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

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

	partial = getPartial(
		authContext = request.authContext,
		poemID = val( url.poemID )
	);
	poem = partial.poem;

	title = "Update Poem";
	errorResponse = "";

	request.response.title = title;

	// Initialize form.
	if ( ! form.submitted ) {

		form.name = poem.name;
		form.content = poem.content;

	}

	// Process form.
	if ( form.submitted ) {

		try {

			poemID = poemService.updatePoem(
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

	}

	include "./edit.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial(
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
