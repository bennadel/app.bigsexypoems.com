<cfscript>

	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// This whole subsystem depends on the last caught error.
	param name="request.error" type="any";

	request.errorResponse = requestHelper.processError( request.error );

	if ( request.isHtmx && ! request.htmx.boosted ) {

		// Responses to an (non-boosted) htmx request are intended to be transcluded into
		// an existing UI. As such, the response wrapper is minimal.
		cfmodule( template = "./htmx/htmx.cfm" );

	} else {

		cfmodule( template = "./message/message.cfm" );
		cfmodule( template = "./_layout/layout.cfm" );

	}

</cfscript>
