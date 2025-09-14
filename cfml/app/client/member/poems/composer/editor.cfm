<cfscript>

	// Define properties for dependency-injection.
	poemService = request.ioc.get( "core.lib.service.poem.PoemService" );
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	poemAccess = request.ioc.get( "core.lib.service.poem.PoemAccess" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.poemID" type="numeric";

	partial = getPartial(
		authContext = request.authContext,
		poemID = val( url.poemID )
	);
	poem = partial.poem;
	title = "Poem Composer";
	errorResponse = "";

	request.response.title = title;

	if ( request.isGet ) {

		form.name = poem.name;
		form.content = poem.content;

	}

	if ( request.isPost ) {

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
				flash: "your.poem.updated"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./editor.view.cfm";

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
