<cfscript>

	// Define properties for dependency-injection.
	externalLinkInterceptor = request.ioc.get( "core.lib.web.ExternalLinkInterceptor" );
	poemService = request.ioc.get( "core.lib.service.poem.PoemService" );
	router = request.ioc.get( "core.lib.web.Router" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	poem = request.poem;
	share = request.share;
	user = request.user;

	// Proxy any external links through an interstitial page where we can alert the user
	// that they are about to leave the site.
	share.noteHtml = externalLinkInterceptor.intercept( share.noteHtml );

	title = poem.name;
	lines = poemService.splitLines( poem.content );

	request.response.title = title;

	include "./view.view.cfm";

</cfscript>
