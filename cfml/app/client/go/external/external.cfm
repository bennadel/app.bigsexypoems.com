<cfscript>

	// Define properties for dependency-injection.
	config = request.ioc.get( "config" );
	externalLinkInterceptor = request.ioc.get( "core.lib.web.ExternalLinkInterceptor" );
	ui = request.ioc.get( "core.lib.web.UI" );
	urlParser = request.ioc.get( "core.lib.util.UrlParser" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.externalUrl" type="string" default="";

	// Note: we are intentionally doing this without a try/catch so that any decoding
	// errors bubble up to the root of the application and render an error page. There's
	// no meaningful way to recover locally from a malformed encoding.
	externalUrl = externalLinkInterceptor.decode( url.externalUrl );
	externalHostname = urlParser.getHost( externalUrl );
	sitename = config.site.name;

	// Only allow http:// and https:// URLs.
	if ( ! externalUrl.reFindNoCase( "^https?://" ) ) {

		throw( type = "App.BadRequest" );

	}

	request.response.title = "Leaving #sitename#";

	include "./external.view.cfm";

</cfscript>
