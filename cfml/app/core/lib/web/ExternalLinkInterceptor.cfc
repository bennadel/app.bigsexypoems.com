component hint = "I rewrite external links in HTML to route through an interstitial warning page." {

	// Define properties for dependency-injection.
	property name="base64UrlEncoder" ioc:type="core.lib.util.Base64UrlEncoder";
	property name="internalHost" ioc:skip;
	property name="jsoup" ioc:type="core.lib.util.JSoupParser";
	property name="logger" ioc:type="core.lib.util.Logger";
	property name="router" ioc:type="core.lib.web.Router";
	property name="site" ioc:get="config.site";
	property name="urlParser" ioc:type="core.lib.util.UrlParser";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the interceptor.
	*/
	public void function initAfterInjection() {

		variables.internalHost = urlParser.getHost( site.url );

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I decode the given external URL payload, returning the original URL string.
	*/
	public string function decode( required string encodedUrl ) {

		return base64UrlEncoder.decodeString( encodedUrl );

	}


	/**
	* I intercept external links in the given HTML, rewriting them to proxy through the
	* external link warning page.
	*/
	public string function intercept( required string html ) {

		if ( ! html.len() ) {

			return html;

		}

		var body = jsoup.parseFragment( html );
		var anchors = body.select( "a[href]" );
		var mutationCount = 0;

		for ( var anchor in anchors ) {

			if ( isInternal( anchor ) ) {

				continue;

			}

			mutationCount++;
			// When passing URLs around as a search parameter in another URL, I find that
			// it's safest to encode the URL using base64url. This way, we don't have to
			// worry about any issues with double-encoding of embedded query string values
			// or losing access to embedded fragments.
			anchor.attr(
				"href",
				router.urlFor([
					event: "go.external",
					externalUrl: base64UrlEncoder.encodeString( anchor.attr( "href" ) )
				])
			);
			// Since we're going to be linking to an external resource, we want to open
			// the link in a new browser tab and inject rel attributes that prevent the
			// browser from providing information and mutation mechanics to a potentially
			// malicious target. You can see the OWASP guide to "reverse tabnapping":
			// --
			// https://owasp.org/www-community/attacks/Reverse_Tabnabbing
			anchor.attr( "rel", "noopener noreferrer" );
			anchor.attr( "target", "_blank" );

		}

		return mutationCount
			? body.html()
			: html
		;

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I determine if the given anchor element links to an internal page of the site.
	*/
	private boolean function isInternal( required any anchor ) {

		// While URLs are extremely flexible, the underlying URL parser (java.net.URI)
		// does have issues with characters outside of the URI specification. This is an
		// edge-case; but we need to wrap parsing in a try-catch so that we don't break
		// the calling context (which may be rendering the only view that allows editing
		// of this HTML content).
		try {

			var href = anchor.attr( "href" );
			// When parsing the href, we want to resolve it against the site URL such that
			// if the href is a relative or root-relative links, it will take on the site
			// host. This makes the comparison feel a little more safe. Note that if the
			// href has a host already, the site URL resolution will be ignored.
			var host = urlParser.getHost( href, site.url );

			return ( host == internalHost );

		} catch ( any error ) {

			// Malformed URLs are considered external for safety purposes.
			logger.logException( error );
			return false;

		}

	}

}
