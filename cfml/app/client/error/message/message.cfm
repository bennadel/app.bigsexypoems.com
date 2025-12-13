<cfscript>

	// Define properties for dependency-injection.
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="request.errorResponse" type="struct";

	title = request.errorResponse.title;
	message = request.errorResponse.message;

	request.response.title = title;

	include "./message.view.cfm";

</cfscript>
