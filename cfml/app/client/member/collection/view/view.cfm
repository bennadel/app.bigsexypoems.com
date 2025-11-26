<cfscript>

	// Define properties for dependency-injection.
	collectionAccess = request.ioc.get( "core.lib.service.collection.CollectionAccess" );
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

		// Todo: I'm passing in the userID here because the collectionID isn't indexed. I
		// will add an index to that column.
		var poems = poemModel
			.getByFilter(
				userID = collection.userID,
				collectionID = collection.id
			)
			.sort( ( a, b ) => compareNoCase( a.name, b.name ) )
		;

		return {
			collection,
			poems,
		};

	}

</cfscript>
