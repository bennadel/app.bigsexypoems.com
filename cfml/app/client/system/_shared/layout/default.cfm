<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="request.response.statusCode" type="numeric" default=200;
	param name="request.response.title" type="string";
	param name="request.response.body" type="string";

	// Use the correct HTTP status code.
	cfheader( statusCode = request.response.statusCode );

	// Reset the output buffer.
	cfcontent( type = "text/html; charset=utf-8" );

	include "./default.view.cfm";

</cfscript>
