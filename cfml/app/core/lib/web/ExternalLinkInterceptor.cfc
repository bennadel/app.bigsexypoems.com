component hint = "I rewrite external links in HTML to route through an interstitial warning page." {

	// Define properties for dependency-injection.
	property name="base64UrlEncoder" ioc:type="core.lib.util.Base64UrlEncoder";
	property name="classLoader" ioc:type="core.lib.classLoader.JSoupClassLoader";
	property name="site" ioc:get="config.site";
	property name="siteHostname" ioc:skip;

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the interceptor after dependency-injection.
	*/
	public void function initAfterInjection() {

		variables.siteHostname = createObject( "java", "java.net.URI" )
			.init( site.url )
			.getHost()
		;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I intercept external links in the given HTML, rewriting them to proxy through the
	* external link warning page.
	*/
	public string function intercept( required string html ) {

		if ( ! html.len() ) {

			return html;

		}

		var document = classLoader.create( "org.jsoup.Jsoup" )
			.parseBodyFragment( html )
		;
		var anchors = document.select( "a[href]" );

		for ( var anchor in anchors ) {

			var href = anchor.attr( "href" );

			try {

				var uri = createObject( "java", "java.net.URI" ).init( href );
				var linkHostname = ( uri.getHost() ?: "" );

			} catch ( any error ) {

				// Malformed URLs are left as-is.
				continue;

			}

			if ( linkHostname == siteHostname ) {

				continue;

			}

			anchor.attr(
				"href",
				"/index.cfm?event=go.external&externalUrl=#base64UrlEncoder.encodeString( href )#"
			);

		}

		return document.body().html();

	}

}
