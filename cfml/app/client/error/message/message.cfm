<cfscript>

	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	errorResponse = requestHelper.processError( request.error );
	title = errorResponse.title;
	message = errorResponse.message;

	request.response.title = title;

	include "./message.view.cfm";

</cfscript>
