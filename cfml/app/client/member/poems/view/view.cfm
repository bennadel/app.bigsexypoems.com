<cfscript>

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

	request.response.title = title;

	include "./view.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I provide the primary partial for the view.
	*/
	private struct function getPrimary(
		required struct authContext,
		required numeric poemID
		) {

		var context = poemAccess.getContext( authContext, poemID, "canView" );
		var poem = context.poem;

		return {
			poem
		};

	}

</cfscript>
