<cfscript>

	// Define properties for dependency-injection.
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	revisionAccess = request.ioc.get( "core.lib.service.poem.RevisionAccess" );
	revisionNavigator = request.ioc.get( "core.lib.service.poem.RevisionNavigator" );
	revisionService = request.ioc.get( "core.lib.service.poem.RevisionService" );
	router = request.ioc.get( "core.lib.web.Router" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.revisionID" type="numeric";
	param name="form.isConfirmed" type="boolean" default=false;

	partial = getPartial(
		authContext = request.authContext,
		revisionID = val( url.revisionID )
	);
	poem = partial.poem;
	revision = partial.revision;
	position = partial.position;
	title = "Delete Revision";
	errorResponse = "";

	request.response.title = title;
	request.response.breadcrumbs.append( request.breadcrumbForPoem( poem ) );
	request.response.breadcrumbs.append( request.breadcrumbForRevisions( poem ) );
	request.response.breadcrumbs.append( request.breadcrumbForRevision( revision, position ) );
	request.response.breadcrumbs.append( "Delete Confirmation" );

	if ( request.isPost ) {

		try {

			if ( ! form.isConfirmed ) {

				throw( type = "App.ConfirmationRequired" );

			}

			revisionService.delete(
				authContext = request.authContext,
				id = revision.id
			);

			router.goto([
				event: "member.poem.revision",
				poemID: poem.id,
				flash: "your.poem.revision.deleted"
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
		required numeric revisionID
		) {

		var context = revisionAccess.getContext( authContext, revisionID, "canDelete" );
		var poem = context.poem;
		var revision = context.revision;
		var position = revisionNavigator.getPosition( revision );

		return {
			poem,
			revision,
			position
		};

	}

</cfscript>
