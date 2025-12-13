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

	// By default, HTMX won't swap-in non-successful HTTP responses. As such, any errors
	// that bubble up to the global error handler (ie, that weren't explicitly handled by
	// the controller) need to be reported using an HTTP response header.
	if ( request.isHtmx ) {

		cfmodule( template = "./htmx/htmx.cfm" );
		cfmodule( template = "/client/_shared/layout/blank.cfm" );

	} else {

		cfmodule( template = "./message/message.cfm" );
		cfmodule( template = "./_shared/layout/default.cfm" );

	}

</cfscript>
