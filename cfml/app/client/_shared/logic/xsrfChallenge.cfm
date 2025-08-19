<cfscript>

	xsrfTokens = request.ioc.get( "core.lib.web.XsrfTokens" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	request.xsrfToken = xsrfTokens.ensureCookie();

	// All form submissions must include a valid XSRF token.
	if ( request.isPost ) {

		xsrfTokens.testRequest();

	}

</cfscript>
