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
	param name="form.isConfirmed" type="boolean" default=false;

	partial = getPartial(
		authContext = request.authContext,
		collectionID = val( url.collectionID )
	);
	collection = partial.collection;

	title = "Delete Collection";
	errorResponse = "";

	request.response.title = title;

	if ( request.isPost ) {

		try {

			if ( ! form.isConfirmed ) {

				throw( type = "App.ConfirmationRequired" );

			}

			collectionService.delete(
				authContext = request.authContext,
				id = collection.id
			);

			router.goto([
				event: "member.collection.list",
				flash: "your.collection.deleted"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./delete.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial(
		required struct authContext,
		required numeric collectionID
		) {

		var context = collectionAccess.getContext( authContext, collectionID, "canDelete" );
		var collection = context.collection;

		return {
			collection
		};

	}

</cfscript>
