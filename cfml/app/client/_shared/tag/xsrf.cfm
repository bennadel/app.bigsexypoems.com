<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	xsrfTokens = request.ioc.get( "core.lib.web.XsrfTokens" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	challengeName = xsrfTokens.getChallengeName();
	challengeToken = request.xsrfToken;

	include "./xsrf.view.cfm";

</cfscript>
