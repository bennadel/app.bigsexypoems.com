<cfscript>

	// Define properties for dependency-injection.
	collectionService = request.ioc.get( "core.lib.service.collection.CollectionService" );
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="form.name" type="string" default="";
	param name="form.descriptionMarkdown" type="string" default="";

	title = "Create New Collection";
	errorResponse = "";

	request.response.title = title;

	if ( request.isPost ) {

		try {

			collectionID = collectionService.createCollection(
				authContext = request.authContext,
				userID = request.authContext.user.id,
				name = form.name,
				descriptionMarkdown = form.descriptionMarkdown
			);

			router.goto([
				event: "member.collection.view",
				collectionID: collectionID,
				flash: "your.collection.created"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./add.view.cfm";

</cfscript>
