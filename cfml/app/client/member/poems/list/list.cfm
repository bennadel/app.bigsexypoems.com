<cfscript>

	// poemAccess = request.ioc.get( "core.lib.service.poem.PoemAccess" );
	poemModel = request.ioc.get( "core.lib.model.poem.PoemModel" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	payload = getPrimary( authContext = request.authContext );
	poems = payload.poems;
	title = "Poems";

	request.response.title = title;
	request.response.activeNav = "poems";

	include "./list.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I provide the primary partial for the view.
	*/
	private struct function getPrimary( required struct authContext ) {

		var poems = poemModel
			.getByFilter( userID = authContext.user.id )
			.sort( ( a, b ) => compareNoCase( a.name, b.name ) )
		;

		return {
			poems
		};

	}

</cfscript>
