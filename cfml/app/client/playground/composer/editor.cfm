<cfscript>

	// Define properties for dependency-injection.
	config = request.ioc.get( "config" );
	router = request.ioc.get( "core.lib.web.Router" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="form.content" type="string" default=getDefaultPoem();

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
