<cfscript>

	config = request.ioc.get( "config" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="request.response.title" type="string" default=config.site.name;

	include "./title.view.cfm";

</cfscript>
