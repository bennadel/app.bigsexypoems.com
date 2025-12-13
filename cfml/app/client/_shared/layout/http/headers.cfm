<cfscript>

	param name="request.response.statusCode" type="numeric" default=200;

	cfheader( statusCode = request.response.statusCode );

</cfscript>
