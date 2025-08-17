<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	errorResponse = requestHelper.processError( request.error );
	title = errorResponse.title;
	message = errorResponse.message;

	request.response.title = title;

	include "./message.view.cfm";

</cfscript>
