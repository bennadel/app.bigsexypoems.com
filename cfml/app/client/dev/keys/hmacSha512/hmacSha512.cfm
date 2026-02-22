<cfscript>

	// Define properties for dependency-injection.
	secureRandom = request.ioc.get( "core.lib.util.SecureRandom" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	key = binaryEncode( secureRandom.generateKeyForAlgorithm( "HmacSha512" ), "base64" );
	title = request.response.title = "HMAC SHA-512 Key";

	include "./hmacSha512.view.cfm";

</cfscript>
