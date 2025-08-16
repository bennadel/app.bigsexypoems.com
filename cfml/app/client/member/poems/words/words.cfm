<cfscript>

	router = request.ioc.get( "core.lib.web.Router" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// None of the views in this HTMX module need a template.
	request.response.template = "blank";

	switch ( router.next() ) {
		case "rhymes":
			cfmodule( template = "./rhymes/rhymes.cfm" );
		break;
		case "synonyms":
			cfmodule( template = "./synonyms/synonyms.cfm" );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

</cfscript>
