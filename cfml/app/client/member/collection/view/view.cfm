<cfscript>

	// Define properties for dependency-injection.
	collectionAccess = request.ioc.get( "core.lib.service.collection.CollectionAccess" );
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
	title = collection.name;
	errorResponse = "";

	request.response.title = title;

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

		return {
			collection
		};

	}

</cfscript>
