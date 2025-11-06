<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="attributes.content" type="string";
	param name="attributes.maxLength" type="numeric" default=40;
	param name="attributes.xClass" type="string" default="";
	param name="attributes.xClassToken" type="string" default="";

	content = attributes.content;
	maxLength = val( attributes.maxLength );
	xClass = attributes.xClass;
	xClassToken = attributes.xClassToken;

	include "./poemPreviewInTable.view.cfm";
	exit;

</cfscript>
