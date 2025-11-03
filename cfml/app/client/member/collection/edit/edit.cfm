<cfscript>

	// Define properties for dependency-injection.
	collectionAccess = request.ioc.get( "core.lib.service.collection.CollectionAccess" );
	collectionService = request.ioc.get( "core.lib.service.collection.CollectionService" );
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.collectionID" type="numeric";
	param name="form.name" type="string" default="";
	param name="form.descriptionMarkdown" type="string" default="";

	partial = getPartial(
		authContext = request.authContext,
		collectionID = val( url.collectionID )
	);
	collection = partial.collection;
	title = "Update Collection";
	errorResponse = "";

	request.response.title = title;

	if ( request.isGet ) {

		form.name = collection.name;
		form.descriptionMarkdown = collection.descriptionMarkdown;

	}

	if ( request.isPost ) {

		try {

			collectionService.update(
				authContext = request.authContext,
				id = collection.id,
				name = form.name,
				descriptionMarkdown = form.descriptionMarkdown
			);

			router.goto([
				event: "member.collection.view",
				collectionID: collection.id,
				flash: "your.collection.updated"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./edit.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial(
		required struct authContext,
		required numeric collectionID
		) {

		var context = collectionAccess.getContext( authContext, collectionID, "canUpdate" );
		var collection = context.collection;

		return {
			collection
		};

	}

</cfscript>
