<cfscript>

	// Define properties for dependency-injection.
	poemModel = request.ioc.get( "core.lib.model.poem.PoemModel" );
	// requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	rateLimitService = request.ioc.get( "core.lib.util.RateLimitService" );
	requestMetadata = request.ioc.get( "core.lib.web.RequestMetadata" );
	router = request.ioc.get( "core.lib.web.Router" );
	shareModel = request.ioc.get( "core.lib.model.poem.share.ShareModel" );
	shareValidation = request.ioc.get( "core.lib.model.poem.share.ShareValidation" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// SECURITY: This entire subsystem requires an identified user.
	// request.authContext = requestHelper.ensureIdentifiedContext();

	// This rate limiting is here just to prevent brute-force guessing of share links. As
	// such, the limit can be relatively high.
	rateLimitService.testRequest( "poem-share-by-ip", requestMetadata.getIpAddress() );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.shareID" type="numeric" default=0;
	param name="url.shareToken" type="string" default="";

	// This entire section depends on a valid share.
	request.share = shareModel.get( val( url.shareID ) );
	request.poem = poemModel.get( request.share.poemID );

	// Todo: put all this logic somewhere better?

	if ( compare( request.share.token, url.shareToken ) ) {

		shareValidation.throwNotFoundError();

	}

	// Every link in this subsystem has to propagate the share link information.
	router.persistSearchParams(
		eventPrefix = "share.poem",
		searchParams = [
			{
				name: "shareID",
				value: request.share.id
			},
			{
				name: "shareToken",
				value: request.share.token
			}
		]
	);

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	switch ( router.next( "view" ) ) {
		case "view":
			cfmodule( template = router.nextTemplate() );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

	cfmodule( template = "./_layout/default.cfm" );

</cfscript>
