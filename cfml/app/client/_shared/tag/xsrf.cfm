<cfscript>

	// Define properties for dependency-injection.
	xsrfTokens = request.ioc.get( "core.lib.web.XsrfTokens" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	challengeName = xsrfTokens.getChallengeName();
	challengeToken = request.xsrfToken;

	include "./xsrf.view.cfm";

</cfscript>
