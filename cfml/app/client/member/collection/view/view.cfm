<cfscript>

	// Define properties for dependency-injection.
	collectionAccess = request.ioc.get( "core.lib.service.collection.CollectionAccess" );
	externalLinkInterceptor = request.ioc.get( "core.lib.web.ExternalLinkInterceptor" );
	poemModel = request.ioc.get( "core.lib.model.poem.PoemModel" );
	router = request.ioc.get( "core.lib.web.Router" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.collectionID" type="numeric";

	partial = getPartial(
		authContext = request.authContext,
		collectionID = val( url.collectionID )
	);
	collection = partial.collection;
	poems = partial.poems;
	title = collection.name;
	errorResponse = "";

	request.response.title = title;
	request.response.breadcrumbs.append( request.breadcrumbForCollection( collection ) );

	include "./view.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial(
		required struct authContext,
		required numeric collectionID
		) {

		var context = collectionAccess.getContext( authContext, collectionID, "canView" );
		var collection = context.collection;

		// Proxy any external links through an interstitial page where we can alert the
		// user that they are about to leave the site.
		collection.descriptionHtml = externalLinkInterceptor.intercept( collection.descriptionHtml );

		var poems = poemModel.getByFilter(
			collectionID = collection.id,
			withSort = "name"
		);

		return {
			collection,
			poems,
		};

	}

</cfscript>
