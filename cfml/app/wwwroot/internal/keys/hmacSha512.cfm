<cfscript>

	key = request.ioc.get( "core.lib.util.SecureRandom" )
		.generateKeyForAlgorithm( "HmacSha512" )
	;

	writeOutput( binaryEncode( key, "base64" ) );

</cfscript>
