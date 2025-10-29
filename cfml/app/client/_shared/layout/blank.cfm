<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="request.response.statusCode" type="numeric" default=200;
	param name="request.response.hxTrigger" type="any" default="";
	param name="request.response.body" type="string" default="";

	if ( isStruct( request.response.hxTrigger ) ) {

		cfheader(
			name = "HX-Trigger",
			value = serializeJson( request.response.hxTrigger )
		);

	} else if ( len( request.response.hxTrigger ) ) {

		cfheader(
			name = "HX-Trigger",
			value = request.response.hxTrigger
		);

	}

	// Override the response status code.
	cfheader( statusCode = request.response.statusCode );
	// Reset the output buffer.
	cfcontent( type = "text/html; charset=utf-8" );

	// Send down the response.
	echo( request.response.body );

</cfscript>
