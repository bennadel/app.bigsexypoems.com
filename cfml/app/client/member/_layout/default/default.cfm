<cfscript>

	ui = request.ioc.get( "core.lib.web.UI" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="request.response.statusCode" type="numeric" default=200;
	param name="request.response.statusText" type="string" default="OK";
	param name="request.response.title" type="string";
	param name="request.response.body" type="string";
	param name="request.response.activeNav" type="string" default="";

	user = request.authContext.user;

	// Use the correct HTTP status code.
	cfheader(
		statusCode = request.response.statusCode,
		statusText = request.response.statusText
	);

	// Reset the output buffer.
	cfcontent( type = "text/html; charset=utf-8" );

	include "./default.view.cfm";

</cfscript>
