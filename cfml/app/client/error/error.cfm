<cfscript>

	// Define properties for dependency-injection.
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// This whole subsystem depends on the last caught error.
	param name="request.error" type="any";

	request.errorResponse = requestHelper.processError( request.error );

	if ( request.isHtmx && ! request.htmx.boosted ) {

		// HTMX errors (that bubble up to the global error handler) are reported using the
		// hx-trigger header. As such, we'll use the blank template.
		cfmodule( template = "./htmx/htmx.cfm" );
		cfmodule( template = "/client/_shared/layout/blank.cfm" );

	} else {

		cfmodule( template = "./message/message.cfm" );
		cfmodule( template = "./_shared/layout/default.cfm" );

	}

</cfscript>
