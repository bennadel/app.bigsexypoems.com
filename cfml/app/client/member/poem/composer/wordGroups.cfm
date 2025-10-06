<cfscript>

	// Define properties for dependency-injection.
	ui = request.ioc.get( "core.lib.web.UI" );
	wordService = request.ioc.get( "core.lib.util.WordService" );

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
