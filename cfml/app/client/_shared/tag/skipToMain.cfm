<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="attributes.anchor" type="string";

	anchor = attributes.anchor;

	include "./skipToMain.view.cfm";
	exit;

</cfscript>
