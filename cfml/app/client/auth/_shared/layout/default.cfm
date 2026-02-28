<cfscript>

	// Define properties for dependency-injection.
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="request.response.title" type="string";
	param name="request.response.body" type="string";

	// Include common HTTP response headers.
	cfmodule( template = "/client/_shared/layout/http/headers.cfm" );
	cfmodule( template = "/client/_shared/layout/http/headersForHtmx.cfm" );

	// Reset the output buffer.
	cfcontent( type = "text/html; charset=utf-8" );

	include "./default.view.cfm";

</cfscript>
