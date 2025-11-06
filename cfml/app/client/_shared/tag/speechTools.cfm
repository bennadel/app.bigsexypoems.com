<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="attributes.inputID" type="string";
	param name="attributes.xClass" type="string" default="";
	param name="attributes.xClassToken" type="string" default="";

	inputID = attributes.inputID;
	xClass = attributes.xClass;
	xClassToken = attributes.xClassToken;

	include "./speechTools.view.cfm";
	exit;

</cfscript>
