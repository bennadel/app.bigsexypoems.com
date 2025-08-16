<cfscript>

	param name="request.response.statusCode" type="numeric" default=200;
	param name="request.response.statusText" type="string" default="OK";
	param name="request.response.title" type="string";
	param name="request.response.body" type="string";

	// Use the correct HTTP status code.
	cfheader(
		statusCode = request.response.statusCode,
		statusText = request.response.statusText
	);

	// Reset the output buffer.
	cfcontent( type = "text/html; charset=utf-8" );

	include "./layout.view.cfm";

</cfscript>
