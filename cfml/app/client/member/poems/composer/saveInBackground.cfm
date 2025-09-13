<cfscript>

	poemService = request.ioc.get( "core.lib.service.poem.PoemService" );
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	poemAccess = request.ioc.get( "core.lib.service.poem.PoemAccess" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.poemID" type="numeric";
	param name="form.name" type="string";
	param name="form.content" type="string";

	partial = getPartial(
		authContext = request.authContext,
		poemID = val( url.poemID )
	);
	poem = partial.poem;
	errorResponse = "";

	request.response.template = "blank";

	if (
		request.isPost &&
		// Since the request is being triggered by JavaScript events, I just want to cut
		// down on any unnecessary database writes.
		( compare( form.name, poem.name ) || compare( form.content, poem.content ) )
		) {

		try {

			poemService.updatePoem(
				authContext = request.authContext,
				poemID = poem.id,
				poemName = form.name,
				poemContent = form.content
			);

		} catch ( any error ) {

			// Note: since this save is entirely in the background, it's easiest to just
			// always return 200 OK and output an error message via the swap. This is why
			// I'm using a different processing method (doesn't change status code).
			errorResponse = requestHelper.processErrorForHtmx( error );

			// Todo: this is NOT the right place for this. This should be a setting on
			// the template rendering. But, putting this here while I discover patterns.
			cfheader(
				name = "HX-Trigger",
				value = serializeJson({
					"app:toast": {
						message: errorResponse.message,
						isError: true
					}
				})
			);

		}

	}

	include "./saveInBackground.view.cfm";

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
