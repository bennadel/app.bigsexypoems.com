<cfscript>

	// Define properties for dependency-injection.
	collectionModel = request.ioc.get( "core.lib.model.collection.CollectionModel" );
	poemAccess = request.ioc.get( "core.lib.service.poem.PoemAccess" );
	poemService = request.ioc.get( "core.lib.service.poem.PoemService" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.poemID" type="numeric";

	partial = getPartial(
		authContext = request.authContext,
		poemID = val( url.poemID )
	);
	poem = partial.poem;
	maybeCollection = partial.maybeCollection;
	title = poem.name;

	lines = poemService.splitLines( poem.content );

	request.response.title = title;
	request.response.breadcrumbs.append( request.breadcrumbForPoem( poem ) );

	include "./view.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial(
		required struct authContext,
		required numeric poemID
		) {

		var context = poemAccess.getContext( authContext, poemID, "canView" );
		var poem = context.poem;
		var maybeCollection = maybeNew();

		if ( poem.collectionID ) {

			maybeCollection.set( collectionModel.get( poem.collectionID ) );

		}

		return {
			poem,
			maybeCollection,
		};

	}

</cfscript>
