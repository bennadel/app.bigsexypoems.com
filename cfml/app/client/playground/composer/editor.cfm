<cfscript>

	// Define properties for dependency-injection.
	config = request.ioc.get( "config" );
	router = request.ioc.get( "core.lib.web.Router" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	localStorageKey = "playground-poem";

	if ( request.isPost ) {

		// Todo: if the user isn't logged-in (request.authContent.session.isAuthenticated),
		// we might want to send them to an intersticial page before the login form in
		// order to give them some more context about the workflow. But, for now, everyone
		// goes directly to the login form.

		router.goto([
			event: "member.poem.add",
			importFrom: localStorageKey
		]);

	}

	request.response.title = config.site.name;

	include "./editor.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I return the default poem to be used if nothing has been persisted.
	*/
	public string function getDefaultPoem() {

		var lines = [
			"Roses are red and violets are blue,",
			"Let BigSexy find the poet in you!",
			"",
			"... Syllables show up to the right as you type #canonicalize( '&##x2192;', true, true )#",
			"",
			"... Rhymes and Synonyms can be searched below #canonicalize( '&##x2193;', true, true )#"
		];

		return lines.toList( chr( 10 ) );

	}

</cfscript>
