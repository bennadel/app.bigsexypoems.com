<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="request.response.statusCode" type="numeric" default=200;
	param name="request.response.body" type="string" default="";

	// Override the response status code.
	cfheader( statusCode = request.response.statusCode );

	// Reset the output buffer and send response.
	cfcontent(
		type = "text/html; charset=utf-8",
		variable = charsetDecode( request.response.body, "utf-8" )
	);

</cfscript>
