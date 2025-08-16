<cfscript>

	config = request.ioc.get( "config" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="request.response.title" type="string" default=config.site.name;

	include "./title.view.cfm";

</cfscript>
