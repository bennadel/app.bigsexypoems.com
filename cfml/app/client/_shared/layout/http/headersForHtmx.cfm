<cfscript>

	// Todo: implement the htmx response headers.

	// param name="request.response.hxLocation" type="string" default="";
	// param name="request.response.hxPushUrl" type="string" default="";
	// param name="request.response.hxRedirect" type="string" default="";
	// param name="request.response.hxRefresh" type="string" default="";
	// param name="request.response.hxReplaceUrl" type="string" default="";
	// param name="request.response.hxReswap" type="string" default="";
	// param name="request.response.hxRetarget" type="string" default="";
	// param name="request.response.hxReselect" type="string" default="";
	param name="request.response.hxTrigger" type="any" default="";
	// param name="request.response.hxTriggerAfterSettle" type="any" default="";
	// param name="request.response.hxTriggerAfterSwap" type="any" default="";

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

</cfscript>
