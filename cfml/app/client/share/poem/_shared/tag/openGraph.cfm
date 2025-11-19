<cfscript>

	// Define properties for dependency-injection.
	config = request.ioc.get( "config" );
	router = request.ioc.get( "core.lib.web.Router" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// In order to show a different Open Graph image when the contents of the image
	// change, we need to create a thumbprint that we can validate. This allows the URL to
	// be a bit more dynamic without opening up an attack vector (for CPU saturation).
	// --
	// Todo: move to a centralized location (ex, PoemService).
	imageVersion = hash( request.poem.name & request.poem.content & request.user.name );

	// Note: using "og" prefix to avoid "url" scope collision.
	ogUrl = router.externalUrlFor({ event: "share.poem" });
	ogTitle = request.poem.name;
	ogDescription = "A poem by #request.user.name# (hosted on #config.site.name#).";
	ogImageUrl = router.externalUrlFor({
		event: "share.poem.openGraphImage",
		imageVersion: imageVersion
	});

	include "./openGraph.view.cfm";
	exit;

</cfscript>
