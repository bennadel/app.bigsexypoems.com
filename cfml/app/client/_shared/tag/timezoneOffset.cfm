<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	param name="attributes.xName" type="string" default="timezoneOffsetInMinutes";

	include "./timezoneOffset.view.cfm";

</cfscript>
