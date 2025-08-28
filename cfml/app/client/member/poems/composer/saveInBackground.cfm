<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="form.content" type="string";

	sleep( 1000 );

	request.response.template = "blank";

</cfscript>
