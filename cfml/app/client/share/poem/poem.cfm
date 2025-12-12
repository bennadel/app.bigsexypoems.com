<cfscript>

	// Define properties for dependency-injection.
	poemModel = request.ioc.get( "core.lib.model.poem.PoemModel" );
	// requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	rateLimitService = request.ioc.get( "core.lib.util.RateLimitService" );
	requestMetadata = request.ioc.get( "core.lib.web.RequestMetadata" );
	router = request.ioc.get( "core.lib.web.Router" );
	sessionService = request.ioc.get( "core.lib.service.session.SessionService" );
	shareModel = request.ioc.get( "core.lib.model.poem.share.ShareModel" );
	shareValidation = request.ioc.get( "core.lib.model.poem.share.ShareValidation" );
	userModel = request.ioc.get( "core.lib.model.user.UserModel" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// SECURITY: This entire subsystem requires an identified user.
	// request.authContext = requestHelper.ensureIdentifiedContext();
	// --
	// Todo: will probably replace with something more official in the future.
	request.authContext = sessionService.getAuthenticationContext();

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
	request.user = userModel.get( request.poem.userID );

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

	request.response.template = "default";

	switch ( router.next( "view" ) ) {
		case "logViewing":
		case "openGraphImage":
		case "view":
			cfmodule( template = router.nextTemplate() );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

	switch ( request.response.template ) {
		case "blank":
			cfmodule( template = "/client/_shared/layout/blank.cfm" );
		break;
		case "default":
			cfmodule( template = "./_shared/layout/default.cfm" );
		break;
		default:
			throw( type = "App.Routing.InvalidTemplate" );
		break;
	}

</cfscript>
