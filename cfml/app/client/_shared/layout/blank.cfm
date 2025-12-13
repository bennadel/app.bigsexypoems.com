<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="request.response.body" type="string" default="";

	// Include common HTTP response headers.
	cfmodule( template = "./http/headers.cfm" );
	cfmodule( template = "./http/headersForHtmx.cfm" );

	// Reset the output buffer.
	cfcontent( type = "text/html; charset=utf-8" );

	// Send down the response.
	echo( request.response.body );

</cfscript>
