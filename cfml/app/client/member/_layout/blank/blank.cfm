<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	param name="request.response.statusCode" type="numeric" default=200;
	param name="request.response.statusText" type="string" default="OK";
	param name="request.response.body" type="string" default="";

	// Override the response status code.
	cfheader(
		statusCode = request.response.statusCode,
		statusText = request.response.statusText
	);

	writeOutput( request.response.body );

</cfscript>
