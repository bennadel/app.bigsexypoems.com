<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="request.errorResponse" type="struct";

	// Use the correct HTTP status code (for the error) in order to make sure HTMX doesn't
	// swap the origin target with the error content.
	cfheader( statusCode = request.errorResponse.statusCode );

	cfheader(
		name = "HX-Trigger",
		value = serializeJson({
			"app:toast": {
				message: request.errorResponse.message,
				isError: true
			}
		})
	);

	// Reset the output buffer.
	cfcontent( type = "text/html; charset=utf-8" );

	include "./htmx.view.cfm";

</cfscript>
