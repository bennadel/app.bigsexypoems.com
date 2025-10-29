<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="request.errorResponse" type="struct";

	request.response.hxTrigger = {
		"app:toast": {
			message: request.errorResponse.message,
			isError: true
		}
	};

	include "./htmx.view.cfm";

</cfscript>
