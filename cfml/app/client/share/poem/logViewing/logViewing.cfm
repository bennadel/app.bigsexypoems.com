<cfscript>

	// Define properties for dependency-injection.
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	shareService = request.ioc.get( "core.lib.service.poem.share.ShareService" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	errorResponse = "";

	try {

		shareService.logShareViewing( request.share.id );

	} catch ( any error ) {

		errorResponse = requestHelper.processError( error );

	}

	// This is a background API call, no need for a full view.
	request.response.template = "blank";
	request.response.body = isSimpleValue( errorResponse )
		? "Viewing logged."
		: "Viewing error."
	;

</cfscript>
