<cfscript>

	// This whole subsystem depends on the last caught error.
	param name="request.error" type="any";

	// There's only one valid route for this module.
	cfmodule( template = "./message/message.cfm" );
	cfmodule( template = "./_layout/layout.cfm" );

</cfscript>
