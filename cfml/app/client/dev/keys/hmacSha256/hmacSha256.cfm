<cfscript>

	// Define properties for dependency-injection.
	secureRandom = request.ioc.get( "core.lib.util.SecureRandom" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	key = binaryEncode( secureRandom.generateKeyForAlgorithm( "HmacSha256" ), "base64" );
	title = request.response.title = "HMAC SHA-256 Key";

	include "./hmacSha256.view.cfm";

</cfscript>
