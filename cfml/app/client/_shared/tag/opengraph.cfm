<cfscript>

	// Define properties for dependency-injection.
	config = request.ioc.get( "config" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	og = {
		url: config.site.url,
		title: config.site.name,
		description: "An online poetry authoring application that helps you unlock your inner BigSexy with syllable counts, rhymes schemes, and synonyms!",
		imageUrl: "https://app.bigsexypoems.com/static/opengraph/big-sexy-poems.png"
	};

	include "./opengraph.view.cfm";
	exit;

</cfscript>
