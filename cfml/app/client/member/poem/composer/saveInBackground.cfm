<cfscript>

	// Define properties for dependency-injection.
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

			poemService.update(
				authContext = request.authContext,
				id = poem.id,
				name = form.name,
				content = form.content
			);

		} catch ( any error ) {

			errorResponse = requestHelper.processErrorForHtmx( error );

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
