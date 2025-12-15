<cfscript>

	// Define properties for dependency-injection.
	config = request.ioc.get( "config" );
	router = request.ioc.get( "core.lib.web.Router" );
	shareService = request.ioc.get( "core.lib.service.poem.share.ShareService" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// Note: using "og" prefix to avoid "url" scope collision.
	ogUrl = router.externalUrlFor({ event: "share.poem" });
	ogTitle = request.poem.name;
	ogDescription = "A poem by #request.user.name# (hosted on #config.site.name#).";
	ogImageUrl = router.externalUrlFor({
		event: "share.poem.openGraphImage",
		// In order to show a different Open Graph image when the contents of the poem
		// change, we need to create a thumbprint of the content that can act as cache
		// invalidation. This allows the URL to be a bit more dynamic without opening up
		// an attack vector (for CPU saturation).
		imageVersion: shareService.getOpenGraphImageVersion(
			poemName = request.poem.name,
			poemContent = request.poem.content,
			userName = request.user.name
		)
	});

	include "./openGraph.view.cfm";
	exit;

</cfscript>
