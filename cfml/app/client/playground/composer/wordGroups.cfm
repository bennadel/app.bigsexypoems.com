<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="attributes.thing" type="string";
	param name="attributes.groups" type="array";

	thing = attributes.thing;
	groups = attributes.groups;

	include "./wordGroups.view.cfm";

</cfscript>
