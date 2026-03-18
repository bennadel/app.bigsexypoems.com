<cfscript>

	// Define properties for dependency-injection.
	base64UrlEncoder = request.ioc.get( "core.lib.util.Base64UrlEncoder" );
	config = request.ioc.get( "config" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.externalUrl" type="string" default="";

	// Note: we are intentionally doing this without a try/catch so that any decoding
	// errors bubble up to the root of the application and render an error page. There's
	// no meaningful way to recover locally.
	externalUrl = base64UrlEncoder.decodeString( url.externalUrl );
	externalHostname = getExternalHost( externalUrl );
	sitename = config.site.name;

	// Only allow http:// and https:// URLs.
	if ( ! externalUrl.reFindNoCase( "^https?://" ) ) {

		throw( type = "App.BadRequest" );

	}

	request.response.title = "Leaving #sitename#";

	include "./external.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I extract the host name from the given URL.
	*/
	private string function getExternalHost( required string uri ) {

		return createObject( "java", "java.net.URI" )
			.init( uri )
			.getHost()
		;

	}

</cfscript>
