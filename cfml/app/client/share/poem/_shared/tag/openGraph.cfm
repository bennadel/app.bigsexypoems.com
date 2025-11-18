<cfscript>

	// Define properties for dependency-injection.
	config = request.ioc.get( "config" );
	router = request.ioc.get( "core.lib.web.Router" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// Note: using "og" prefix to avoid "url" scope collision.
	ogUrl = router.externalUrlFor({ event: "share.poem" });
	ogTitle = request.poem.name;
	ogDescription = "A poem by #request.user.name# (hosted on #config.site.name#).";
	ogImageUrl = router.externalUrlFor({ event: "share.poem.openGraphImage" });

	include "./openGraph.view.cfm";
	exit;

</cfscript>
