<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="attributes.message" type="string" default="";
	param name="attributes.response" type="any" default="";
	param name="attributes.xClass" type="string" default="";
	param name="attributes.xClassToken" type="string" default="";

	if ( attributes.message.len() ) {

		message = attributes.message;

	// Since ColdFusion doesn't have the best notion of NULL, we're going to be defaulting
	// the error response to the empty string. It will only become actionable as a Struct.
	} else if ( isStruct( attributes.response ) ) {

		message = attributes.response.message;

	} else {

		exit;

	}

	include "./errorMessage.view.cfm";

	// For CFML hierarchy purposes, allow for closing tag, but don't execute a second time.
	exit;

</cfscript>