component
	extends = "core.lib.util.markdown.BaseMarkdownSanitizer"
	hint = "I provide methods for sanitizing the block HTML content."
	{

	// Define properties for dependency-injection.
	property name="cleaner" ioc:skip;
	property name="jsoup" ioc:type="core.lib.util.JSoupParser";
	property name="safelist" ioc:skip;

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the HTML sanitizer.
	*/
	public void function initAfterInjection() {

		variables.safelist = jsoup.createSafelist()
			// Basic formatting.
			.addTags([ "b", "del", "em", "i", "mark", "strike", "strong", "u" ])
			// Headers.
			// --
			// Todo: we might want to swap these (or at least the H1) with a p[strong]
			// configuration instead?
			.addTags([ "h1", "h2", "h3", "h4", "h5", "h6" ])
			// Basic structuring.
			.addTags([ "p", "blockquote", "ul", "ol", "li", "br", "hr" ])
			// Code blocks.
			.addTags([ "pre", "code" ])
			.addAttributes( "pre", [ "class" ] )
			.addAttributes( "code", [ "class" ] )
			// Anchor links.
			.addTags([ "a" ])
			.addAttributes( "a", [ "href" ] )
			.addProtocols( "a", "href", [ "http", "https" ] )
			// Note: I'm moving these anchor attributes enforcement to the external link
			// interceptor.
			// .addEnforcedAttribute( "a", "rel", "noopener noreferrer" )
			// .addEnforcedAttribute( "a", "target", "_blank" )
		;

		variables.cleaner = jsoup.createCleaner( safelist );

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I sanitize the given HTML. Any invalid or illegal markup is quietly removed from the
	* sanitized output; but the collection of removed tags and attributes will be provided
	* in the untrusted markup report.
	*/
	public struct function sanitize( required string unsafeHtml ) {

		var unsafeDom = jsoup.parseHtml( unsafeHtml );
		var unsafeMarkup = getUnsafeMarkup( safelist, unsafeDom );
		var safeDom = cleaner.clean( unsafeDom );
		var safeHtml = safeDom.body().html();

		return {
			safeHtml: safeHtml,
			unsafeMarkup: unsafeMarkup
		};

	}

}
