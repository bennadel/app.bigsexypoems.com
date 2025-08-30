<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="request.response.statusCode" type="numeric" default=200;

	title = request.errorResponse.title;
	message = request.errorResponse.message;

	request.response.title = title;

	// Use the correct HTTP status code to make sure HTMX doesn't swap the origin target.
	cfheader( statusCode = request.response.statusCode );

	// Reset the output buffer.
	cfcontent( type = "text/html; charset=utf-8" );

	include "./htmx.view.cfm";

</cfscript>
