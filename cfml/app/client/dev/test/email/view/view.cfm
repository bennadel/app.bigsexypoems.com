<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.templateID" type="string";

	request.response.template = "blank";

	switch ( url.templateID ) {
		case "loginRequest":
			include "./view.view.cfm";
		break;
		default:
			throw( type = "App.NotFound" );
		break;
	}

</cfscript>
